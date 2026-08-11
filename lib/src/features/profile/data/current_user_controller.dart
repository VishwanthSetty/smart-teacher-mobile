import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_controller.dart';
import '../domain/me_entity.dart';

/// The signed-in actor, once `GET /users/me` has answered.
///
/// Deliberately *not* part of [SessionController]: the session gate only knows
/// whether tokens exist, while role and school come from the API (PRD §5.7 —
/// "never hardcode a role assumption anywhere else in the app"). Keeping the
/// two apart means the router can redirect before the profile call lands.
///
/// `null` means "not fetched (yet)", which covers both a signed-out app and
/// the moment between `onSignedIn()` and the profile arriving on a restored
/// session. Consumers that need the user must handle `null` rather than
/// assume login already populated it.
///
/// It clears itself when the session ends, so a forced logout raised by the
/// Dio interceptor can't leave one user's profile visible to the next.
class CurrentUserController extends Notifier<MeEntity?> {
  @override
  MeEntity? build() {
    ref.listen<SessionStatus>(
      sessionControllerProvider,
      (SessionStatus? previous, SessionStatus next) {
        if (next == SessionStatus.unauthenticated) {
          clear();
        }
      },
    );

    return null;
  }

  /// Called by the login flow once the profile has been fetched, *before*
  /// `SessionController.onSignedIn()` so the role is in place by the time the
  /// router redirects to the shell.
  void setUser(MeEntity user) => _set(user);

  void clear() => _set(null);

  void _set(MeEntity? user) {
    if (ref.mounted) {
      state = user;
    }
  }
}

final NotifierProvider<CurrentUserController, MeEntity?> currentUserProvider =
    NotifierProvider<CurrentUserController, MeEntity?>(
  CurrentUserController.new,
);
