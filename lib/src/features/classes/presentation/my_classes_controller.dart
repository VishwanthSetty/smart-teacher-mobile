import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../profile/data/current_user_controller.dart';
import '../../profile/domain/me_entity.dart';
import '../data/teacher_assignment_repository.dart';
import '../domain/teacher_assignment_entity.dart';

/// Backs My Classes (PRD §5.5.1).
///
/// Shaped like `LibraryController` — always fetches in [build], the same
/// `refresh()` for pull-to-refresh and "Try again", the same suppressed
/// automatic retry — with one difference that is the whole point of this
/// screen: **the call needs the signed-in teacher's own id.**
///
/// It comes from [currentUserProvider], the profile `GET /users/me` already
/// cached (there is no second fetch for it here). [build] *watches* it, so if
/// the profile is refreshed into a different actor the assignments are re-read
/// for them rather than left showing the previous teacher's classes; `MeEntity`
/// has value equality, so an identical re-fetch doesn't churn.
///
/// With no cached profile there is **no call at all**. Issuing one without
/// `teacherId` would not fail — it would succeed and return the whole school's
/// assignments (§5.5.1), which is a worse outcome than an error state, so this
/// is one of the few places the app manufactures an [AppError] rather than
/// relaying one. In practice it is unreachable from the shell, which only
/// builds its tabs once the profile has resolved (§5.7).
///
/// Unlike the library, a suspension-flavoured `403` here is **not** confirmed
/// on the spot. [SuspensionInterceptor] already observes this call like every
/// other authenticated one, so reporting it again from here would turn a single
/// `403` into the two-in-a-row the latch treats as corroboration — and this
/// endpoint is role-gated (`SCHOOL_ADMIN`/`TEACHER`, §8.6) rather than scoped
/// to the actor's entitlements, so its `403` has an innocent reading the
/// library's does not. Latching the whole app onto the suspension screen is
/// worth being sure about.
class MyClassesController extends AsyncNotifier<List<TeacherAssignmentEntity>> {
  /// Guards against a second pull landing while the first is still in flight.
  bool _refreshing = false;

  @override
  Future<List<TeacherAssignmentEntity>> build() {
    final MeEntity? me = ref.watch(currentUserProvider);
    return _fetch(me);
  }

  /// Pull-to-refresh, and the "Try again" action on the error state.
  ///
  /// The current state is left alone until the call answers, so a populated
  /// list stays on screen instead of blanking out mid-gesture. A failure lands
  /// as an error state rather than being thrown at the gesture.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final MeEntity? me = ref.read(currentUserProvider);
      final AsyncValue<List<TeacherAssignmentEntity>> next =
          await AsyncValue.guard(() => _fetch(me));
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<List<TeacherAssignmentEntity>> _fetch(MeEntity? me) async {
    if (me == null) {
      throw const UnknownError(
        message: "We couldn't confirm who you're signed in as. "
            'Please try again.',
      );
    }

    return ref.read(teacherAssignmentRepositoryProvider).fetchAssignments(
          teacherId: me.id,
        );
  }
}

/// `retry: null` turns off Riverpod's automatic exponential retry, matching the
/// rest of the app: a failed load is shown with an explicit "Try again" rather
/// than re-issued behind the user's back — pointlessly so against a suspended
/// school, which 403s every time.
final AsyncNotifierProvider<MyClassesController, List<TeacherAssignmentEntity>>
    myClassesControllerProvider = AsyncNotifierProvider<MyClassesController,
        List<TeacherAssignmentEntity>>(
  MyClassesController.new,
  retry: (int retryCount, Object error) => null,
);
