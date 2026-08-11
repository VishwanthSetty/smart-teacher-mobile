import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/current_user_controller.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_screen.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('profile screen (PRD §5.2)', () {
    testWidgets('shows name, email, role badge and school name',
        (WidgetTester tester) async {
      await _pumpProfile(
        tester,
        profile: FakeProfileRepository(
          user: buildMe(
            name: 'Asha Rao',
            email: 'asha@springfield.edu',
            role: UserRole.teacher,
          ),
        ),
      );

      expect(find.text('Asha Rao'), findsOneWidget);
      expect(find.text('asha@springfield.edu'), findsWidgets);
      expect(find.text('Teacher'), findsOneWidget);
      expect(find.text('Springfield High'), findsOneWidget);
    });

    testWidgets('renders the student role for a student',
        (WidgetTester tester) async {
      await _pumpProfile(
        tester,
        profile: FakeProfileRepository(user: buildMe(role: UserRole.student)),
      );

      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Teacher'), findsNothing);
    });

    testWidgets('serves the profile login already fetched, without refetching',
        (WidgetTester tester) async {
      final FakeProfileRepository profile = FakeProfileRepository(
        user: buildMe(name: 'Cached User'),
      );
      final ProviderContainer container = await _pumpProfile(
        tester,
        profile: profile,
        // Exactly what login leaves behind: the actor already in hand.
        cachedUser: buildMe(name: 'Cached User'),
      );

      expect(find.text('Cached User'), findsOneWidget);
      expect(profile.callCount, 0);
      expect(container.read(currentUserProvider)?.name, 'Cached User');
    });

    testWidgets('fetches when nothing is cached (a restored session)',
        (WidgetTester tester) async {
      final FakeProfileRepository profile = FakeProfileRepository(
        user: buildMe(name: 'Restored User'),
      );
      final ProviderContainer container =
          await _pumpProfile(tester, profile: profile);

      expect(profile.callCount, 1);
      expect(find.text('Restored User'), findsOneWidget);
      // What it fetched becomes the app-wide actor, so the shell (§5.7) and
      // this screen can never disagree about the role.
      expect(container.read(currentUserProvider)?.name, 'Restored User');
    });

    testWidgets('pull-to-refresh refetches and repaints',
        (WidgetTester tester) async {
      final FakeProfileRepository profile = FakeProfileRepository(
        user: buildMe(name: 'Old Name'),
      );
      final ProviderContainer container = await _pumpProfile(
        tester,
        profile: profile,
        cachedUser: buildMe(name: 'Old Name'),
      );

      profile.user = buildMe(name: 'New Name');
      await _pullToRefresh(tester);

      expect(profile.callCount, 1);
      expect(find.text('New Name'), findsOneWidget);
      expect(find.text('Old Name'), findsNothing);
      expect(container.read(currentUserProvider)?.name, 'New Name');
    });

    testWidgets('a failed load offers a retry', (WidgetTester tester) async {
      final FakeProfileRepository profile = FakeProfileRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _pumpProfile(tester, profile: profile);

      expect(find.text('Could not reach the server.'), findsOneWidget);

      profile.error = null;
      profile.user = buildMe(name: 'Back Online');
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Back Online'), findsOneWidget);
    });

    testWidgets('signs out from here', (WidgetTester tester) async {
      final ProviderContainer container = await _pumpProfile(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('suspended school (PRD §5.2)', () {
    testWidgets('a SUSPENDED school status replaces the screen',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpProfile(
        tester,
        profile: FakeProfileRepository(
          user: buildMe(schoolStatus: SchoolStatus.suspended),
        ),
      );

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.text('Access suspended'), findsOneWidget);
      expect(find.textContaining('Springfield High'), findsOneWidget);
      // Latched app-wide, not just locally — every other screen reads this.
      expect(container.read(schoolSuspensionProvider), isTrue);
    });

    testWidgets('a suspended 403 on /users/me replaces the screen too',
        (WidgetTester tester) async {
      await _pumpProfile(
        tester,
        profile: FakeProfileRepository(
          error: const ForbiddenError(
            message: "Your school's access is suspended.",
            isSchoolSuspended: true,
          ),
        ),
      );

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      // The generic error state, with its pointless retry, is not shown.
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('a plain 403 gets the ordinary error state',
        (WidgetTester tester) async {
      await _pumpProfile(
        tester,
        profile: FakeProfileRepository(
          error: const ForbiddenError(message: "You don't have access."),
        ),
      );

      expect(find.byType(SchoolSuspendedView), findsNothing);
      expect(find.text("You don't have access."), findsOneWidget);
    });

    testWidgets('the repeated-403 pattern takes over an already loaded screen',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpProfile(tester);
      expect(find.byType(SchoolSuspendedView), findsNothing);

      // Two suspension-flavoured 403s from calls elsewhere in the app — what
      // the interceptor reports as the school goes suspended mid-session.
      final SchoolSuspensionController suspension =
          container.read(schoolSuspensionProvider.notifier);
      suspension.reportSuspendedForbidden();
      await tester.pumpAndSettle();
      expect(find.byType(SchoolSuspendedView), findsNothing);

      suspension.reportSuspendedForbidden();
      await tester.pumpAndSettle();
      expect(find.byType(SchoolSuspendedView), findsOneWidget);
    });

    testWidgets('sign-out is reachable from the suspended screen',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpProfile(
        tester,
        profile: FakeProfileRepository(
          user: buildMe(schoolStatus: SchoolStatus.suspended),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      // The flag clears with the session, so the next user starts clean.
      expect(container.read(schoolSuspensionProvider), isFalse);
    });
  });
}

/// Boots the real app on a restored session and navigates to `/profile`, so
/// the router redirect and the app-wide providers are exercised the same way
/// they are in production.
Future<ProviderContainer> _pumpProfile(
  WidgetTester tester, {
  FakeProfileRepository? profile,
  MeEntity? cachedUser,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider
          .overrideWithValue(profile ?? FakeProfileRepository()),
    ],
  );
  addTearDown(container.dispose);

  if (cachedUser != null) {
    container.read(currentUserProvider.notifier).setUser(cachedUser);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const SmartTeacherApp(),
    ),
  );
  await tester.pumpAndSettle();

  container.read(routerProvider).go(AppRoutes.profile);
  await tester.pumpAndSettle();
  expect(find.byType(ProfileScreen), findsOneWidget);

  return container;
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  await tester.fling(
    find.byType(ListView),
    const Offset(0, 300),
    1000,
  );
  await tester.pumpAndSettle();
}
