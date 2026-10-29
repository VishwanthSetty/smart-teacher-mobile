import 'local_activity.dart';
import 'watch_interval.dart';

/// How far the reported position may jump between two samples before it is
/// read as a **seek** rather than as ordinary playback.
///
/// Sampling is nominally ~1s but a busy frame, a rate change, or a decoder
/// hiccup can stretch it, so the tolerance has to absorb some jitter without
/// swallowing a real scrub. Anything beyond it closes the open range and opens
/// a new one at the destination — which is exactly what makes dragging to the
/// end contribute no coverage.
const int playbackSeekToleranceSecs = 3;

/// A buffering stall longer than this closes the open range (mobile plan §3).
///
/// Position does not advance while stalled, so a stall left open would not
/// inflate coverage on its own. It is closed anyway because a long stall is
/// usually followed by a rebuffer-and-jump, and closing early keeps the
/// interval honest rather than bridging across the gap.
const Duration playbackStallThreshold = Duration(seconds: 2);

/// Coverage accumulated before the tracker asks to flush (mobile plan §3).
///
/// At 15s a lost beat costs at most 15s of coverage, and re-sending it from
/// the outbox is cheap. Raising this is the stated lever if beat volume bites
/// at rollout — the union rule makes a coarser cadence safe, only lossier on a
/// hard crash.
const int playbackFlushEverySecs = 15;

/// What the tracker hands its owner when a beat is due.
typedef PlaybackBeat =
    void Function(List<WatchInterval> intervals, Duration position);

/// Accumulates the ranges of a video that were **actually played**.
///
/// Deliberately timer-free and stream-free: every decision is a pure function
/// of the position samples pushed into [onSample] plus an injected clock, so
/// "a seek emits no interval" is a unit test rather than an integration test
/// that has to pump a real player.
///
/// The contract it upholds, from backend plan §3.1: a client sends intervals
/// actually played, never a computed percentage. The union is the server's job
/// and a client-computed percent would be unverifiable and forgeable.
class PlaybackTracker {
  PlaybackTracker({
    required PlaybackBeat onBeat,
    DateTime Function() clock = DateTime.now,
  }) : _onBeat = onBeat,
       _clock = clock;

  final PlaybackBeat _onBeat;
  final DateTime Function() _clock;

  /// Ranges closed but not yet handed to the outbox.
  final List<WatchInterval> _pending = <WatchInterval>[];

  int? _openRangeStartSecs;
  int _lastPositionSecs = 0;
  DateTime? _stallStartedAt;
  bool _disposed = false;

  /// The position the player last reported, for the resume write.
  Duration get position => Duration(seconds: _lastPositionSecs);

  /// Coverage held but not yet emitted. Exposed for tests and for the
  /// "is there anything worth flushing?" check on dispose.
  int get pendingCoverageSecs =>
      coveredSeconds(mergeWatchIntervals(_pendingIncludingOpenRange()));

  /// Feeds one player sample in. Safe to call at any rate.
  void onSample({
    required Duration position,
    required bool isPlaying,
    required bool isBuffering,
  }) {
    if (_disposed) {
      return;
    }
    final int secs = position.inSeconds;

    if (!isPlaying) {
      _closeOpenRange();
      _lastPositionSecs = secs;
      _stallStartedAt = null;
      return;
    }

    if (isBuffering) {
      final DateTime now = _clock();
      _stallStartedAt ??= now;
      if (now.difference(_stallStartedAt!) > playbackStallThreshold) {
        _closeOpenRange();
      }
      // Position does not advance across a stall, so nothing else to record.
      _lastPositionSecs = secs;
      return;
    }
    _stallStartedAt = null;

    final int? start = _openRangeStartSecs;
    if (start == null) {
      _openRangeStartSecs = secs;
      _lastPositionSecs = secs;
      return;
    }

    final int delta = secs - _lastPositionSecs;
    if (delta < 0 || delta > playbackSeekToleranceSecs) {
      // A seek. The range that was open ends where playback actually stopped,
      // and a fresh one opens at the destination — the jumped-over span is
      // never covered by either.
      _closeOpenRange();
      _openRangeStartSecs = secs;
    }

    _lastPositionSecs = secs;

    if (pendingCoverageSecs >= playbackFlushEverySecs) {
      flush();
    }
  }

  /// Called on pause, rate change, and any other range-closing event.
  void onPlaybackInterrupted() {
    if (_disposed) {
      return;
    }
    _closeOpenRange();
    flush();
  }

  /// Hands everything accumulated to the owner and starts a fresh range at the
  /// current position.
  ///
  /// Closing and reopening rather than emitting the open range in place is
  /// what keeps successive beats **non-overlapping**. Re-emitting the same
  /// seconds would still be *correct* — the server's union is idempotent — but
  /// the plan is explicit that a client never resends history: it wastes
  /// bandwidth and can trip the wall-clock clamp that truncates a beat
  /// claiming more coverage than has elapsed.
  void flush() {
    if (_disposed) {
      return;
    }
    final bool wasOpen = _openRangeStartSecs != null;
    _closeOpenRange();

    if (_pending.isEmpty) {
      return;
    }
    final List<WatchInterval> beat = mergeWatchIntervals(_pending);
    _pending.clear();

    if (wasOpen) {
      _openRangeStartSecs = _lastPositionSecs;
    }
    _onBeat(beat, position);
  }

  /// Final flush. The tracker accepts no further samples afterwards.
  void dispose() {
    if (_disposed) {
      return;
    }
    flush();
    _disposed = true;
    _openRangeStartSecs = null;
    _pending.clear();
  }

  void _closeOpenRange() {
    final int? start = _openRangeStartSecs;
    _openRangeStartSecs = null;
    if (start == null || _lastPositionSecs <= start) {
      return;
    }
    _pending.add(WatchInterval(start, _lastPositionSecs));
  }

  List<WatchInterval> _pendingIncludingOpenRange() {
    final int? start = _openRangeStartSecs;
    return <WatchInterval>[
      ..._pending,
      if (start != null && _lastPositionSecs > start)
        WatchInterval(start, _lastPositionSecs),
    ];
  }
}

/// Whether to offer the **"Resume from 6:52 · Start over"** chooser rather than
/// jumping silently (mobile plan §3).
///
/// Two conditions, both required. The positions must differ by more than
/// [resumeChooserThreshold], and the divergent position must have come from
/// *somewhere else* — a [LocalActivity] that has been synced. Below the
/// threshold, resuming silently is what the user expects; above it, a silent
/// jump is exactly what feels broken, because the cross-device case is the one
/// where the user did not put the playhead there.
const Duration resumeChooserThreshold = Duration(seconds: 10);

bool shouldOfferResumeChooser({
  required LocalActivity? cached,
  required Duration serverPosition,
}) {
  if (cached == null) {
    // Nothing local to disagree with. A server position is simply where the
    // user left off, wherever they left off.
    return serverPosition > resumeChooserThreshold;
  }
  final Duration localPosition = Duration(seconds: cached.positionSecs);
  final Duration difference = (serverPosition - localPosition).abs();
  return difference > resumeChooserThreshold && cached.isSynced;
}
