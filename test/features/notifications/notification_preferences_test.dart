import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/notifications/domain/notification_entity.dart';
import 'package:smart_teacher_mobile/src/features/notifications/domain/push_token_source.dart';
import 'package:smart_teacher_mobile/src/features/notifications/presentation/notification_preferences_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_notification_repository.dart';

void main() {
  group('notification preferences (mobile plan §5.10)', () {
    testWidgets('renders the server\'s values, defaults included', (
      WidgetTester tester,
    ) async {
      // The server answers with a defaulted object for a user who never saved
      // one, so there is no "unset" state to render.
      await _pump(tester, FakeNotificationRepository());

      expect(find.text('In-app notifications'), findsOneWidget);
      expect(find.text('Push at any time'), findsOneWidget);
      // The 1440-minute default, as one of the four choices that mean
      // something rather than a slider over 0–10080.
      final ChoiceChip day = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '1 day'),
      );
      expect(day.selected, isTrue);
    });

    testWidgets('a toggle sends only the field it changed', (
      WidgetTester tester,
    ) async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      await _pump(tester, repository);

      await tester.tap(find.text('Task reminders'));
      await tester.pumpAndSettle();

      expect(repository.preferenceWrites, hasLength(1));
      expect(repository.preferenceWrites.single.taskRemindersEnabled, isFalse);
      // Everything else is absent from the body rather than sent as null, which
      // the DTO would reject.
      expect(repository.preferenceWrites.single.inAppEnabled, isNull);
      expect(repository.preferenceWrites.single.pushEnabled, isNull);
    });

    testWidgets('turning quiet hours on sends both bounds', (
      WidgetTester tester,
    ) async {
      // The API answers `400` for exactly one of the pair, so "on" has to mean
      // something the moment it is switched.
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      await _pump(tester, repository);

      await tester.tap(find.text('Quiet hours'));
      await tester.pumpAndSettle();

      final write = repository.preferenceWrites.single;
      expect(write.quietFromMins, isNotNull);
      expect(write.quietToMins, isNotNull);
      expect(write.clearQuietHours, isFalse);
    });

    testWidgets('turning quiet hours off clears both together', (
      WidgetTester tester,
    ) async {
      final FakeNotificationRepository repository = FakeNotificationRepository(
        preferences: const NotificationPreferenceEntity(
          quietFromMins: 1320,
          quietToMins: 420,
        ),
      );
      await _pump(tester, repository);

      expect(find.text('No push between 22:00 and 07:00 UTC'), findsOneWidget);

      await tester.tap(find.text('Quiet hours'));
      await tester.pumpAndSettle();

      expect(repository.preferenceWrites.single.clearQuietHours, isTrue);
    });

    testWidgets('changing the lead time sends its minutes', (
      WidgetTester tester,
    ) async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      await _pump(tester, repository);

      await tester.tap(find.widgetWithText(ChoiceChip, '3 hours'));
      await tester.pumpAndSettle();

      expect(repository.preferenceWrites.single.dueSoonLeadMins, 180);
    });

    testWidgets(
      'the push toggle is disabled and explained with no provider wired',
      (WidgetTester tester) async {
        // §5.10: present it plainly rather than nagging. This build has no FCM
        // SDK, which is the same fact a denied permission produces — and the
        // inbox works either way.
        await _pump(tester, FakeNotificationRepository());

        expect(
          find.textContaining('Push is not available on this device'),
          findsOneWidget,
        );
        final SwitchListTile push = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Push notifications'),
        );
        expect(push.onChanged, isNull);
      },
    );

    testWidgets('the push toggle works when a provider is configured', (
      WidgetTester tester,
    ) async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      await _pump(
        tester,
        repository,
        extraOverrides: <Override>[
          pushTokenSourceProvider.overrideWithValue(FakePushTokenSource()),
        ],
      );

      await tester.tap(find.text('Push notifications'));
      await tester.pumpAndSettle();

      expect(repository.preferenceWrites.single.pushEnabled, isFalse);
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeNotificationRepository repository, {
  List<Override> extraOverrides = const <Override>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        ...activityOverrides(notifications: repository),
        ...extraOverrides,
      ],
      child: const MaterialApp(home: NotificationPreferencesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}
