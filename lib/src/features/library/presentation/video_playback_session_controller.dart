import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../data/video_playback_repository.dart';
import '../domain/playback_token_entity.dart';
import 'video_playback_engine.dart';

const double playbackRefreshAtFraction = 0.8;
const Duration minimumPlaybackRefreshDelay = Duration(seconds: 15);
const int maximumPlaybackRefreshesPerWindow = 3;
const Duration playbackRefreshWindow = Duration(seconds: 60);

abstract interface class PlaybackRefreshHandle {
  void cancel();
}

abstract interface class PlaybackRefreshScheduler {
  PlaybackRefreshHandle schedule(Duration delay, void Function() callback);
}

class _TimerRefreshHandle implements PlaybackRefreshHandle {
  _TimerRefreshHandle(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}

class _TimerRefreshScheduler implements PlaybackRefreshScheduler {
  const _TimerRefreshScheduler();

  @override
  PlaybackRefreshHandle schedule(Duration delay, void Function() callback) =>
      _TimerRefreshHandle(Timer(delay, callback));
}

final Provider<PlaybackRefreshScheduler> playbackRefreshSchedulerProvider =
    Provider<PlaybackRefreshScheduler>(
      (Ref ref) => const _TimerRefreshScheduler(),
    );

sealed class VideoPlaybackSessionState {
  const VideoPlaybackSessionState();
}

final class VideoPlaybackReady extends VideoPlaybackSessionState {
  const VideoPlaybackReady({required this.engine, required this.ticket});

  final VideoPlaybackEngine engine;
  final PlaybackTokenEntity ticket;
}

final class VideoPlaybackFailed extends VideoPlaybackSessionState {
  const VideoPlaybackFailed({
    required this.message,
    required this.canRetry,
    this.isUnavailable = false,
  });

  final String message;
  final bool canRetry;
  final bool isUnavailable;
}

enum _RefreshReason { scheduled, playbackAuthError }

class _RefreshBudgetExceeded implements Exception {
  const _RefreshBudgetExceeded();
}

class _PlaybackEngineFailure implements Exception {
  const _PlaybackEngineFailure(this.description);

  final String description;

