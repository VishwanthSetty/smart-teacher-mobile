import 'package:flutter_riverpod/flutter_riverpod.dart';
// The only place in the app that needs a *family* provider so far, and the
// family types live outside the default export surface.
import 'package:flutter_riverpod/misc.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../data/content_tree_repository.dart';
import '../domain/content_node_entity.dart';

/// Backs the curriculum tree (PRD §5.4.2), one instance per curriculum id.
///
/// Shaped like [LibraryController]: always fetches in `build` (nothing earlier
/// caches a tree), the same `refresh()` for pull-to-refresh and "Try again",
/// and the same suppressed automatic retry.
///
/// A `403` read as a suspension is confirmed on the *first* answer rather than
/// waiting for the interceptor's two-in-a-row corroboration — for a sharper
/// reason than the library's. The interceptor corroborates because one
/// suspension-flavoured `403` can really be an entitlement refusal; but this
/// endpoint answers entitlement refusals with `404`, by policy (§4). A `403`
/// from here therefore cannot be the narrow refusal the threshold exists to
/// guard against.
class CurriculumTreeController extends AsyncNotifier<ContentTreeEntity> {
  CurriculumTreeController(this.curriculumId);

  final String curriculumId;

  /// Guards against a second pull landing while the first is still in flight.
  bool _refreshing = false;

  @override
  Future<ContentTreeEntity> build() => _fetch();

  /// Pull-to-refresh, and the "Try again" action on the error state.
  ///
  /// The current state is left alone until the call answers, so an expanded
  /// tree stays on screen instead of blanking out mid-gesture.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<ContentTreeEntity> next = await AsyncValue.guard(_fetch);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<ContentTreeEntity> _fetch() async {
    try {
      return await ref.read(contentTreeRepositoryProvider).fetchTree(
            curriculumId,
          );
    } on ForbiddenError catch (error) {
      if (error.isSchoolSuspended && ref.mounted) {
        ref.read(schoolSuspensionProvider.notifier).confirm();
      }
      rethrow;
    }
  }
}

/// Auto-disposing, unlike the library's single controller: this one is a family
/// keyed by curriculum id, so without it every curriculum a user opens would
/// keep its whole tree alive for the rest of the session. The screen watching
/// it holds it for as long as it is on the stack, and popping back to the
/// library is exactly when a stale tree stops being worth keeping.
///
/// `retry: null` matches the rest of the app: a failed load is shown with an
/// explicit "Try again" rather than re-issued behind the user's back — and a
/// `404` here is a final answer, not a transient one worth re-asking.
final AsyncNotifierProviderFamily<CurriculumTreeController, ContentTreeEntity,
        String> curriculumTreeControllerProvider =
    AsyncNotifierProvider.autoDispose
        .family<CurriculumTreeController, ContentTreeEntity, String>(
  CurriculumTreeController.new,
  retry: (int retryCount, Object error) => null,
);
