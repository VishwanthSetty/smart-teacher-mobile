import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/pagination/cursor_paged_state.dart';
import '../data/library_search_repository.dart';
import '../domain/search_query.dart';
import '../domain/search_result_entity.dart';

/// How long the field waits after the last keystroke (mobile plan §5.5).
const Duration searchDebounce = Duration(milliseconds: 300);

/// The live query. Lives in its own notifier for the same reason
/// `rosterQueryProvider` does: the controller *watches* it, so **changing a
/// filter restarts from the first page by construction** rather than by
/// remembering to reset a cursor.
///
/// Debouncing is deliberately **not** here. Every state change on this notifier
/// is meant to reach the network; the 300ms wait belongs to the text field,
/// which is the only thing that produces changes faster than a request.
class SearchQueryNotifier extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();

  void setTerm(String term) {
    // `SearchQuery` compares on the trimmed term, so a trailing space costs no
    // request — the same trade `RosterQuery` makes.
    final SearchQuery next = state.copyWith(term: term);
    if (next != state) {
      state = next;
    }
  }

  void apply(SearchQuery query) {
    if (query != state) {
      state = query;
    }
  }

  void clearFilters() => apply(state.withoutFilters());
}

/// The search results (mobile plan §5.5).
///
/// Auto-disposing: search is a screen a user visits, uses and leaves, and
/// holding a result set for the session buys nothing.
///
/// An **empty query runs no request at all** and resolves to an empty page.
/// `/library/search` with no `q` and no filters returns the first twenty rows
/// of the whole library, which is the Library tab's answer, not this screen's —
/// and showing it would make an untouched search box look like a result set.
///
/// Paging follows the same split as history: the first page is the
/// `AsyncValue`, every page after it is `isLoadingMore` / `loadMoreError`
/// *inside* the data, so a failed page four can never blank pages one to three.
class LibrarySearchController
    extends AsyncNotifier<CursorPagedState<SearchResultEntity>> {
  /// Rises on every query change. A page still in flight when the query changes
  /// is dropped rather than appended to a list that has since been re-queried.
  int _generation = 0;
  bool _loadingMore = false;

  @override
  Future<CursorPagedState<SearchResultEntity>> build() async {
    ref.watch(searchQueryProvider);
    _generation++;
    return _firstPage();
  }

  Future<void> refresh() async {
    final int generation = ++_generation;
    final AsyncValue<CursorPagedState<SearchResultEntity>> next =
        await AsyncValue.guard(_firstPage);
    if (ref.mounted && generation == _generation) {
      state = next;
    }
  }

  Future<void> loadMore() async {
    final CursorPagedState<SearchResultEntity>? current = state.value;
    if (current == null ||
        _loadingMore ||
        !current.hasMore ||
        current.cursor == null) {
      return;
    }
    _loadingMore = true;
    final int generation = _generation;
    state = AsyncData<CursorPagedState<SearchResultEntity>>(
      current.loadingMore(),
    );

    try {
      final List<SearchResultEntity> page = await ref
          .read(librarySearchRepositoryProvider)
          .search(ref.read(searchQueryProvider), cursor: current.cursor);
      if (!ref.mounted || generation != _generation) {
        return;
      }
      state = AsyncData<CursorPagedState<SearchResultEntity>>(
        current.appendPage(
          page,
          limit: searchPageLimit,
          identity: (SearchResultEntity row) => row.id,
          cursorOf: (SearchResultEntity row) => row.id,
        ),
      );
    } on AppError catch (error) {
      if (ref.mounted && generation == _generation) {
        state = AsyncData<CursorPagedState<SearchResultEntity>>(
          current.failedToLoadMore(error),
        );
      }
    } finally {
      _loadingMore = false;
    }
  }

  Future<CursorPagedState<SearchResultEntity>> _firstPage() async {
    final SearchQuery query = ref.read(searchQueryProvider);
    if (!query.isRunnable) {
      return const CursorPagedState<SearchResultEntity>();
    }
    final List<SearchResultEntity> page = await ref
        .read(librarySearchRepositoryProvider)
        .search(query);
    return CursorPagedState<SearchResultEntity>.firstPage(
      page,
      limit: searchPageLimit,
      cursorOf: (SearchResultEntity row) => row.id,
    );
  }
}

final NotifierProvider<SearchQueryNotifier, SearchQuery> searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, SearchQuery>(
      SearchQueryNotifier.new,
    );

final AsyncNotifierProvider<
  LibrarySearchController,
  CursorPagedState<SearchResultEntity>
>
librarySearchControllerProvider =
    AsyncNotifierProvider.autoDispose<
      LibrarySearchController,
      CursorPagedState<SearchResultEntity>
    >(
      LibrarySearchController.new,
      retry: (int retryCount, Object error) => null,
    );
