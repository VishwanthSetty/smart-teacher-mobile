import 'package:flutter/foundation.dart';

/// A closed range of video seconds that was **actually played**, never a
/// position and never a seek destination (mobile plan §3, backend plan §3.1).
///
/// The distinction is the whole point of the type. `positionSecs` says where to
/// resume and is moved freely by seeking; an interval says "these seconds
/// passed through the decoder". Only the latter counts toward completion, which
/// is what makes dragging the scrubber to the end contribute nothing.
@immutable
class WatchInterval {
  const WatchInterval(this.startSecs, this.endSecs);

  final int startSecs;
  final int endSecs;

  int get lengthSecs => endSecs - startSecs;

  bool get isEmpty => lengthSecs <= 0;

  /// The wire form the API expects: a bare two-element array, because
  /// `UpdateVideoProgressDto.intervals` is typed `number[][]`.
  List<int> toJson() => <int>[startSecs, endSecs];

  @override
  bool operator ==(Object other) =>
      other is WatchInterval &&
      other.startSecs == startSecs &&
      other.endSecs == endSecs;

  @override
  int get hashCode => Object.hash(startSecs, endSecs);

  @override
  String toString() => '[$startSecs, $endSecs]';
}

/// Seconds of slack within which two ranges are treated as one.
///
/// Matches the server's own 1s join tolerance. Without it, a beat boundary
/// landing mid-second leaves a one-second hole that no amount of rewatching
/// ever fills, and a video watched end to end stalls just under the completion
/// threshold.
const int watchIntervalJoinToleranceSecs = 1;

/// Unions [intervals] into a sorted, non-overlapping, minimal set.
///
/// Clamped to `[0, durationSecs]` when a duration is known. Deliberately the
/// same algorithm the server runs: the client merges only to keep the outbox
/// payload small, and the server merges again because it is the authority. A
/// client that skipped this would still be correct, only chattier — which is
/// why this must never *add* coverage the raw ranges didn't contain.
///
/// Union is commutative and idempotent, so replaying a queued beat that already
/// landed is safe. That is what lets the outbox retry without bookkeeping.
List<WatchInterval> mergeWatchIntervals(
  Iterable<WatchInterval> intervals, {
  int? durationSecs,
}) {
  final List<WatchInterval> clamped = <WatchInterval>[];
  for (final WatchInterval interval in intervals) {
    final int start = interval.startSecs < 0 ? 0 : interval.startSecs;
    final int end = durationSecs != null && interval.endSecs > durationSecs
        ? durationSecs
        : interval.endSecs;
    if (end > start) {
      clamped.add(WatchInterval(start, end));
    }
  }
  if (clamped.isEmpty) {
    return const <WatchInterval>[];
  }

  clamped.sort((WatchInterval a, WatchInterval b) {
    final int byStart = a.startSecs.compareTo(b.startSecs);
    return byStart != 0 ? byStart : a.endSecs.compareTo(b.endSecs);
  });

  final List<WatchInterval> merged = <WatchInterval>[clamped.first];
  for (final WatchInterval interval in clamped.skip(1)) {
    final WatchInterval last = merged.last;
    if (interval.startSecs <= last.endSecs + watchIntervalJoinToleranceSecs) {
      if (interval.endSecs > last.endSecs) {
        merged[merged.length - 1] = WatchInterval(
          last.startSecs,
          interval.endSecs,
        );
      }
    } else {
      merged.add(interval);
    }
  }
  return List<WatchInterval>.unmodifiable(merged);
}

/// Total seconds covered by [intervals], which must already be merged.
///
/// Summing unmerged ranges double-counts the overlap, so this always runs on
/// the output of [mergeWatchIntervals] rather than on raw capture.
int coveredSeconds(Iterable<WatchInterval> intervals) => intervals.fold<int>(
  0,
  (int total, WatchInterval interval) => total + interval.lengthSecs,
);

/// Parses the `watchedIntervals` JSON the API stores and returns.
///
/// Tolerant by design: the column is free-form `Json` server-side, and one
/// malformed pair must not fail a whole history row. A bad entry is dropped,
/// not thrown on.
List<WatchInterval> parseWatchIntervals(dynamic value) {
  if (value is! List<dynamic>) {
    return const <WatchInterval>[];
  }
  final List<WatchInterval> parsed = <WatchInterval>[];
  for (final dynamic entry in value) {
    if (entry is! List<dynamic> || entry.length != 2) {
      continue;
    }
    final int? start = _asSeconds(entry[0]);
    final int? end = _asSeconds(entry[1]);
    if (start != null && end != null && end > start) {
      parsed.add(WatchInterval(start, end));
    }
  }
  return mergeWatchIntervals(parsed);
}

int? _asSeconds(dynamic value) => switch (value) {
  final int seconds => seconds,
  final double seconds when seconds.isFinite => seconds.floor(),
  final String text => int.tryParse(text),
  _ => null,
};
