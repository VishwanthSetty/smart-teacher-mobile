import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/playback_tracker.dart';
import '../../../../core/sync/watch_interval.dart';
import '../../../library/presentation/video_playback_engine.dart';
import '../../../library/presentation/video_playback_session_controller.dart';
import '../activity_sync_controller.dart';

/// Bridges the player to the outbox (mobile plan §3).
///
/// Wraps the player screen rather than living inside the playback widget, for
/// two reasons:
///
/// * the engine is **replaced** whenever the short-lived playback token is
///   re-minted, and progress must survive that swap — the tracker outlives any
///   one engine, and re-attaching is just a listener move;
/// * full screen is a second route over the same provider, so a reporter
///   attached to the playback widget would exist twice and double-report. This
///   sits on the screen that stays mounted underneath both.
///
/// The token lifecycle and the progress beat stay independent, as the plan
/// requires: a failed re-mint must not drop queued beats, and a failed beat
/// must not interrupt playback. Nothing here awaits the network — beats go to
/// the durable queue and the worker drains them.
class VideoProgressReporter extends ConsumerStatefulWidget {
  const VideoProgressReporter({
    required this.videoId,
    required this.child,
    this.title = '',
    this.durationSecs,
    super.key,
  });

  final String videoId;
  final Widget child;
  final String title;
  final int? durationSecs;

  @override
  ConsumerState<VideoProgressReporter> createState() =>
      _VideoProgressReporterState();
}

class _VideoProgressReporterState extends ConsumerState<VideoProgressReporter>
    with WidgetsBindingObserver {
  late final PlaybackTracker _tracker = PlaybackTracker(onBeat: _emit);

  VideoPlaybackEngine? _attached;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _attached?.removeListener(_onEngineChanged);
    _attached = null;
    // The final flush. Everything still open is closed and queued here, which
    // is what makes leaving the screen mid-video lose nothing.
    _tracker.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Foreground is one of the plan's flush triggers: anything queued while
      // offline or backgrounded gets its chance as soon as the app is live.
      unawaited(ref.read(activitySyncControllerProvider).flush());
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Backgrounding closes the open range and queues it. Playback is already
      // stopping — `allowBackgroundPlayback` is off — so holding the range open
      // would only risk losing it to a force-quit.
      _tracker.onPlaybackInterrupted();
    }
  }

  @override
  Widget build(BuildContext context) {
    // `listen`, not `watch`: attaching a listener is a side effect, and
    // watching here would rebuild the whole player subtree on every session
    // state change.
    ref.listen<AsyncValue<VideoPlaybackSessionState>>(
      videoPlaybackSessionControllerProvider(widget.videoId),
      (
        AsyncValue<VideoPlaybackSessionState>? previous,
        AsyncValue<VideoPlaybackSessionState> next,
      ) => _syncAttachment(next.value),
    );
    _syncAttachment(
      ref
          .read(videoPlaybackSessionControllerProvider(widget.videoId))
          .value,
    );

    return widget.child;
  }

  void _syncAttachment(VideoPlaybackSessionState? state) {
    final VideoPlaybackEngine? engine = switch (state) {
      final VideoPlaybackReady ready => ready.engine,
      _ => null,
    };
    if (identical(engine, _attached)) {
      return;
    }

    // An engine swap is a discontinuity in the sample stream — the new
    // controller starts at zero before it seeks back. Close what is open
    // first, or the reopened range would span the gap and claim coverage that
    // was never played.
    _tracker.onPlaybackInterrupted();

    _attached?.removeListener(_onEngineChanged);
    _attached = engine;
    _wasPlaying = false;
    engine?.addListener(_onEngineChanged);
  }

  void _onEngineChanged() {
    final VideoPlaybackEngine? engine = _attached;
    if (engine == null) {
      return;
    }
    final VideoPlaybackValue value = engine.value;
    if (!value.isInitialized) {
      return;
    }

    _tracker.onSample(
      position: value.position,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
    );

    // A pause is a range close *and* a flush trigger, so the beat is queued at
    // the moment the user stops rather than waiting for the next 15s window
    // that may never come.
    if (_wasPlaying && !value.isPlaying) {
      _tracker.onPlaybackInterrupted();
    }
    _wasPlaying = value.isPlaying;
  }

  void _emit(List<WatchInterval> intervals, Duration position) {
    if (intervals.isEmpty) {
      return;
    }
    unawaited(
      ref
          .read(activitySyncControllerProvider)
          .recordVideoBeat(
            videoId: widget.videoId,
            intervals: intervals,
            position: position,
            title: widget.title,
            durationSecs: widget.durationSecs,
          ),
    );
  }
}
