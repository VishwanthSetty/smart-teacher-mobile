import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/storage/token_storage.dart';
import '../../activity/presentation/activity_sync_controller.dart';
import '../../notifications/presentation/push_registration_controller.dart';
import '../data/auth_repository.dart';

/// Which server-side sessions a logout revokes (PRD §5.1.3).
enum LogoutScope { thisDevice, allDevices }

/// Signing out (PRD §5.1.3).
///
/// Stateless on purpose — unlike login there is no failure the user can act
/// on, so there is nothing for a screen to render. Logout is **local-first**:
/// secure storage is cleared and the session gate flipped immediately, and
/// `POST /auth/logout` is fired alongside without being awaited. The server
/// revoke is best-effort; a user on a dead network still gets signed out.
///
/// It never calls `context.go` — ending the session is what navigates, via the
/// router redirect (the same rule [LoginController] follows in reverse).
class LogoutController {
  const LogoutController(this._ref);

  final Ref _ref;

  /// Completes once the local session is gone. The network revoke may still
  /// be in flight at that point, by design. [LogoutScope.thisDevice] is the
  /// default and sends the current refresh token; [LogoutScope.allDevices]
  /// omits it, which is the API's instruction to revoke every session.
  Future<void> logout({LogoutScope scope = LogoutScope.thisDevice}) async {
    // **First**, and awaited, unlike everything else here (mobile plan §5.10).
    // `DELETE /me/devices/:id` is a bearer-authenticated call, so it has to
    // happen while the access token still exists — clearing storage first would
    // strand the row on the server, and that row is precisely what a later push
    // would be delivered to, on a device nobody is signed in on. It is one fast
    // call that swallows its own failures, so awaiting it costs the logout
    // nothing it can lose.
    await _ref.read(pushRegistrationControllerProvider).unregister();

    // Read before clearing: the revoke needs a token pair that is about to
    // stop existing locally.
    final ({String? accessToken, String? refreshToken}) tokens =
        await _readTokens();

    final String? refreshToken = switch (scope) {
      LogoutScope.thisDevice => tokens.refreshToken,
      LogoutScope.allDevices => null,
    };
    final bool canRevoke = switch (scope) {
      LogoutScope.thisDevice => refreshToken != null,
      LogoutScope.allDevices => tokens.accessToken != null,
    };

    if (canRevoke) {
      // Deliberately not awaited — §5.1.3 forbids blocking the logout UX on
      // this round-trip. Failures are swallowed: the local session is being
      // torn down either way, and the server-side token expires on its own.
      unawaited(
        _revoke(refreshToken: refreshToken, accessToken: tokens.accessToken),
      );
    }

    // Before the gate flips, not after: the activity cache and the outbox both
    // hold *this* actor's data, and carrying either into the next session would
    // show one user another's history — or replay their queued beats under the
    // new account's token (mobile plan §0, "never cache a resource list past
    // logout").
    //
    // Queued-but-unsent progress is lost by this, deliberately. The alternative
    // is holding one user's writes while another is signed in, and a beat is a
    // far cheaper thing to lose than that.
    await _clearLocalActivity();

    await _ref.read(sessionControllerProvider.notifier).signOut();
  }

  Future<void> _clearLocalActivity() async {
    try {
      await _ref.read(activitySyncControllerProvider).clearForSignOut();
    } catch (_) {
      // Same contract as the keystore read above: a database that will not
      // open must not be able to trap a user in a session they asked to leave.
    }
  }

  Future<({String? accessToken, String? refreshToken})> _readTokens() async {
    final TokenStorage storage = _ref.read(tokenStorageProvider);
    try {
      return (
        accessToken: await storage.getAccessToken(),
        refreshToken: await storage.getRefreshToken(),
      );
    } catch (_) {
      // An unreadable keystore costs us the server-side revoke, nothing more.
      // Signing out locally must still happen.
      return (accessToken: null, refreshToken: null);
    }
  }

  Future<void> _revoke({
    required String? refreshToken,
    required String? accessToken,
  }) async {
    try {
      await _ref
          .read(authRepositoryProvider)
          .logout(refreshToken: refreshToken, accessToken: accessToken);
    } on AppError {
      // Nothing to show and nothing to retry — see logout()'s contract.
    }
  }
}

final Provider<LogoutController> logoutControllerProvider =
    Provider<LogoutController>(LogoutController.new);
