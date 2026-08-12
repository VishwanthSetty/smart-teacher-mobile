import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/pagination/paged_list_state.dart';
import '../../../core/pagination/paginated_result.dart';
import '../data/student_repository.dart';
import '../domain/student_entity.dart';
import 'roster_query.dart';

/// Backs the roster (PRD §5.5.2) — the app's one paginated list (§6.5).
///
/// Shaped like `LibraryController` for the first page (always fetches in
/// [build], the same `refresh()`, the same suppressed automatic retry), with
/// the two things pagination adds:
///
/// * [build] **watches** [rosterQueryProvider], so changing the search term or
///   the section filter restarts from page one by construction. There is no
///   "reset the page counter" step to forget, and a stale page can't be
///   appended to a list that has since been re-queried.
/// * [loadMore] appends *into the existing data* rather than through the
///   `AsyncValue`, so a failed page four leaves pages one to three on screen.
///   See [PagedListState] for that split.
///
/// It does not read `MeEntity.role` and does not narrow by teacher. §5.5.2
/// *recommends* defaulting the section filter to a section the teacher actually
/// teaches; that default is deliberately not applied here. Silently showing a
/// subset of the school's students on first open is indistinguishable, to the
/// person looking at it, from the school having that few students — and the
/// filter it would need (`/teacher-assignments`, §5.5.1) would make the first
/// page wait on a second endpoint that may itself be empty or failing. The
/// picker starts at "All sections" and narrowing is one tap away.
///
/// Like My Classes and the section lookup, and unlike the library, a
/// suspension-flavoured `403` here does **not** `confirm()` the suspension
/// latch: `SuspensionInterceptor` already observes this call, so self-reporting
/// would turn one `403` into the two-in-a-row it treats as corroboration, and
/// `/students` is role-gated (§8.6) rather than entitlement-scoped, so its
/// `403` has an innocent reading `/curricula`'s does not.
class RosterController extends AsyncNotifier<PagedListState<StudentEntity>> {
  /// Rows per request — the PRD's default (§5.5.2). Small enough that the first
  /// screenful arrives quickly, and the widget asks for the next one before the
  /// user reaches the bottom.
  static const int pageSize = PaginationConstants.defaultLimit;

  /// Bumped on every [build]. A page still in flight when the query changes
  /// belongs to the previous list and is dropped rather than appended.
  int _generation = 0;

  bool _refreshing = false;

  @override
  Future<PagedListState<StudentEntity>> build() async {
    final RosterQuery query = ref.watch(rosterQueryProvider);
    _generation++;

    return PagedListState<StudentEntity>.firstPage(
      await _fetch(query, PaginationConstants.firstPage),
    );
  }

  /// Fetches the next page and appends it.
  ///
  /// Silently does nothing unless there is a loaded page, more behind it, and
  /// nothing already in flight — the widget guards the same conditions, and
  /// both matter: scroll physics can fire the trigger repeatedly, and a
  /// pull-to-refresh can land in the middle of one of these.
  Future<void> loadMore() async {
    final PagedListState<StudentEntity>? current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        _refreshing) {
      return;
    }

    final int generation = _generation;
    final RosterQuery query = ref.read(rosterQueryProvider);
    final int page = current.nextPage;

    state = AsyncData<PagedListState<StudentEntity>>(current.loadingMore());

    try {
      final PaginatedResult<StudentEntity> next = await _fetch(query, page);
      final PagedListState<StudentEntity>? latest = state.value;
      if (!_isCurrent(generation) || latest == null) {
        return;
      }

      state = AsyncData<PagedListState<StudentEntity>>(
        latest.appendPage(next, identity: (StudentEntity s) => s.id),
      );
    } on Object catch (error) {
      final PagedListState<StudentEntity>? latest = state.value;
      if (!_isCurrent(generation) || latest == null) {
        return;
      }

      // Lands in the footer, not over the list: the rows already fetched are
      // still perfectly good, and the retry is the user's to take.
      state = AsyncData<PagedListState<StudentEntity>>(
        latest.failedToLoadMore(AppError.from(error)),
      );
    }
  }

  /// Pull-to-refresh, and the "Try again" on the first-page error state.
  ///
  /// Re-reads **page one only**, deliberately discarding pages already scrolled
  /// past: the alternative — re-fetching every page held — multiplies requests
  /// on a moving table for rows the user has scrolled away from. The current
  /// state is left alone until the call answers, so a populated list doesn't
  /// blank out mid-gesture.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    final int generation = _generation;
    final RosterQuery query = ref.read(rosterQueryProvider);

    try {
      final AsyncValue<PagedListState<StudentEntity>> next =
          await AsyncValue.guard(
        () async => PagedListState<StudentEntity>.firstPage(
          await _fetch(query, PaginationConstants.firstPage),
        ),
      );

      if (_isCurrent(generation)) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  Future<PaginatedResult<StudentEntity>> _fetch(RosterQuery query, int page) {
    return ref.read(studentRepositoryProvider).fetchStudents(
          page: page,
          limit: pageSize,
          search: query.term,
          sectionId: query.sectionId,
          status: query.status,
        );
  }
}

/// `retry: null` turns off Riverpod's automatic exponential retry, matching the
/// rest of the app: a failed load is shown with an explicit "Try again" rather
/// than re-issued behind the user's back — pointlessly so against a suspended
/// school, which 403s every time.
///
/// Not auto-disposing, for the same reason as [rosterQueryProvider]: the roster
/// is a tab in the shell's `IndexedStack`, and dropping its pages on every tab
/// switch would re-fetch page one — and lose the user's scroll position — every
/// time they glanced at My Classes.
final AsyncNotifierProvider<RosterController, PagedListState<StudentEntity>>
    rosterControllerProvider = AsyncNotifierProvider<RosterController,
        PagedListState<StudentEntity>>(
  RosterController.new,
  retry: (int retryCount, Object error) => null,
);
