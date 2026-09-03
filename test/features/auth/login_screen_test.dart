import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/role_selection_screen.dart';
import 'package:smart_teacher_mobile/src/features/classes/data/teacher_assignment_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/section_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';
import 'package:smart_teacher_mobile/src/features/shell/presentation/app_shell.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/current_user_controller.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_section_repository.dart';
import '../../support/fake_student_repository.dart';
import '../../support/fake_teacher_assignment_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('form validation', () {
    testWidgets('an empty form is rejected before any request goes out',
        (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpLogin(tester, auth: auth);

      await _tapSignIn(tester);

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Enter your school code'), findsOneWidget);
      expect(auth.callCount, 0);
    });

    testWidgets('a malformed email is rejected before any request goes out',
        (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpLogin(tester, auth: auth);

      await _fillForm(tester, email: 'asha@springfield');
      await _tapSignIn(tester);

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(auth.callCount, 0);
    });

    testWidgets('surrounding whitespace is trimmed off the credentials',
        (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpLogin(tester, auth: auth);

      await _fillForm(
        tester,
        email: '  asha@springfield.edu ',
        schoolSlug: ' springfield ',
      );
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(auth.lastEmail, 'asha@springfield.edu');
      expect(auth.lastSchoolSlug, 'springfield');
    });
  });

  group('successful login', () {
    testWidgets('persists tokens, loads the profile, and opens the session',
        (WidgetTester tester) async {
      final FakeTokenStorage storage = FakeTokenStorage();
      final FakeProfileRepository profile = FakeProfileRepository(
        user: buildMe(name: 'Asha Rao', role: UserRole.teacher),
      );
      final ProviderContainer container = await _pumpLogin(
        tester,
        storage: storage,
        profile: profile,
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(await storage.getAccessToken(), 'access-token');
      expect(await storage.getRefreshToken(), 'refresh-token');
      expect(profile.callCount, 1);
      expect(container.read(currentUserProvider)?.name, 'Asha Rao');
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.authenticated,
      );
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('shows progress and refuses a second submit while in flight',
        (WidgetTester tester) async {
      final Completer<void> gate = Completer<void>();
      final FakeAuthRepository auth = FakeAuthRepository(gate: gate);
      await _pumpLogin(tester, auth: auth);

      await _fillForm(tester);
      await _tapSignIn(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await _tapSignIn(tester);
      expect(auth.callCount, 1);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
    });
  });

  group('error states (PRD §5.1.1)', () {
    testWidgets('401 says nothing about which of the three fields was wrong',
        (WidgetTester tester) async {
      final FakeTokenStorage storage = FakeTokenStorage();
      final ProviderContainer container = await _pumpLogin(
        tester,
        storage: storage,
        auth: FakeAuthRepository(
          error: const UnauthorizedError(message: 'Invalid credentials'),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Check your email, password and school code'),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await storage.getRefreshToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });

    testWidgets('404 is treated as a bad credential, not "no such school"',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const NotFoundError(message: 'School not found'),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Check your email, password and school code'),
        findsOneWidget,
      );
      expect(find.textContaining('school'), findsWidgets);
      expect(find.textContaining('not found'), findsNothing);
    });

    testWidgets('403 without the suspension signal reads as a disabled account',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const ForbiddenError(message: 'Account disabled'),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This account is disabled'),
        findsOneWidget,
      );
    });

    testWidgets('403 carrying the suspension signal points at the school',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const ForbiddenError(
            message: 'School suspended',
            isSchoolSuspended: true,
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Your school's access is suspended"),
        findsOneWidget,
      );
      expect(find.textContaining('This account is disabled'), findsNothing);
    });

    testWidgets('429 becomes a waiting state that counts itself down',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const RateLimitedError(
            message: 'Too many attempts',
            retryAfter: Duration(seconds: 90),
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Try again in 1 minute 30s'), findsOneWidget);
      expect(_signInButton(tester).onPressed, isNull);

      await tester.pump(const Duration(seconds: 31));
      expect(find.textContaining('Try again in 59s'), findsOneWidget);
      expect(_signInButton(tester).onPressed, isNull);

      // Window elapsed — the button comes back without a reload.
      await tester.pump(const Duration(seconds: 59));
      await tester.pump();
      expect(_signInButton(tester).onPressed, isNotNull);
    });

    testWidgets('a 429 with no Retry-After warns without locking the button',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const RateLimitedError(message: 'Too many attempts'),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Too many sign-in attempts'),
        findsOneWidget,
      );
      expect(find.textContaining('Try again in'), findsNothing);
      expect(_signInButton(tester).onPressed, isNotNull);
    });

    testWidgets('an offline attempt is not reported as a bad password',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const NetworkError(message: 'Could not reach the server.'),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(
        find.textContaining('Check your email, password and school code'),
        findsNothing,
      );
    });

    testWidgets('editing the form clears the previous failure',
        (WidgetTester tester) async {
      await _pumpLogin(
        tester,
        auth: FakeAuthRepository(
          error: const UnauthorizedError(message: 'Invalid credentials'),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Check your email, password and school code'),
        findsOneWidget,
      );

      await tester.enterText(_passwordField, 'another-try');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Check your email, password and school code'),
        findsNothing,
      );
    });
  });

  group('the profile call is part of logging in', () {
    testWidgets('a failed /users/me rolls the persisted tokens back',
        (WidgetTester tester) async {
      final FakeTokenStorage storage = FakeTokenStorage();
      final ProviderContainer container = await _pumpLogin(
        tester,
        storage: storage,
        profile: FakeProfileRepository(
          error: const UnknownError(message: 'Server error', statusCode: 500),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(find.text('Server error'), findsOneWidget);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('a suspended school is refused at the door, not per screen',
        (WidgetTester tester) async {
      final FakeTokenStorage storage = FakeTokenStorage();
      final ProviderContainer container = await _pumpLogin(
        tester,
        storage: storage,
        profile: FakeProfileRepository(
          user: buildMe(schoolStatus: SchoolStatus.suspended),
        ),
      );

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Your school's access is suspended"),
        findsOneWidget,
      );
      expect(await storage.getRefreshToken(), isNull);
      expect(container.read(currentUserProvider), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });
  });

  group('the signed-in profile follows the session', () {
    testWidgets('a forced logout drops the cached user',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpLogin(tester);

      await _fillForm(tester);
      await _tapSignIn(tester);
      await tester.pumpAndSettle();
      expect(container.read(currentUserProvider), isNotNull);

      await container.read(sessionControllerProvider.notifier).signOut();
      await tester.pumpAndSettle();

      expect(container.read(currentUserProvider), isNull);
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });
  });
}

final Finder _emailField = find.widgetWithText(TextFormField, 'Email');
final Finder _passwordField = find.widgetWithText(TextFormField, 'Password');
final Finder _schoolField = find.widgetWithText(TextFormField, 'School code');

/// Boots the real app (router included) on `/login` with fake repositories,
/// so each test exercises the same wiring production uses — including the
/// redirect that carries a successful login to `/home`.
Future<ProviderContainer> _pumpLogin(
  WidgetTester tester, {
  FakeTokenStorage? storage,
  FakeAuthRepository? auth,
  FakeProfileRepository? profile,
}) async {
  final ProviderContainer container = ProviderContainer(
    // `Override` isn't exported by flutter_riverpod, so the list stays
    // inferred — matching the existing router tests.
    overrides: [
      tokenStorageProvider.overrideWithValue(storage ?? FakeTokenStorage()),
      authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
      profileRepositoryProvider
          .overrideWithValue(profile ?? FakeProfileRepository()),
      // A successful login lands on the shell, whose IndexedStack builds every
      // tab up front — without these, each one would go to the network.
      curriculumRepositoryProvider.overrideWithValue(FakeCurriculumRepository()),
      teacherAssignmentRepositoryProvider.overrideWithValue(
        FakeTeacherAssignmentRepository(),
      ),
      studentRepositoryProvider.overrideWithValue(FakeStudentRepository()),
      sectionRepositoryProvider.overrideWithValue(FakeSectionRepository()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const SmartTeacherApp(),
    ),
  );
  await tester.pumpAndSettle();

  container.read(routerProvider).go(AppRoutes.login);
  await tester.pumpAndSettle();

  expect(find.byType(LoginScreen), findsOneWidget);
  return container;
}

Future<void> _fillForm(
  WidgetTester tester, {
  String email = 'asha@springfield.edu',
  String password = 'correct-horse',
  String schoolSlug = 'springfield',
}) async {
  await tester.enterText(_emailField, email);
  await tester.enterText(_passwordField, password);
  await tester.enterText(_schoolField, schoolSlug);
  await tester.pump();
}

Future<void> _tapSignIn(WidgetTester tester) async {
  // By type, not by label: mid-submit the button's child is a spinner.
  await tester.tap(find.byType(FilledButton), warnIfMissed: false);
  await tester.pump();
}

ButtonStyleButton _signInButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));


