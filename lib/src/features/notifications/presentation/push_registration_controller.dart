import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../data/notification_repository.dart';
import '../domain/notification_entity.dart';
import '../domain/push_token_source.dart';

/// Registers this device for push, and un-registers it on the way out
/// (mobile plan §5.10).
///
/// Two rules shape the whole class:
///
/// 1. **`DELETE /me/devices/:id` happens before secure storage is cleared.** It
///    is a bearer-authenticated call, so a logout that cleared the tokens first
///    would leave the row on the server forever — and that row is what a later
///    push would be delivered to, on a device nobody is signed in on.
///    [LogoutController] therefore calls [unregister] as its first step.
/// 2. **Nothing here is allowed to fail loudly.** Push is best-effort by
///    design; every notification is written in-app first (backend plan §5.5),
///    so a device that cannot register still sees every alert in the inbox. An
///    `AppError` from either call is swallowed, exactly as the logout revoke's
///    is.
///
/// The device id is held in memory rather than persisted. It is re-derived on
/// every registration — `POST /me/devices` upserts on the token and answers
/// with the row — so a process restart re-registers and gets the id back. A
/// logout in a session that never registered has nothing to delete, which is
/// the correct no-op rather than a missing cleanup.
class PushRegistrationController {
  PushRegistrationController(this._ref);

  final Ref _ref;

  String? _deviceId;
  StreamSubscription<String>? _refreshes;

  /// The registered device's id, or `null` when this session has not (or could
  /// not) register one. Exposed for tests and for [unregister]'s contract.
  String? get deviceId => _deviceId;

  /// Called after a session opens. Safe to call repeatedly: the endpoint
  /// upserts on the token.
  ///
  /// A source with no provider behind it answers `null` and this returns
  /// without a request — which is the whole of the "push permission denied"
  /// path, presented plainly rather than as a nag (mobile plan §5.10).
  Future<void> register() async {
    final PushTokenSource source = _ref.read(pushTokenSourceProvider);
    final String? platform = source.platform;
    final String? token = await _readToken(source);
    if (platform == null || token == null || token.isEmpty) {
      return;
    }

    await _registerToken(platform: platform, token: token);

    // Re-register on every re-mint. The old row is not deleted: the server
    // upserts by token, so a re-minted token creates a second row, and the dead
    // one ages out of the provider's own delivery attempts. Deleting it would
    // need an id we were never given for a token we no longer hold.
    _refreshes ??= source.tokenRefreshes.listen((String refreshed) {
      unawaited(_registerToken(platform: platform, token: refreshed));
    });
  }

  /// Removes this device's row, then forgets it.
  ///
  /// Called from the logout path **before** the token pair is cleared. Awaited
  /// there, unlike the session revoke: this one needs the bearer token that is
  /// about to disappear, and it is a single fast call with nothing behind it.
  Future<void> unregister() async {
    final String? id = _deviceId;
    // Cleared first, so a failed delete cannot leave a stale id pointing at a
    // row the next session would try to delete again under a different account.
    _deviceId = null;
    await _refreshes?.cancel();
    _refreshes = null;

    if (id == null || id.isEmpty) {
      return;
    }
    try {
      await _ref.read(notificationRepositoryProvider).removeDevice(id);
    } on AppError {
      // Best-effort, like the session revoke beside it. A `404` means the row
      // is already gone, which is the outcome we wanted anyway.
    }
  }

  Future<void> _registerToken({
    required String platform,
    required String token,
  }) async {
    try {
      final DeviceRegistrationEntity device = await _ref
          .read(notificationRepositoryProvider)
          .registerDevice(platform: platform, token: token);
      if (device.id.isNotEmpty) {
        _deviceId = device.id;
      }
    } on AppError {
      // Swallowed: the inbox works regardless, and a retry loop against a
      // suspended school would 403 forever.
    }
  }

  Future<String?> _readToken(PushTokenSource source) async {
    try {
      return await source.currentToken();
    } catch (_) {
      // A provider SDK that throws on an unconfigured project must not be able
      // to break sign-in, which is the call site this sits behind.
      return null;
    }
  }
}

final Provider<PushRegistrationController> pushRegistrationControllerProvider =
    Provider<PushRegistrationController>(PushRegistrationController.new);
