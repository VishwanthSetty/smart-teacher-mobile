import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/sync/activity_cache_store.dart';
import 'package:smart_teacher_mobile/src/core/sync/local_activity.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_entry.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_worker.dart';
import 'package:smart_teacher_mobile/src/core/sync/watch_interval.dart';
import 'package:smart_teacher_mobile/src/features/activity/data/progress_outbox_transport.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/activity_sync_controller.dart';

import '../../support/fake_progress_repository.dart';

/// Lets the fire-and-forget flush that every write kicks off actually run.
///
/// [ActivitySyncController] deliberately does not await its own flush — a beat
/// is durable in the outbox the moment it is enqueued, and blocking playback
/// on the round trip would trade the thing that matters for the thing that
/// doesn't. Tests therefore have to drain the microtask queue before asserting
/// on what reached the network.
Future<void> settle() async {
  for (int turn = 0; turn < 8; turn++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late InMemoryOutboxStore outbox;
  late InMemoryActivityCacheStore cache;
  late FakeProgressRepository progress;

  /// The clock both the controller and the worker read.
  ///
  /// Shared and movable, because a failed write is parked behind an
  /// exponential backoff gate — a test that wants to see the retry has to let
  /// that window pass, and waiting two real seconds for it would be a slow
  /// test that still raced.
  late DateTime now;

  ActivitySyncController build() {
    outbox = InMemoryOutboxStore();
    cache = InMemoryActivityCacheStore();
    progress = FakeProgressRepository();
    now = DateTime(2026, 9, 11, 10);
    return ActivitySyncController(
      outbox: outbox,
      cache: cache,
      worker: OutboxWorker(
        store: outbox,
        transport: ProgressOutboxTransport(progress),
        sink: ActivityCacheSyncSink(cache),
        clock: () => now,
      ),
      clock: () => now,
    );
  }

  group('video beats', () {
    test('stamps clientUpdatedAt at the action, not at send time', () async {
      // The server resolves positionSecs by last-write-wins on this field. A
      // timestamp taken when the queue happened to drain would make an
      // hour-old beat look newer than a fresh one from another device.
      final ActivitySyncController controller = build();
      final DateTime action = now;

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(0, 15)],
        position: const Duration(seconds: 15),
      );
      await settle();

      expect(progress.calls.single.clientUpdatedAt, action);
    });

    test('sends the intervals it was given, merged', () async {
      final ActivitySyncController controller = build();

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[
          WatchInterval(0, 15),
          WatchInterval(14, 30),
        ],
        position: const Duration(seconds: 30),
      );
      await settle();

      expect(progress.calls.single.intervals, const <WatchInterval>[
        WatchInterval(0, 30),
      ]);
      expect(progress.calls.single.positionSecs, 30);
    });

    test('writes the cache optimistically before the network answers', () async {
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(0, 15)],
        position: const Duration(seconds: 15),
        title: 'Photosynthesis',
      );

      final LocalActivity? cached = await cache.read('video-1');
      expect(cached, isNotNull);
      expect(cached!.positionSecs, 15);
      expect(cached.title, 'Photosynthesis');
      // Unsynced, because nothing has confirmed it — which is what keeps the
      // resume chooser from treating this device's own write as a
      // cross-device fact.
      expect(cached.isSynced, isFalse);
    });

    test('never invents a percent or a status of its own', () async {
      // Completion is unique coverage against a *server*-configured threshold.
      // A client that guessed would eventually disagree with the badge the
      // server renders.
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(0, 600)],
        position: const Duration(seconds: 600),
        durationSecs: 600,
      );

      final LocalActivity cached = (await cache.read('video-1'))!;
      expect(cached.percent, 0);
      expect(cached.status, 'IN_PROGRESS');
    });

    test('the server response overwrites the optimistic row', () async {
      final ActivitySyncController controller = build();
      progress.activity = buildActivity(
        videoId: 'video-1',
        status: ActivityProgressStatus.completed,
        percent: 95,
      );

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(0, 600)],
        position: const Duration(seconds: 600),
      );
      await settle();

      final LocalActivity cached = (await cache.read('video-1'))!;
      expect(cached.status, 'COMPLETED');
      expect(cached.percent, 95);
      expect(cached.isSynced, isTrue);
    });

    test('a beat with no video id is dropped rather than queued', () async {
      final ActivitySyncController controller = build();

      await controller.recordVideoBeat(
        videoId: '',
        intervals: const <WatchInterval>[WatchInterval(0, 15)],
        position: const Duration(seconds: 15),
      );

      expect(await outbox.pendingEntries(), isEmpty);
      expect(progress.calls, isEmpty);
    });

    test('two beats while offline collapse into one request', () async {
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(0, 15)],
        position: const Duration(seconds: 15),
      );
      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(15, 30)],
        position: const Duration(seconds: 30),
      );
      await settle();

      expect(await outbox.pendingEntries(), hasLength(1));

      progress.error = null;
      progress.calls.clear();
      // Past the backoff window the failed beat is parked behind.
      now = now.add(const Duration(minutes: 1));
      await controller.flush();

      expect(progress.calls, hasLength(1));
      expect(progress.calls.single.intervals, const <WatchInterval>[
        WatchInterval(0, 30),
      ]);
    });
  });

  group('documents', () {
    test('a page report never completes the document', () async {
      // Opening a PDF is not reading it.
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.recordDocumentPage(
        documentId: 'doc-1',
        lastPage: 24,
        pageCount: 24,
      );

      final LocalActivity cached = (await cache.read('doc-1'))!;
      expect(cached.status, 'IN_PROGRESS');
      expect(cached.lastPage, 24);
    });

    test('page 0 is dropped — the DTO is @Min(1)', () async {
      final ActivitySyncController controller = build();
      await controller.recordDocumentPage(documentId: 'doc-1', lastPage: 0);
      expect(await outbox.pendingEntries(), isEmpty);
    });

    test('marking complete is what sets COMPLETED, optimistically', () async {
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.setDocumentComplete(
        documentId: 'doc-1',
        isComplete: true,
      );

      final LocalActivity cached = (await cache.read('doc-1'))!;
      expect(cached.status, 'COMPLETED');
      expect(cached.completedAt, isNotNull);
    });

    test('un-marking clears it again', () async {
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.setDocumentComplete(
        documentId: 'doc-1',
        isComplete: true,
      );
      await controller.setDocumentComplete(
        documentId: 'doc-1',
        isComplete: false,
      );

      final LocalActivity cached = (await cache.read('doc-1'))!;
      expect(cached.status, 'IN_PROGRESS');
      expect(cached.completedAt, isNull);
      // And the two cancel down to a single pending write.
      expect(await outbox.pendingEntries(), hasLength(1));
      expect(
        (await outbox.pendingEntries()).single.kind,
        OutboxKind.documentUncomplete,
      );
    });

    test('marking complete hits the complete endpoint, not the page one', () async {
      final ActivitySyncController controller = build();

      await controller.setDocumentComplete(
        documentId: 'doc-1',
        isComplete: true,
      );
      await settle();

      expect(progress.calls.single.kind, 'docComplete');
      expect(progress.calls.single.resourceId, 'doc-1');
    });
  });

  group('sign-out', () {
    test('drops the cache and the queue', () async {
      // Carrying either into the next session would show one user another's
      // history, or replay their beats under the new account's token.
      final ActivitySyncController controller = build();
      progress.error = const NetworkError(message: 'Offline');

      await controller.recordVideoBeat(
        videoId: 'video-1',
        intervals: const <WatchInterval>[WatchInterval(0, 15)],
        position: const Duration(seconds: 15),
      );
      await settle();
      expect(await outbox.pendingEntries(), isNotEmpty);

      await controller.clearForSignOut();

      expect(await outbox.pendingEntries(), isEmpty);
      expect(await cache.read('video-1'), isNull);
    });
  });
}
