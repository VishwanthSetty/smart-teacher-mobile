import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/section_repository.dart';
import '../domain/section_entity.dart';

/// The section lookup behind the roster's filter picker (PRD §5.5.3).
///
/// Shaped like `LibraryController` — always fetches in [build], the same
/// `refresh()`, the same suppressed automatic retry — with one deliberate
/// difference: it is **not** auto-disposing. A picker is opened and dismissed
/// repeatedly over one visit to the roster, and a school's section list is
/// close to static; re-fetching it on every dismissal would be a request per
/// tap for an answer that hasn't changed. It is held for the session instead,
/// and `refresh()` is there for the cases that matter.
///
/// It takes no arguments and reads no role: `GET /sections` answers with the
/// caller's school, and narrowing the picker to the sections a teacher
/// personally teaches (§5.5.2's suggested *default*) is a client-side choice
/// the roster makes from `/teacher-assignments` ids — not a narrowing of this
/// list, which is also what a teacher browsing beyond their own classes needs.
///
/// A suspension-flavoured `403` is **not** confirmed on the latch from here,
/// for the same reason as `MyClassesController`: `SuspensionInterceptor`
/// already observes this call, so self-reporting would turn one `403` into the
/// two-in-a-row it treats as corroboration — and this endpoint is role-gated
/// (§8.6) rather than entitlement-scoped, so its `403` has an innocent reading
/// `/curricula`'s does not.
class SectionsController extends AsyncNotifier<List<SectionEntity>> {
  /// Guards against a second refresh landing while the first is still in
  /// flight.
  bool _refreshing = false;

  @override
  Future<List<SectionEntity>> build() {
    return ref.read(sectionRepositoryProvider).fetchSections();
  }

  /// Re-reads the list — for the "Try again" a consumer offers on the error
  /// state, and for a pull-to-refresh on whatever screen hosts the picker.
  ///
  /// The current state is left alone until the call answers, so a populated
  /// picker keeps its options instead of blanking out. A failure lands as an
  /// error state rather than being thrown at the caller.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<SectionEntity>> next = await AsyncValue.guard(
        () => ref.read(sectionRepositoryProvider).fetchSections(),
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }
}

/// `retry: null` turns off Riverpod's automatic exponential retry, matching the
/// rest of the app: a failed load is shown with an explicit "Try again" rather
/// than re-issued behind the user's back — pointlessly so against a suspended
/// school, which 403s every time.
final AsyncNotifierProvider<SectionsController, List<SectionEntity>>
    sectionsControllerProvider =
    AsyncNotifierProvider<SectionsController, List<SectionEntity>>(
  SectionsController.new,
  retry: (int retryCount, Object error) => null,
);
