import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/sync/local_activity.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_entry.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_worker.dart';
import 'package:smart_teacher_mobile/src/features/notifications/data/notification_outbox_transport.dart';

import '../../support/fake_notification_repository.dart';

void main() {
  group('notification read coalescing (mobile plan §2.2)', () {
    test('the same notification read twice is one request', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(_read('notification-1', at: DateTime(2026, 9, 12, 9)));
      await store.enqueue(
        _read('notification-1', at: DateTime(2026, 9, 12, 9, 5)),
      );

      // The plan's coalescing rule for this kind is "dedupe", which the merge
      // key gives for free.
      final List<OutboxEntry> pending = await store.pendingEntries();
      expect(pending, hasLength(1));
      expect(pending.single.kind, OutboxKind.notificationRead);
    });

    test('the first read time is kept, not the second', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      final DateTime first = DateTime(2026, 9, 12, 9);

      await store.enqueue(_read('notification-1', at: first));
      await store.enqueue(
        _read('notification-1', at: DateTime(2026, 9, 12, 9, 5)),
      );

      // When the user actually read it, which is what the stamp means — and the
      // reason it is taken at the tap rather than at send time in the first
      // place.
      final List<OutboxEntry> pending = await store.pendingEntries();
      expect(pending.single.clientUpdatedAt, first);
    });

    test('reads of different notifications do not coalesce', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(_read('notification-1'));
      await store.enqueue(_read('notification-2'));

      expect(await store.pendingEntries(), hasLength(2));
    });

    test('a read carries no body — it is a bare POST', () {
      // An empty map would send `{}` and invite a validation pipe to have an
      // opinion about it.
      expect(_read('notification-1').toRequestBody(), isNull);
    });
  });

  group('notification transport', () {
    test('sends the notification id, and caches nothing', () async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final NotificationOutboxTransport transport =
          NotificationOutboxTransport(repository);

      final LocalActivity? synced = await transport.send(
        _read('notification-7'),
      );

      expect(repository.readIds, <String>['notification-7']);
      // Reading an alert about a video does not change how far through it you
      // are, so there is nothing for the worker's cache sink to reconcile.
      expect(synced, isNull);
    });

    test('refuses a kind it does not own', () async {
      final NotificationOutboxTransport transport =
          NotificationOutboxTransport(FakeNotificationRepository());

      // Reaching this is a wiring bug in the composite's routing table, not a
      // bad payload — so it throws rather than silently succeeding.
      expect(
        () => transport.send(
          OutboxEntry(
            id: 'entry',
            target: const OutboxTarget(
              kind: OutboxKind.videoProgress,
              resourceId: 'video-1',
            ),
            clientUpdatedAt: DateTime(2026, 9, 12),
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('a 404 is discarded rather than retried forever', () async {
      // The notification's row is gone, or belonged to a session that has
      // ended. Replaying it would wedge the queue behind an entry that can only
      // fail.
      final FakeNotificationRepository repository = FakeNotificationRepository(
        error: const NotFoundError(message: 'Notification not found'),
      );
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      await store.enqueue(_read('notification-1'));

      final OutboxWorker worker = OutboxWorker(
        store: store,
        transport: NotificationOutboxTransport(repository),
      );
      final OutboxFlushReport report = await worker.flush();

      expect(report.discarded, 1);
      expect(await store.pendingEntries(), isEmpty);
    });
  });
}

OutboxEntry _read(String id, {DateTime? at}) => OutboxEntry(
  id: 'entry-$id',
  target: OutboxTarget(kind: OutboxKind.notificationRead, resourceId: id),
  clientUpdatedAt: at ?? DateTime(2026, 9, 12, 9),
);
