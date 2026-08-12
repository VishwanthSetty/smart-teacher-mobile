import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/reset_password_screen.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('the link itself', () {
    testWidgets('a link with no token shows no form at all', (
      WidgetTester tester,
    ) async {
      await _pumpReset(tester, token: null);

      expect(
        find.textContaining('This reset link is incomplete'),
        findsOneWidget,
      );
      expect(_passwordField, findsNothing);
      expect(find.text('Request a new link'), findsOneWidget);
    });

    testWidgets('a rejected token takes the form down and offers a new link', (
      WidgetTester tester,
    ) async {
      await _pumpReset(
        tester,
        auth: FakeAuthRepository(
          resetPasswordError: const UnauthorizedError(message: 'Token expired'),
        ),
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('expired or has already been used'),
        findsOneWidget,
      );
      expect(_passwordField, findsNothing);

      await tester.tap(find.text('Request a new link'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('a 404 on the token reads the same as an expired one', (
      WidgetTester tester,
    ) async {
      await _pumpReset(
        tester,
        auth: FakeAuthRepository(
          resetPasswordError: const NotFoundError(message: 'Not found'),
        ),
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('expired or has already been used'),
        findsOneWidget,
      );
    });
  });

  group('form validation', () {
    testWidgets('an empty form is rejected before any request goes out', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpReset(tester, auth: auth);

      await _tapSubmit(tester);

      expect(find.text('Enter a new password'), findsOneWidget);
      expect(find.text('Re-enter your new password'), findsOneWidget);
      expect(auth.resetPasswordCallCount, 0);
    });

    testWidgets('a short password is rejected before any request goes out', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpReset(tester, auth: auth);

      await _fillForm(tester, password: 'short', confirmation: 'short');
      await _tapSubmit(tester);

      expect(find.text('Use at least 8 characters'), findsOneWidget);
      expect(auth.resetPasswordCallCount, 0);
    });

    testWidgets('a mistyped confirmation is caught client-side', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await _pumpReset(tester, auth: auth);

      await _fillForm(
        tester,
        password: 'correct-horse-battery',
        confirmation: 'correct-horse-bttery',
      );
      await _tapSubmit(tester);

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(auth.resetPasswordCallCount, 0);
    });

    testWidgets('the strength meter tracks what has been typed', (
      WidgetTester tester,
    ) async {
      await _pumpReset(tester);

      await tester.enterText(_passwordField, 'password');
      await tester.pumpAndSettle();
      expect(find.text('Weak'), findsOneWidget);

      await tester.enterText(_passwordField, 'Passw0rd-long');
      await tester.pumpAndSettle();
      expect(find.text('Strong'), findsOneWidget);
    });
  });

  group('a successful reset', () {
    testWidgets('sends the token, ends the session, and lands on /login', (
      WidgetTester tester,
    ) async {
      final FakeTokenStorage storage = FakeTokenStorage(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      final FakeAuthRepository auth = FakeAuthRepository();
      final ProviderContainer container = await _pumpReset(
        tester,
        auth: auth,
        storage: storage,
        token: 'token-from-email',
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(auth.lastResetToken, 'token-from-email');
      expect(auth.lastPassword, 'correct-horse-battery');
      expect(find.byType(LoginScreen), findsOneWidget);

      // Every session is revoked server-side, so the local one must go too —
      // otherwise the router would bounce straight back into the app on dead
      // tokens.
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });

  group('server-side rejections', () {
    testWidgets("a rejected password shows the API's own wording", (
      WidgetTester tester,
    ) async {
      await _pumpReset(
        tester,
        auth: FakeAuthRepository(
          resetPasswordError: const ValidationError(
            message: 'Password is too common',
            fieldErrors: <String>['password must not be a common password'],
            statusCode: 422,
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('Password is too common'), findsOneWidget);
      expect(
        find.textContaining('must not be a common password'),
        findsOneWidget,
      );
      // Recoverable — unlike a dead token, the form stays up.
      expect(_passwordField, findsOneWidget);
    });

    testWidgets('a 400 with no field list still shows what the API said', (
      WidgetTester tester,
    ) async {
      await _pumpReset(
        tester,
        auth: FakeAuthRepository(
          resetPasswordError: const ValidationError(
            message: 'Password must contain a number',
            fieldErrors: <String>[],
            statusCode: 400,
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('Password must contain a number'), findsOneWidget);
      expect(_passwordField, findsOneWidget);
    });

    testWidgets('a 429 counts down and blocks submission', (
      WidgetTester tester,
    ) async {
      await _pumpReset(
        tester,
        auth: FakeAuthRepository(
          resetPasswordError: const RateLimitedError(
            message: 'Too many attempts',
            retryAfter: Duration(seconds: 30),
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('Try again in 30s'), findsOneWidget);
      expect(_submitButton(tester).onPressed, isNull);

      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      expect(_submitButton(tester).onPressed, isNotNull);
    });

    testWidgets('an offline attempt keeps the form and says why', (
      WidgetTester tester,
    ) async {
      await _pumpReset(
        tester,
        auth: FakeAuthRepository(
          resetPasswordError: const NetworkError(
            message: 'Could not reach the server.',
          ),
        ),
      );

      await _fillForm(tester);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(_passwordField, findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });
  });
}

final Finder _passwordField = find.widgetWithText(
  TextFormField,
  'New password',
);
final Finder _confirmField = find.widgetWithText(
  TextFormField,
  'Confirm new password',
);

/// Boots the app and follows the deep link to `/reset-password`. The route is
/// exempt from the authenticated redirect (PRD §5.1.4), so this works with or
/// without a stored session.
Future<ProviderContainer> _pumpReset(
  WidgetTester tester, {
  FakeAuthRepository? auth,
  FakeTokenStorage? storage,
  String? token = 'reset-token',
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage ?? FakeTokenStorage()),
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

  container
      .read(routerProvider)
      .go(
        token == null
            ? AppRoutes.resetPassword
            : '${AppRoutes.resetPassword}?${AppRoutes.resetTokenParam}=$token',
      );
  await tester.pumpAndSettle();
  expect(find.byType(ResetPasswordScreen), findsOneWidget);

  return container;
}

Future<void> _fillForm(
  WidgetTester tester, {
  String password = 'correct-horse-battery',
  String confirmation = 'correct-horse-battery',
}) async {
  await tester.enterText(_passwordField, password);
  await tester.enterText(_confirmField, confirmation);
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton), warnIfMissed: false);
  await tester.pump();
}

ButtonStyleButton _submitButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));
