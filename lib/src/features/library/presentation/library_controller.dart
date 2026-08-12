import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../data/curriculum_repository.dart';
import '../domain/curriculum_entity.dart';

/// Backs the library list (PRD §5.4.1).
///
/// Unlike the profile there is nothing cached to serve first — no earlier step
/// in the app fetches `/curricula` — so [build] always goes to the network and
/// the screen's first frame is a loading state.
///
/// An **empty list is data, not an error** (§6.4): an unentitled school and a
/// student with no active enrollment both answer `200 []`, and the screen owes
/// them a first-class empty state. Nothing here turns that into a failure.
///
/// A `403` worded as a suspension is reported to [schoolSuspensionProvider]
/// immediately rather than waiting for the interceptor's two-in-a-row pattern.
/// The interceptor deliberately corroborates, because one suspension-flavoured
/// `403` can be an ordinary entitlement refusal — but `/curricula` is the
/// broadest read either role has, scoped to exactly what they are entitled to,
/// so there is no narrower entitlement for it to be refused by (§5.2).
class LibraryController extends AsyncNotifier<List<CurriculumEntity>> {
  /// Guards against a second pull landing while the first is still in flight.
  bool _refreshing = false;

  @override
  Future<List<CurriculumEntity>> build() => _fetch();

  /// Pull-to-refresh, and the "Try again" action on the error state.
  ///
  /// The current state is left alone until the call answers, so a populated
  /// list stays on screen instead of blanking out mid-gesture —
  /// `RefreshIndicator` is already showing progress, and awaits this future to
  /// decide when to retract. A failure lands as an error state rather than
  /// being thrown at the gesture.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<CurriculumEntity>> next =
          await AsyncValue.guard(_fetch);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<List<CurriculumEntity>> _fetch() async {
    try {
      return await ref.read(curriculumRepositoryProvider).fetchCurricula();
    } on ForbiddenError catch (error) {
      if (error.isSchoolSuspended && ref.mounted) {
        ref.read(schoolSuspensionProvider.notifier).confirm();
      }
      rethrow;
    }
  }
}

/// `retry: null` turns off Riverpod's automatic exponential retry, matching the
/// profile: a failed load is shown with an explicit "Try again" (and a
/// pull-to-refresh), rather than re-issuing the call behind the user's back —
/// pointlessly so against a suspended school, which 403s every time.
final AsyncNotifierProvider<LibraryController, List<CurriculumEntity>>
    libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, List<CurriculumEntity>>(
  LibraryController.new,
  retry: (int retryCount, Object error) => null,
);
