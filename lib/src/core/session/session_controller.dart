import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/auth_event_notifier.dart';
import '../storage/token_storage.dart';

/// Whether the app currently has a session, from the router's point of view
/// (PRD §6.6).
enum SessionStatus {
  /// Startup: secure storage hasn't been read yet, so we can't tell. The
  /// router parks on `/splash` rather than guessing — guessing means either
  /// flashing the login screen at a signed-in user or briefly showing a
  /// protected screen to a signed-out one.
  unknown,

  /// A refresh token is present. Whether it is still *valid* is the server's
  /// answer, delivered as a 401 the interceptor handles (PRD §6.2) — which,
  /// if refresh fails, lands back here as [unauthenticated].
  authenticated,

  /// No session. Everything except the public auth routes redirects to
  /// `/login`.
  unauthenticated,
}

/// The single session gate the router redirect reads (PRD §6.6).
///
/// Three things move it:
///  - **startup** — [_restore] reads [TokenStorage.hasValidSession] once.
///  - **login/logout** — the auth feature calls [onSignedIn] / [signOut].
///  - **forced logout** — [AuthEvent.loggedOut] from the Dio interceptor,
///    raised when a refresh fails anywhere in the app. Storage is already
///    cleared by then; this just flips the status, and the router's
///    `refreshListenable` turns that into a redirect to `/login`.
///
/// Role lives elsewhere on purpose: it comes from `GET /users/me`, not from
/// the token, so the role-based shell selection (PRD §5.7) belongs to the
/// profile feature rather than this gate.
class SessionController extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    final AuthEventNotifier authEvents = ref.watch(authEventNotifierProvider);

    final StreamSubscription<AuthEvent> subscription = authEvents.events.listen(
      (AuthEvent event) {
        switch (event) {
          case AuthEvent.loggedOut:
            _set(SessionStatus.unauthenticated);
        }
      },
    );
    ref.onDispose(subscription.cancel);

    unawaited(_restore());
    return SessionStatus.unknown;
  }

  /// Marks the session live. Call **after** the tokens are in secure storage,
  /// so a redirect triggered by this can't outrun the persisted pair.
  void onSignedIn() => _set(SessionStatus.authenticated);

  /// Clears the session locally and immediately. Per PRD §5.1.3 logout must
  /// not wait on a network round-trip — the caller may fire the server-side
  /// revoke separately and ignore its outcome.
  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).clearTokens();
    _set(SessionStatus.unauthenticated);
  }

  Future<void> _restore() async {
    bool hasSession;
    try {
      hasSession = await ref.read(tokenStorageProvider).hasValidSession();
    } catch (_) {
      // An unreadable keystore (wiped, corrupted, or a platform channel that
      // isn't there) must not strand the app on the splash screen forever.
      // Treat it as "no session" — the worst case is one avoidable login.
      hasSession = false;
    }
    _set(
      hasSession ? SessionStatus.authenticated : SessionStatus.unauthenticated,
    );
  }

  /// Guards against a late async result (a slow storage read, an event racing
  /// teardown) writing to a disposed notifier.
  void _set(SessionStatus status) {
    if (ref.mounted) {
      state = status;
    }
  }
}

final NotifierProvider<SessionController, SessionStatus>
    sessionControllerProvider =
    NotifierProvider<SessionController, SessionStatus>(SessionController.new);
