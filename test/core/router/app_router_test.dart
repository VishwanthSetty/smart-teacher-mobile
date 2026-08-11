import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/network/auth_event_notifier.dart';
import 'package:smart_teacher_mobile/src/core/router/app_router.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/reset_password_screen.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/shell/presentation/app_shell.dart';
import 'package:smart_teacher_mobile/src/features/splash/presentation/splash_screen.dart';

import '../../support/fake_profile_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('startup gate', () {
    testWidgets('holds on splash while the session is undetermined',
        (WidgetTester tester) async {
      final Completer<void> gate = Completer<void>();
      await _pumpApp(
        tester,
        storage: FakeTokenStorage(restoreGate: gate),
        settle: false,
      );

      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('sends a user with no stored session to /login',
        (WidgetTester tester) async {
      await _pumpApp(tester, storage: FakeTokenStorage());

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('sends a user with a stored session to /home',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        storage: FakeTokenStorage(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      );

      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('falls back to /login when secure storage cannot be read',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        storage: FakeTokenStorage(refreshToken: 'refresh', failReads: true),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('deep links arriving during startup', () {
    testWidgets('a reset link that lands before the session resolves survives',
        (WidgetTester tester) async {
      final Completer<void> gate = Completer<void>();
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(restoreGate: gate),
        settle: false,
      );

      // The OS hands the link over while secure storage is still being read.
      container
          .read(routerProvider)
          .go('${AppRoutes.resetPassword}?token=abc123');
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      // The token made it through to a usable form, rather than the
      // "incomplete link" state.
      expect(find.widgetWithText(TextFormField, 'New password'), findsOneWidget);
    });

    testWidgets('a parked destination is re-gated once the session resolves',
        (WidgetTester tester) async {
      final Completer<void> gate = Completer<void>();
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(restoreGate: gate),
        settle: false,
      );

      container.read(routerProvider).go(AppRoutes.home);
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      // Storage answers "no session" — the parked /home must not be honoured.
      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('unauthenticated redirects', () {
    testWidgets('a protected route redirects to /login',
        (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpApp(tester, storage: FakeTokenStorage());

      container.read(routerProvider).go(AppRoutes.home);
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('public auth routes stay reachable',
        (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpApp(tester, storage: FakeTokenStorage());

      container.read(routerProvider).go(AppRoutes.forgotPassword);
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      container.read(routerProvider).go(AppRoutes.resetPassword);
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });

    testWidgets('the gate wins over an unknown route — no error page leaks',
        (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpApp(tester, storage: FakeTokenStorage());

      container.read(routerProvider).go('/nope');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.textContaining('Page not found'), findsNothing);
    });
  });

  group('authenticated redirects', () {
    testWidgets('/login bounces to /home for a signed-in user',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(refreshToken: 'refresh'),
      );

      container.read(routerProvider).go(AppRoutes.login);
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('/reset-password is exempt — a deep link still opens it',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(refreshToken: 'refresh'),
      );

      container
          .read(routerProvider)
          .go('${AppRoutes.resetPassword}?token=abc123');
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      // The token made it through to a usable form, rather than the
      // "incomplete link" state.
      expect(find.widgetWithText(TextFormField, 'New password'), findsOneWidget);
    });

    testWidgets('an unknown route reaches the error page once signed in',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(refreshToken: 'refresh'),
      );

      container.read(routerProvider).go('/nope');
      await tester.pumpAndSettle();

      expect(find.textContaining('Page not found'), findsOneWidget);
    });

    testWidgets('a missing reset token is surfaced, not silently accepted',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(refreshToken: 'refresh'),
      );

      container.read(routerProvider).go(AppRoutes.resetPassword);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This reset link is incomplete'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'New password'), findsNothing);
    });
  });

  group('forced logout', () {
    testWidgets('an interceptor logout event redirects to /login',
        (WidgetTester tester) async {
      final ProviderContainer container = await _pumpApp(
        tester,
        storage: FakeTokenStorage(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      );
      expect(find.byType(AppShell), findsOneWidget);

      // What AuthInterceptor emits when a refresh fails anywhere in the app.
      container.read(authEventNotifierProvider).notifyLoggedOut();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });

    testWidgets('signing out clears tokens and redirects',
        (WidgetTester tester) async {
      final FakeTokenStorage storage = FakeTokenStorage(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      final ProviderContainer container =
          await _pumpApp(tester, storage: storage);

      // Driven through the session gate rather than the button: the button
      // lives on the profile screen (PRD §5.2) and its own path is covered in
      // test/features/auth/logout_test.dart. What matters here is only that a
      // closed session moves the router.
      await container.read(sessionControllerProvider.notifier).signOut();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });

    testWidgets('signing back in returns to /home', (WidgetTester tester) async {
      final ProviderContainer container =
          await _pumpApp(tester, storage: FakeTokenStorage());
      expect(find.byType(LoginScreen), findsOneWidget);

      container.read(sessionControllerProvider.notifier).onSignedIn();
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
    });
  });
}

/// Boots the real app against a fake token storage and returns the container,
/// so a test can drive navigation and session state the way the app does.
Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required TokenStorage storage,
  bool settle = true,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      // /home is the role-based shell now (PRD §5.7), and a restored session
      // means it fetches `GET /users/me` for its tab set. Without this the
      // redirect tests would be making a real HTTP call.
      profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const SmartTeacherApp(),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }

  return container;
}
