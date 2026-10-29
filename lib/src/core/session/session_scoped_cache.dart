import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_controller.dart';

/// Drops a provider's state when the session ends.
///
/// **Call this from the `build()` of any non-auto-disposing controller that
/// holds server data.** Mobile plan §0 is explicit: the app never caches a
/// resource list past logout. A controller that is held for the session — the
/// saved list, the collections, either task list — would otherwise still be
/// populated when the next user signs in on the same device, and would show
/// them the previous actor's rows until something happened to refresh it.
///
/// Auto-disposing controllers need none of this: nothing is watching them by
/// the time the router has replaced every screen with `/login`.
///
/// [CurrentUserController] does the same thing by hand rather than through
/// this, because it clears to a meaningful `null` rather than re-running a
/// fetch — invalidating it would immediately rebuild it to the same `null`.
void invalidateOnSignOut(Ref ref) {
  ref.listen<SessionStatus>(sessionControllerProvider, (
    SessionStatus? previous,
    SessionStatus next,
  ) {
    if (next == SessionStatus.unauthenticated) {
      ref.invalidateSelf();
    }
  });
}