  @override
  String toString() => description;
}

/// Owns the HLS controller and replaces it whenever the short-lived playback
/// token must be re-minted (viewer PRD B1).
class VideoPlaybackSessionController
    extends AsyncNotifier<VideoPlaybackSessionState> {
  VideoPlaybackSessionController(this.videoId);

  final String videoId;
  final List<DateTime> _refreshTimes = <DateTime>[];

  VideoPlaybackEngine? _engine;
  PlaybackRefreshHandle? _refreshTimer;
  bool _refreshing = false;
  String? _handledErrorDescription;

  @override
  Future<VideoPlaybackSessionState> build() async {
    ref.onDispose(_dispose);
    return _loadInitial();
  }

  Future<void> retry() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;
    _refreshTimer?.cancel();
    _refreshTimes.clear();
    state = const AsyncLoading<VideoPlaybackSessionState>();

    final VideoPlaybackEngine? previous = _detachEngine();
    if (previous != null) {
      await previous.dispose();
    }

    try {
      final VideoPlaybackSessionState next = await _loadInitial();
      if (ref.mounted) {
        state = AsyncData<VideoPlaybackSessionState>(next);
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<void> togglePlayback() async {
    final VideoPlaybackEngine? engine = _engine;
    if (engine == null) {
      return;
    }

    try {
      if (engine.value.isPlaying) {
        await engine.pause();
      } else {
        await engine.play();
      }
    } catch (error) {
      await _handleControlFailure(error);
    }
  }

  Future<void> seekTo(Duration position) async {
    final VideoPlaybackEngine? engine = _engine;
    if (engine == null) {
      return;
    }

    try {
      await engine.seekTo(position);
    } catch (error) {
      await _handleControlFailure(error);
    }
  }

  Future<VideoPlaybackSessionState> _loadInitial() async {
    try {
      PlaybackTokenEntity ticket = await _mint();
      try {
        final VideoPlaybackReady ready = await _attach(
          ticket,
          resumeAt: Duration.zero,
          wasPlaying: false,
        );
        _scheduleRefresh(ticket.expiresInSecs);
        return ready;
      } catch (error) {
        // A token can lapse between mint and native initialization. One
        // immediate re-mint is the retry; a second failure is surfaced.
        if (!_isPlaybackAuthFailure(error)) {
          rethrow;
        }
        _takeRefreshBudget();
        ticket = await _mint();
        final VideoPlaybackReady ready = await _attach(
          ticket,
          resumeAt: Duration.zero,
          wasPlaying: false,
        );
        _scheduleRefresh(ticket.expiresInSecs);
        return ready;
      }
    } catch (error) {
      return _failureFor(error);
    }
  }

  Future<void> _refresh(_RefreshReason reason) async {
    if (_refreshing || !ref.mounted) {
      return;
    }

    _refreshing = true;
    _refreshTimer?.cancel();

    try {
      _takeRefreshBudget();
      PlaybackTokenEntity fresh = await _mint();

      final VideoPlaybackEngine? previous = _engine;
      final Duration resumeAt = previous?.value.position ?? Duration.zero;
      final bool wasPlaying = previous?.value.isPlaying ?? false;

      // This is the native/Safari source swap: once the state is captured,
      // stop the old source, initialize a controller from the fresh manifest,
      // seek back, and resume only if it had been playing.
      if (wasPlaying) {
        await previous?.pause();
      }

      VideoPlaybackReady ready;
      try {
        ready = await _attach(
          fresh,
          resumeAt: resumeAt,
          wasPlaying: wasPlaying,
        );
      } catch (error) {
        // A scheduled swap that itself hits an expired media URL gets the one
        // immediate auth retry. An auth-error-triggered swap already *is* that
        // retry and therefore falls through to the visible failure.
        if (reason != _RefreshReason.scheduled ||
            !_isPlaybackAuthFailure(error)) {
          rethrow;
        }
        _takeRefreshBudget();
        fresh = await _mint();
        ready = await _attach(
          fresh,
          resumeAt: resumeAt,
          wasPlaying: wasPlaying,
        );
      }

      if (!ref.mounted) {
        await ready.engine.dispose();
        return;
      }

      state = AsyncData<VideoPlaybackSessionState>(ready);
      _scheduleRefresh(fresh.expiresInSecs);
      if (previous != null && !identical(previous, ready.engine)) {
        await previous.dispose();
      }
    } catch (error) {
      await _showFailure(error);
    } finally {
      _refreshing = false;
    }
  }

  Future<VideoPlaybackReady> _attach(
    PlaybackTokenEntity ticket, {
    required Duration resumeAt,
    required bool wasPlaying,
  }) async {
    final VideoPlaybackEngine next = ref
        .read(videoPlaybackEngineFactoryProvider)
        .create(ticket.manifestUri);

    try {
      await next.initialize();
      final String? description = next.value.errorDescription;
      if (description != null) {
        throw _PlaybackEngineFailure(description);
      }
      if (resumeAt > Duration.zero) {
        await next.seekTo(resumeAt);
      }
      if (wasPlaying) {
        await next.play();
      }
    } catch (error) {
      await next.dispose();
      if (error is _PlaybackEngineFailure) {
        rethrow;
      }
      throw _PlaybackEngineFailure(error.toString());
    }

    final VideoPlaybackEngine? current = _engine;
    current?.removeListener(_onEngineChanged);
    _engine = next;
    _handledErrorDescription = null;
    next.addListener(_onEngineChanged);

    return VideoPlaybackReady(engine: next, ticket: ticket);
  }

  Future<PlaybackTokenEntity> _mint() async {
    try {
      return await ref
          .read(videoPlaybackRepositoryProvider)
          .fetchPlaybackToken(videoId);
    } on ForbiddenError catch (error) {
      if (error.isSchoolSuspended && ref.mounted) {
        ref.read(schoolSuspensionProvider.notifier).confirm();
      }
      rethrow;
    }
  }

  void _scheduleRefresh(int expiresInSecs) {
    _refreshTimer?.cancel();
    final int scaledMilliseconds =
        (expiresInSecs *
                Duration.millisecondsPerSecond *
                playbackRefreshAtFraction)
            .round();
    final Duration scaled = Duration(milliseconds: scaledMilliseconds);
    final Duration delay = scaled < minimumPlaybackRefreshDelay
        ? minimumPlaybackRefreshDelay
        : scaled;
    _refreshTimer = ref
        .read(playbackRefreshSchedulerProvider)
        .schedule(delay, () => unawaited(_refresh(_RefreshReason.scheduled)));
  }

  void _takeRefreshBudget() {
    final DateTime now = DateTime.now();
    _refreshTimes.removeWhere(
      (DateTime at) => now.difference(at) >= playbackRefreshWindow,
    );
    if (_refreshTimes.length >= maximumPlaybackRefreshesPerWindow) {
      throw const _RefreshBudgetExceeded();
    }
    _refreshTimes.add(now);
  }

  void _onEngineChanged() {
    final String? description = _engine?.value.errorDescription;
    if (description == null || description == _handledErrorDescription) {
      return;
    }
    _handledErrorDescription = description;

    final AppError? mediaError = AppError.tryFromHttpFailureDescription(
      description,
    );
    if (mediaError is UnauthorizedError || mediaError is ForbiddenError) {
      unawaited(_refresh(_RefreshReason.playbackAuthError));
      return;
    }
    unawaited(_showFailure(mediaError ?? _PlaybackEngineFailure(description)));
  }

  Future<void> _handleControlFailure(Object error) async {
    final AppError? mediaError = _mediaError(error);
    if (mediaError is UnauthorizedError || mediaError is ForbiddenError) {
      await _refresh(_RefreshReason.playbackAuthError);
    } else {
      await _showFailure(mediaError ?? error);
    }
  }

  Future<void> _showFailure(Object error) async {
    _refreshTimer?.cancel();
    final VideoPlaybackEngine? engine = _engine;
    if (engine?.value.isPlaying ?? false) {
      try {
        await engine?.pause();
      } catch (_) {
        // The visible failure below is already the useful answer.
      }
    }
    if (ref.mounted) {
      state = AsyncData<VideoPlaybackSessionState>(_failureFor(error));
    }
  }

  VideoPlaybackFailed _failureFor(Object error) {
    if (error case final NotFoundError _) {
      return const VideoPlaybackFailed(
        message: 'This content is no longer available.',
        canRetry: false,
        isUnavailable: true,
      );
    }
    return const VideoPlaybackFailed(
      message: 'Playback failed. Check your connection and try again.',
      canRetry: true,
    );
  }

  bool _isPlaybackAuthFailure(Object error) {
    final AppError? mediaError = _mediaError(error);
    return mediaError is UnauthorizedError || mediaError is ForbiddenError;
  }

  AppError? _mediaError(Object error) =>
      AppError.tryFromHttpFailureDescription(error.toString());

  VideoPlaybackEngine? _detachEngine() {
    final VideoPlaybackEngine? current = _engine;
    current?.removeListener(_onEngineChanged);
    _engine = null;
    _handledErrorDescription = null;
    return current;
  }

  void _dispose() {
    _refreshTimer?.cancel();
    final VideoPlaybackEngine? current = _detachEngine();
    if (current != null) {
      unawaited(current.dispose());
    }
  }
}

final AsyncNotifierProviderFamily<
  VideoPlaybackSessionController,
  VideoPlaybackSessionState,
  String
>
videoPlaybackSessionControllerProvider = AsyncNotifierProvider.autoDispose
    .family<VideoPlaybackSessionController, VideoPlaybackSessionState, String>(
      VideoPlaybackSessionController.new,
      retry: (int retryCount, Object error) => null,
    );
