import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/features/notifications/domain/notification_entity.dart';
import 'package:smart_teacher_mobile/src/features/notifications/presentation/notification_inbox_screen.dart';
import 'package:smart_teacher_mobile/src/features/notifications/presentation/notifications_controller.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_notification_repository.dart';

void main() {
  group('notification inbox (mobile plan §5.10)', () {
    testWidgets('renders unread rows with a dot', (WidgetTester tester) async {
      await _pump(
        tester,
        FakeNotificationRepository(
          notifications: <NotificationEntity>[
            buildNotification(id: 'n1', title: 'New task'),
            buildNotification(
              id: 'n2',
              title: 'Task reminder',
              readAt: DateTime(2026, 9, 11),
            ),
          ],
        ),
      );

      expect(find.text('New task'), findsOneWidget);
      expect(find.text('Task reminder'), findsOneWidget);
      // One dot, for the one unread row.
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('an empty inbox is a designed state, not an error', (
      WidgetTester tester,
    ) async {
      await _pump(tester, FakeNotificationRepository());

      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('a row with a blank title still names itself', (
      WidgetTester tester,
    ) async {
      // A malformed row would otherwise render as an untappable empty tile.
      await _pump(
        tester,
        FakeNotificationRepository(
          notifications: <NotificationEntity>[
            buildNotification(title: '  ', type: NotificationKind.taskDueSoon),
          ],
        ),
      );

      expect(find.text('Task due soon'), findsOneWidget);
    });

    testWidgets('tapping a row marks it read through the outbox', (
      WidgetTester tester,
    ) async {
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      final FakeNotificationRepository repository = FakeNotificationRepository(
        notifications: <NotificationEntity>[
          buildNotification(id: 'n1', title: 'New task', taskId: null),
        ],
      );
      await _pump(tester, repository, outbox: outbox);

      await tester.tap(find.text('New task'));
      await tester.pumpAndSettle();

      // The flush really drains in a widget test, so the queue is empty
      // afterwards and the fake's argument log — not the queue — is what proves
      // the write happened.
      expect(repository.readIds, <String>['n1']);
      expect(await outbox.pendingEntries(), isEmpty);
      // And the dot is gone optimistically, under the finger.
      expect(find.byIcon(Icons.circle), findsNothing);
    });

    testWidgets('a second tap on a read row queues nothing', (
      WidgetTester tester,
    ) async {
      // The endpoint is idempotent, but a queued entry that changes nothing is
      // still a request, and the badge would not move either way.
      final FakeNotificationRepository repository = FakeNotificationRepository(
        notifications: <NotificationEntity>[
          buildNotification(id: 'n1', title: 'New task', taskId: null),
        ],
      );
      await _pump(tester, repository);

      await tester.tap(find.text('New task'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New task'));
      await tester.pumpAndSettle();

      expect(repository.readIds, <String>['n1']);
    });

    testWidgets('mark all read reports how many it changed', (
      WidgetTester tester,
    ) async {
      final FakeNotificationRepository repository = FakeNotificationRepository(
        notifications: <NotificationEntity>[
          buildNotification(id: 'n1'),
          buildNotification(id: 'n2'),
          buildNotification(id: 'n3', readAt: DateTime(2026, 9, 11)),
        ],
      );
      await _pump(tester, repository);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(repository.readAllCalls, 1);
      expect(find.text('2 notifications marked read.'), findsOneWidget);
      // Bulk, so it is awaited and reported rather than queued: one entry
      // standing for an unknown number of rows could not be coalesced honestly.
      expect(find.text('Mark all read'), findsNothing);
    });
  });

  group('unread badge', () {
    test('counts only unread rows, and answers 0 while loading', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: activityOverrides(
          notifications: FakeNotificationRepository(
            notifications: <NotificationEntity>[
              buildNotification(id: 'n1'),
              buildNotification(id: 'n2'),
              buildNotification(id: 'n3', readAt: DateTime(2026, 9, 11)),
            ],
          ),
        ),
      );
      addTearDown(container.dispose);
      // A standing listener, or the controller is torn down the instant an
      // await yields.
      container.listen(
        notificationsControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      // A badge is an invitation; one drawn from a guess would flicker.
      expect(unreadNotificationCount(container.read(notificationsControllerProvider)), 0);

      await container.read(notificationsControllerProvider.future);

      expect(unreadNotificationCount(container.read(notificationsControllerProvider)), 2);
    });

    test('marking read moves the badge without a refetch', () async {
      final FakeNotificationRepository repository = FakeNotificationRepository(
        notifications: <NotificationEntity>[buildNotification(id: 'n1')],
      );
      final ProviderContainer container = ProviderContainer(
        overrides: activityOverrides(notifications: repository),
      );
      addTearDown(container.dispose);
      container.listen(
        notificationsControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await container.read(notificationsControllerProvider.future);

      expect(unreadNotificationCount(container.read(notificationsControllerProvider)), 1);

      await container
          .read(notificationsControllerProvider.notifier)
          .markRead('n1');

      expect(unreadNotificationCount(container.read(notificationsControllerProvider)), 0);
    });
  });

  group('paging', () {
    test('a full page is assumed to have another behind it', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: activityOverrides(
          notifications: FakeNotificationRepository(
            notifications: <NotificationEntity>[
              for (int i = 0; i < 30; i++) buildNotification(id: 'n$i'),
            ],
          ),
        ),
      );
      addTearDown(container.dispose);
      container.listen(
        notificationsControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await container.read(notificationsControllerProvider.future);
      // The server hardcodes `take: 21` and accepts no limit, so that is the
      // number a short page is measured against.
      expect(container.read(notificationsControllerProvider).value!.items, hasLength(21));
      expect(container.read(notificationsControllerProvider).value!.hasMore, isTrue);

      await container.read(notificationsControllerProvider.notifier).loadMore();

      // Asserted through the controller rather than by finding row text: a
      // ListView disposes rows scrolled far off screen.
      expect(container.read(notificationsControllerProvider).value!.items, hasLength(30));
      expect(container.read(notificationsControllerProvider).value!.hasMore, isFalse);
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeNotificationRepository repository, {
  InMemoryOutboxStore? outbox,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        notifications: repository,
        outbox: outbox,
      ),
      child: const MaterialApp(home: NotificationInboxScreen()),
    ),
  );
  await tester.pumpAndSettle();
}
