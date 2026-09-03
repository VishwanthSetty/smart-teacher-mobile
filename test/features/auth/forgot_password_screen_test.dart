import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/role_selection_screen.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_token_storage.dart';

/// The confirmation copy, which must be identical for every outcome the app
/// treats as "sent".
const String _confirmation = 'If that account exists, a reset link is on its';

void main() {
  group('form validation', () {
    testWidgets('an empty form is rejected before any request goes out',
        (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpForgotPassword(tester, auth: auth);

      await _tapSend(tester);

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your school code'), findsOneWidget);
      expect(auth.forgotPasswordCallCount, 0);
    });

    testWidgets('a malformed email is rejected before any request goes out',
        (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpForgotPassword(tester, auth: auth);

      await _fillForm(tester, email: 'asha@springfield');
      await _tapSend(tester);

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(auth.forgotPasswordCallCount, 0);
    });
  });

  group('account existence is never revealed (PRD §5.1.4)', () {
    testWidgets('a 200 shows the conditional confirmation, not "sent"',
        (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpForgotPassword(tester, auth: auth);

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(auth.forgotPasswordCallCount, 1);
      expect(auth.lastEmail, 'asha@springfield.edu');
      expect(auth.lastSchoolSlug, 'springfield');
      expect(find.textContaining(_confirmation), findsOneWidget);
      // The form is gone, so there's nothing to retry against.
      expect(find.widgetWithText(TextFormField, 'Email'), findsNothing);
    });

    testWidgets('a 404 is indistinguishable from a successful request',
        (WidgetTester tester) async {
      await _pumpForgotPassword(
        tester,
        auth: FakeAuthRepository(
          forgotPasswordError: const NotFoundError(message: 'No such user'),
        ),
      );

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining(_confirmation), findsOneWidget);
      expect(find.textContaining('No such user'), findsNothing);
    });

    testWidgets('a 403 is indistinguishable from a successful request',
        (WidgetTester tester) async {
      await _pumpForgotPassword(
        tester,
        auth: FakeAuthRepository(
          forgotPasswordError: const ForbiddenError(message: 'Disabled'),
        ),
      );

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining(_confirmation), findsOneWidget);
      expect(find.textContaining('Disabled'), findsNothing);
    });
  });

  group('failures that mean nothing was sent', () {
    testWidgets('an offline attempt is reported, not claimed as sent',
        (WidgetTester tester) async {
      await _pumpForgotPassword(
        tester,
        auth: FakeAuthRepository(
          forgotPasswordError: const NetworkError(
            message: 'Could not reach the server.',
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(find.textContaining(_confirmation), findsNothing);
      // Still on the form, so the user can try again.
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('a 500 is reported, not claimed as sent',
        (WidgetTester tester) async {
      await _pumpForgotPassword(
        tester,
        auth: FakeAuthRepository(
          forgotPasswordError: const UnknownError(
            message: 'Something went wrong. Please try again.',
            statusCode: 500,
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Something went wrong'), findsOneWidget);
      expect(find.textContaining(_confirmation), findsNothing);
    });
  });

  group('rate limiting is its own state, worded for this screen', () {
    testWidgets('a 429 counts down and does not read like a failed login',
        (WidgetTester tester) async {
      await _pumpForgotPassword(
        tester,
        auth: FakeAuthRepository(
          forgotPasswordError: const RateLimitedError(
            message: 'Too many requests',
            retryAfter: Duration(seconds: 65),
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining("You've asked for a reset link a few times"),
        findsOneWidget,
      );
      expect(find.textContaining('Try again in 1 minute 5s'), findsOneWidget);
      // Distinct copy from the login lockout (PRD §5.1.4).
      expect(find.textContaining('sign-in attempts'), findsNothing);
      expect(_sendButton(tester).onPressed, isNull);

      await tester.pump(const Duration(seconds: 65));
      await tester.pump();
      expect(_sendButton(tester).onPressed, isNotNull);
    });

    testWidgets('a 429 with no Retry-After warns without locking the button',
        (WidgetTester tester) async {
      await _pumpForgotPassword(
        tester,
        auth: FakeAuthRepository(
          forgotPasswordError: const RateLimitedError(
            message: 'Too many requests',
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining("You've asked for a reset link a few times"),
        findsOneWidget,
      );
      expect(find.textContaining('Try again in'), findsNothing);
      expect(_sendButton(tester).onPressed, isNotNull);
    });
  });

  group('navigation', () {
    testWidgets('the confirmation can hand the form back for a typo',
        (WidgetTester tester) async {
      await _pumpForgotPassword(tester);

      await _fillForm(tester);
      await _tapSend(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining(_confirmation), findsOneWidget);

      await tester.tap(find.text('Use a different email'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.textContaining(_confirmation), findsNothing);
    });

    testWidgets('"Back to sign in" returns to /login',
        (WidgetTester tester) async {
      await _pumpForgotPassword(tester);

      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });

    testWidgets('the login screen can reach this screen',
        (WidgetTester tester) async {
      await _pumpForgotPassword(tester, startAtLogin: true);

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });
  });

  testWidgets('a second send is refused while one is in flight',
      (WidgetTester tester) async {
    final Completer<void> gate = Completer<void>();
    final FakeAuthRepository auth = FakeAuthRepository(gate: gate);
    await _pumpForgotPassword(tester, auth: auth);

    await _fillForm(tester);
    await _tapSend(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await _tapSend(tester);
    expect(auth.forgotPasswordCallCount, 1);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining(_confirmation), findsOneWidget);
  });
}

final Finder _emailField = find.widgetWithText(TextFormField, 'Email');
final Finder _schoolField = find.widgetWithText(TextFormField, 'School code');

Future<ProviderContainer> _pumpForgotPassword(
  WidgetTester tester, {
  FakeAuthRepository? auth,
  bool startAtLogin = false,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
      authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
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

  if (!startAtLogin) {
    container.read(routerProvider).go(AppRoutes.forgotPassword);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  } else {
    container.read(routerProvider).go(AppRoutes.login);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  }

  return container;
}

Future<void> _fillForm(
  WidgetTester tester, {
  String email = 'asha@springfield.edu',
  String schoolSlug = 'springfield',
}) async {
  await tester.enterText(_emailField, email);
  await tester.enterText(_schoolField, schoolSlug);
  await tester.pump();
}

Future<void> _tapSend(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton), warnIfMissed: false);
  await tester.pump();
}

ButtonStyleButton _sendButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

