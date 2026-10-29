import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/session/school_suspension_controller.dart';
import 'core/session/session_controller.dart';
import 'features/classes/presentation/my_classes_controller.dart';
import 'features/library/presentation/library_controller.dart';
import 'features/notifications/presentation/notifications_controller.dart';
import 'features/notifications/presentation/push_registration_controller.dart';
import 'features/profile/presentation/profile_controller.dart';
import 'features/roster/presentation/roster_controller.dart';
import 'features/roster/presentation/roster_query.dart';
import 'features/roster/presentation/sections_controller.dart';

/// Every provider that caches **one actor's** data for the life of the app.
///
/// These are all deliberately non-auto-disposing — a tab switch or a picker
/// re-open must not cost a request — which also means nothing disposes them
/// when a session ends. Signing out and signing back in as somebody else
/// would otherwise leave the previous actor's answers in place: the shell
/// reads its role off `profileControllerProvider`, so a teacher's cached
/// profile painted the teacher tab set for the student who signed in after
/// them (PRD §5.7).
///
/// Anything auto-disposing (the curriculum tree family, the auth screens) is
/// absent on purpose: it is already gone with the screen that held it.
void _resetSessionScopedCaches(Ref ref) {
  ref.invalidate(profileControllerProvider);
  ref.invalidate(libraryControllerProvider);
  ref.invalidate(myClassesControllerProvider);
  ref.invalidate(rosterControllerProvider);
  ref.invalidate(rosterQueryProvider);
  ref.invalidate(sectionsControllerProvider);
  // The inbox is in this list and not on `invalidateOnSignOut` for the reason
  // the doc below gives: the shell's app bar *watches* it through the unread
  // badge, so it is one of the providers that must not be rebuilt while the
  // shell is still mounted.
  ref.invalidate(notificationsControllerProvider);
  // The latch is a property of the school the *previous* actor belonged to;
  // the new one gets to be judged on their own 403s.
  ref.invalidate(schoolSuspensionProvider);
}

/// Drops every session-scoped cache when a **new** session opens.
///
/// The reset fires on the transition *into* [SessionStatus.authenticated]
/// rather than on sign-out, and the difference matters: at sign-out the shell
/// is still mounted, so invalidating what it watches rebuilds those providers
/// immediately — against a store that has just been emptied, which means a
/// round of doomed requests and an error flash before the redirect lands. At
/// sign-in nothing watches them yet, so each one is simply discarded and
/// rebuilt lazily by whichever screen asks first. By then the login flow has
/// already put the new actor in `currentUserProvider`, so the profile rebuild
/// serves the right user from cache without a second `GET /users/me`.
///
/// This lives above `core/` because it names feature providers, and `core/`
/// may not import a feature. It is kept alive by [SmartTeacherApp].
final Provider<void> sessionResetProvider = Provider<void>((Ref ref) {
  ref.listen<SessionStatus>(
    sessionControllerProvider,
    (SessionStatus? previous, SessionStatus next) {
      if (next != SessionStatus.authenticated ||
          previous == SessionStatus.authenticated) {
        return;
      }

      _resetSessionScopedCaches(ref);

      // Push registration rides the same transition, which is exactly the
      // moment §5.10 names: "register the FCM/APNs token after login". It
      // covers a restored session too, since that is the same transition —
      // and `POST /me/devices` upserts on the token, so registering on every
      // launch is correct rather than duplicative.
      //
      // Not awaited, and it never throws: push is best-effort, every alert is
      // written in-app first, and nothing about signing in should wait on a
      // device row. The de-registration half is in [LogoutController], where it
      // runs *before* secure storage is cleared.
      unawaited(ref.read(pushRegistrationControllerProvider).register());
    },
  );
});
