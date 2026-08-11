import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_error.dart';
import 'session_controller.dart';

/// Whether the signed-in user's school has had its access suspended
/// (PRD §5.2).
///
/// A suspended school 403s **every** authenticated call for the remainder of
/// the access token's life. Without a shared latch, that shows up as a generic
/// error on each screen in turn; the PRD asks for one dedicated
/// "your school's access is suspended" screen instead. This notifier is that
/// latch — the single app-wide answer to "is this a suspension, or did this
/// one call just fail?".
///
/// Two things can set it:
///
///  - **The repeat pattern.** Every `403` the app receives is examined by
///    [SuspensionInterceptor]; the ones the error mapper reads as a suspension
///    ([ForbiddenError.isSchoolSuspended]) are reported here. One such 403 is
///    not enough — a single call can 403 for role or entitlement reasons and
///    still carry suspension-flavoured prose. [_confirmThreshold] consecutive
///    ones is the "repeated across calls" signal §5.2 describes.
///  - **An authoritative answer.** `GET /users/me` returning
///    `school.status == SUSPENDED`, or 403ing *as* a suspension, is not a
///    guess — the profile feature calls [confirm] directly in that case.
///
/// It clears itself on a successful authenticated call (a school that answers
/// is not suspended, so a reinstatement heals the app without a restart) and
/// when the session ends, so one user's suspension can't greet the next.
class SchoolSuspensionController extends Notifier<bool> {
  /// How many suspension-flavoured `403`s in a row count as "repeated".
  static const int _confirmThreshold = 2;

  int _streak = 0;

  @override
  bool build() {
    ref.listen<SessionStatus>(
      sessionControllerProvider,
      (SessionStatus? previous, SessionStatus next) {
        if (next == SessionStatus.unauthenticated) {
          reset();
        }
      },
    );

    return false;
  }

  /// A `403` that the error mapper read as a suspension. Latches once the
  /// pattern repeats — see [_confirmThreshold].
  void reportSuspendedForbidden() {
    _streak++;
    if (_streak >= _confirmThreshold) {
      _set(true);
    }
  }

  /// Any other outcome from an authenticated call, including a `403` for some
  /// *other* reason: the school is answering, so the streak restarts and a
  /// previously latched suspension is released.
  void reportAuthenticatedCallSucceeded() {
    _streak = 0;
    _set(false);
  }

  /// The school's own status said so. No threshold applies — this is the
  /// answer, not a pattern.
  void confirm() {
    _streak = _confirmThreshold;
    _set(true);
  }

  void reset() {
    _streak = 0;
    _set(false);
  }

  /// Guards against a late network callback writing to a disposed notifier.
  void _set(bool suspended) {
    if (ref.mounted && state != suspended) {
      state = suspended;
    }
  }
}

final NotifierProvider<SchoolSuspensionController, bool>
    schoolSuspensionProvider =
    NotifierProvider<SchoolSuspensionController, bool>(
  SchoolSuspensionController.new,
);
