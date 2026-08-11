import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-lifecycle events the app reacts to outside the network layer.
///
/// [AuthInterceptor] (in `auth_interceptor.dart`) emits these instead of
/// navigating directly on an unrecoverable 401 — per PRD §6.2, navigation is
/// the router's job. Once the auth feature's router redirect (PRD §6.6)
/// exists, it listens to [AuthEventNotifier.events] and routes to `/login`.
enum AuthEvent {
  /// The refresh token was rejected, or the refresh call itself failed, and
  /// secure storage has already been cleared. Anything listening should
  /// treat the session as over.
  loggedOut,
}

/// Broadcast stream of [AuthEvent]s. One instance per app (see
/// [authEventNotifierProvider]) so any number of listeners — the router, an
/// in-app snackbar — can react to the same event.
class AuthEventNotifier {
  final StreamController<AuthEvent> _controller =
      StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get events => _controller.stream;

  void notifyLoggedOut() => _controller.add(AuthEvent.loggedOut);

  void dispose() => _controller.close();
}

final Provider<AuthEventNotifier> authEventNotifierProvider =
    Provider<AuthEventNotifier>((Ref ref) {
  final AuthEventNotifier notifier = AuthEventNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
