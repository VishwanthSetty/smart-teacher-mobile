import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/local_activity.dart';
import 'package:smart_teacher_mobile/src/core/sync/playback_tracker.dart';
import 'package:smart_teacher_mobile/src/core/sync/watch_interval.dart';

void main() {
  group('mergeWatchIntervals', () {
    test('unions overlapping ranges', () {
      expect(
        mergeWatchIntervals(const <WatchInterval>[
          WatchInterval(0, 30),
          WatchInterval(20, 50),
        ]),
        const <WatchInterval>[WatchInterval(0, 50)],
      );
    });

    test('joins ranges within the 1s tolerance', () {
      // Without this, a beat boundary landing mid-second leaves a hole no
      // amount of rewatching ever fills, and a video watched end to end stalls
      // just under the completion threshold.
      expect(
        mergeWatchIntervals(const <WatchInterval>[
          WatchInterval(0, 30),
          WatchInterval(31, 60),
        ]),
        const <WatchInterval>[WatchInterval(0, 60)],
      );
    });

    test('keeps a genuine gap apart', () {
      expect(
        mergeWatchIntervals(const <WatchInterval>[
          WatchInterval(0, 30),
          WatchInterval(120, 150),
        ]),
        const <WatchInterval>[WatchInterval(0, 30), WatchInterval(120, 150)],
      );
    });

    test('is idempotent under replay', () {
      // This is what makes the outbox safe to retry: a queued beat that
      // already landed can be replayed without inflating coverage.
      const List<WatchInterval> once = <WatchInterval>[
        WatchInterval(0, 30),
        WatchInterval(40, 60),
      ];
      final List<WatchInterval> merged = mergeWatchIntervals(once);
      expect(mergeWatchIntervals(<WatchInterval>[...merged, ...once]), merged);
    });

    test('is commutative, so two devices need no ordering guarantee', () {
      const WatchInterval a = WatchInterval(0, 30);
      const WatchInterval b = WatchInterval(25, 60);
      expect(
        mergeWatchIntervals(const <WatchInterval>[a, b]),
        mergeWatchIntervals(const <WatchInterval>[b, a]),
      );
    });

    test('clamps to the duration and drops empty ranges', () {
      expect(
        mergeWatchIntervals(const <WatchInterval>[
          WatchInterval(-10, 20),
          WatchInterval(50, 50),
          WatchInterval(90, 200),
        ], durationSecs: 100),
        const <WatchInterval>[WatchInterval(0, 20), WatchInterval(90, 100)],
      );
    });

    test('coveredSeconds does not double-count an overlap', () {
      expect(
        coveredSeconds(
          mergeWatchIntervals(const <WatchInterval>[
            WatchInterval(0, 30),
            WatchInterval(10, 40),
          ]),
        ),
        40,
      );
    });
  });

  group('parseWatchIntervals', () {
    test('reads the stored JSON shape', () {
      expect(
        parseWatchIntervals(<dynamic>[
          <dynamic>[0, 30],
          <dynamic>[40, 60],
        ]),
        const <WatchInterval>[WatchInterval(0, 30), WatchInterval(40, 60)],
      );
    });

    test('drops malformed entries instead of throwing', () {
      // The column is free-form JSON server-side; one bad pair must not fail a
      // whole history row.
      expect(
        parseWatchIntervals(<dynamic>[
          <dynamic>[0, 30],
          <dynamic>[1],
          'nonsense',
          <dynamic>[60, 40],
        ]),
        const <WatchInterval>[WatchInterval(0, 30)],
      );
    });

    test('a non-list is empty, not an error', () {
      expect(parseWatchIntervals(null), isEmpty);
      expect(parseWatchIntervals(42), isEmpty);
    });
  });

  group('PlaybackTracker', () {
    test('accumulates a contiguous range and flushes at the cadence', () {
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 0; second <= playbackFlushEverySecs; second++) {
        _play(tracker, second);
      }

      expect(beats, hasLength(1));
      expect(beats.single, const <WatchInterval>[WatchInterval(0, 15)]);
    });

    test('a seek contributes no interval for the span jumped over', () {
      // The rule the whole design turns on: seeking to the end cannot complete
      // a video, because only played ranges count.
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 0; second <= 5; second++) {
        _play(tracker, second);
      }
      // Scrub to the end of a long video.
      _play(tracker, 900);
      _play(tracker, 901);
      tracker.dispose();

      final List<WatchInterval> emitted = beats.expand(
        (List<WatchInterval> beat) => beat,
      ).toList();
      expect(emitted, const <WatchInterval>[
        WatchInterval(0, 5),
        WatchInterval(900, 901),
      ]);
      // Six seconds of real playback, not nine hundred.
      expect(coveredSeconds(mergeWatchIntervals(emitted)), 6);
    });

    test('a backwards seek opens a new range rather than a negative one', () {
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 100; second <= 105; second++) {
        _play(tracker, second);
      }
      _play(tracker, 10);
      _play(tracker, 11);
      tracker.dispose();

      final List<WatchInterval> emitted = beats.expand(
        (List<WatchInterval> beat) => beat,
      ).toList();
      expect(emitted, const <WatchInterval>[
        WatchInterval(10, 11),
        WatchInterval(100, 105),
      ]);
    });

    test('pausing closes the range and flushes immediately', () {
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 0; second <= 4; second++) {
        _play(tracker, second);
      }
      expect(beats, isEmpty, reason: 'four seconds is under the cadence');

      tracker.onPlaybackInterrupted();
      expect(beats.single, const <WatchInterval>[WatchInterval(0, 4)]);
    });

    test('successive beats do not overlap', () {
      // The client never resends history: the server merges, and re-sending
      // wastes bandwidth and risks the wall-clock clamp.
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 0; second <= 2 * playbackFlushEverySecs; second++) {
        _play(tracker, second);
      }

      expect(beats, hasLength(2));
      expect(beats.first, const <WatchInterval>[WatchInterval(0, 15)]);
      expect(beats.last, const <WatchInterval>[WatchInterval(15, 30)]);
    });

    test('emits nothing at all when playback never advances', () {
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int tick = 0; tick < 20; tick++) {
        _play(tracker, 0);
      }
      tracker.dispose();

      expect(beats, isEmpty);
    });

    test('a paused player records nothing', () {
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 0; second <= 30; second++) {
        tracker.onSample(
          position: Duration(seconds: second),
          isPlaying: false,
          isBuffering: false,
        );
      }
      tracker.dispose();

      expect(beats, isEmpty);
    });

    test('dispose performs the final flush, then accepts nothing more', () {
      final List<List<WatchInterval>> beats = <List<WatchInterval>>[];
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> intervals, Duration _) =>
            beats.add(intervals),
      );

      for (int second = 0; second <= 3; second++) {
        _play(tracker, second);
      }
      tracker.dispose();
      expect(beats.single, const <WatchInterval>[WatchInterval(0, 3)]);

      _play(tracker, 4);
      tracker.flush();
      expect(beats, hasLength(1));
    });

    test('reports the latest position for the resume write', () {
      final PlaybackTracker tracker = PlaybackTracker(
        onBeat: (List<WatchInterval> _, Duration _) {},
      );
      _play(tracker, 0);
      _play(tracker, 42);
      expect(tracker.position, const Duration(seconds: 42));
    });
  });

  group('shouldOfferResumeChooser', () {
    test('offers the chooser past the threshold when the row is synced', () {
      expect(
        shouldOfferResumeChooser(
          cached: _cached(positionSecs: 10, synced: true),
          serverPosition: const Duration(seconds: 400),
        ),
        isTrue,
      );
    });

    test('stays silent within ten seconds', () {
      expect(
        shouldOfferResumeChooser(
          cached: _cached(positionSecs: 400, synced: true),
          serverPosition: const Duration(seconds: 405),
        ),
        isFalse,
      );
    });

    test('stays silent for a position this device set but never synced', () {
      // An unsynced row is *this* device's own optimistic write. The user put
      // the playhead there themselves, so there is nothing to ask about.
      expect(
        shouldOfferResumeChooser(
          cached: _cached(positionSecs: 10, synced: false),
          serverPosition: const Duration(seconds: 400),
        ),
        isFalse,
      );
    });

    test('offers the chooser when there is no local row at all', () {
      expect(
        shouldOfferResumeChooser(
          cached: null,
          serverPosition: const Duration(seconds: 400),
        ),
        isTrue,
      );
      expect(
        shouldOfferResumeChooser(
          cached: null,
          serverPosition: const Duration(seconds: 3),
        ),
        isFalse,
      );
    });
  });
}

/// One playing, non-buffering sample at [second].
void _play(PlaybackTracker tracker, int second) => tracker.onSample(
  position: Duration(seconds: second),
  isPlaying: true,
  isBuffering: false,
);

LocalActivity _cached({required int positionSecs, required bool synced}) =>
    LocalActivity(
      resourceId: 'video-1',
      resourceType: 'VIDEO',
      status: 'IN_PROGRESS',
      lastAccessedAt: DateTime(2026, 9, 11),
      positionSecs: positionSecs,
      serverUpdatedAt: synced ? DateTime(2026, 9, 11) : null,
    );
