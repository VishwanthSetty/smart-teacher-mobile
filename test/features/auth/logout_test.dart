import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/role_selection_screen.dart';
import 'package:smart_teacher_mobile/src/features/shell/domain/shell_tab.dart';
import 'package:smart_teacher_mobile/src/features/shell/presentation/app_shell.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/current_user_controller.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/presentation/profile_screen.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('logout (PRD §5.1.3)', () {
    testWidgets('revokes this device, clears storage, and lands on /login', (
      WidgetTester tester,
    ) async {
      final FakeTokenStorage storage = FakeTokenStorage(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final FakeAuthRepository auth = FakeAuthRepository();
      final ProviderContainer container = await _pumpSignedIn(
        tester,
        storage: storage,
        auth: auth,
      );

      await _tapSignOut(tester);

      expect(auth.logoutCallCount, 1);
      // The refresh token scopes the revoke to this device; omitting it would
      // sign the user out everywhere.
      expect(auth.lastLogoutRefreshToken, 'refresh-token');
      expect(auth.lastLogoutAccessToken, 'access-token');

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(container.read(currentUserProvider), isNull);
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });

    testWidgets('does not wait for the revoke before signing out', (
      WidgetTester tester,
    ) async {
      final Completer<void> gate = Completer<void>();
      final FakeTokenStorage storage = FakeTokenStorage(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final ProviderContainer container = await _pumpSignedIn(
        tester,
        storage: storage,
        auth: FakeAuthRepository(gate: gate),
      );

      await _tapSignOut(tester);

      // The network call is still in flight, and the user is already out.
      expect(gate.isCompleted, isFalse);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(await storage.getRefreshToken(), isNull);
      expect(find.byType(RoleSelectionScreen), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });

    testWidgets('can revoke every session after explicit confirmation', (
      WidgetTester tester,
    ) async {
      final FakeTokenStorage storage = FakeTokenStorage(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final FakeAuthRepository auth = FakeAuthRepository();
      final ProviderContainer container = await _pumpSignedIn(
        tester,
        storage: storage,
        auth: auth,
      );

      await _openProfile(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Sign out everywhere'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out everywhere?'), findsOneWidget);
      expect(auth.logoutCallCount, 0);

      await tester.tap(
        find.widgetWithText(FilledButton, 'Sign out everywhere'),
      );
      await tester.pumpAndSettle();

      expect(auth.logoutCallCount, 1);
      // Null is deliberate: the repository omits the body, which tells the
      // API to revoke every session instead of only this refresh token.
      expect(auth.lastLogoutRefreshToken, isNull);
      expect(auth.lastLogoutAccessToken, 'access-token');
      expect(await storage.getRefreshToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });

    testWidgets('cancelling sign out everywhere keeps the session', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      final ProviderContainer container = await _pumpSignedIn(
        tester,
        storage: FakeTokenStorage(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        ),
        auth: auth,
      );

      await _openProfile(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Sign out everywhere'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(auth.logoutCallCount, 0);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.authenticated,
      );
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('a failed revoke still signs the user out', (
      WidgetTester tester,
    ) async {
      final FakeTokenStorage storage = FakeTokenStorage(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final ProviderContainer container = await _pumpSignedIn(
        tester,
        storage: storage,
        auth: FakeAuthRepository(
          logoutError: const NetworkError(
            message: 'Could not reach the server.',
          ),
        ),
      );

      await _tapSignOut(tester);

      expect(await storage.getRefreshToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
      // Nothing to act on, so nothing is surfaced.
      expect(find.text('Could not reach the server.'), findsNothing);
    });

    testWidgets('an unreadable keystore still signs the user out', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      final ProviderContainer container = await _pumpSignedIn(
        tester,
        storage: FakeTokenStorage(
          refreshToken: 'refresh-token',
          failReads: true,
        ),
        auth: auth,
        // `failReads` also breaks the startup session restore, so this test
        // opens the session by hand rather than through the splash redirect.
        restoreSession: false,
      );

      await _tapSignOut(tester);

      // No token to send, so no call goes out — but the session ends anyway.
      expect(auth.logoutCallCount, 0);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });
  });
}

/// Boots the real app (router included) already signed in, so the sign-out tap
/// exercises the same wiring production uses — including the redirect that
/// carries an ended session to `/login`.
Future<ProviderContainer> _pumpSignedIn(
  WidgetTester tester, {
  required FakeTokenStorage storage,
  FakeAuthRepository? auth,
  bool restoreSession = true,
}) async {
  final ProviderContainer container = ProviderContainer(
    // `Override` isn't exported by flutter_riverpod, so the list stays
    // inferred — matching the existing auth tests.
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
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
  await tester.pumpAndSettle();

  if (!restoreSession) {
    container.read(sessionControllerProvider.notifier).onSignedIn();
    await tester.pumpAndSettle();
  }

  expect(find.byType(AppShell), findsOneWidget);
  return container;
}

/// Sign-out lives on the profile screen (PRD §5.2), so every one of these
/// walks there first — the same route a user takes. The fake actor is a
/// teacher, whose shell (§5.7) has no Profile tab, so the way there is the
/// shell's app-bar action.
Future<void> _tapSignOut(WidgetTester tester) async {
  await _openProfile(tester);

  final Finder button = find.widgetWithText(FilledButton, 'Sign out');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.widgetWithIcon(IconButton, ShellTab.profile.icon));
  await tester.pumpAndSettle();
  expect(find.byType(ProfileScreen), findsOneWidget);
}

