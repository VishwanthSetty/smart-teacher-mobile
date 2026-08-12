import 'package:flutter/foundation.dart';

import '../errors/app_error.dart';
import 'paginated_result.dart';

/// Everything accumulated so far by a paginated screen (PRD §6.5) — the rows
/// from every page fetched, plus what is known about the next one.
///
/// The split between this and the `AsyncValue` wrapping it is the whole design:
///
/// * the **first** page is the screen's `AsyncValue` — loading is a spinner in
///   place of the list, and a failure is an error state with a retry;
/// * **every page after it** is [isLoadingMore] / [loadMoreError] *inside* the
///   data, because the rows already on screen must not be replaced by a spinner
///   or an error when the fetch was only ever additive.
///
/// Collapsing the two would mean a failed page 3 blanking pages 1 and 2, which
/// is the classic infinite-scroll bug this type exists to make unwritable.
@immutable
class PagedListState<T> {
  const PagedListState({
    this.items = const <Never>[],
    this.nextPage = PaginationConstants.firstPage,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.total,
  });

  /// The state after the first page lands.
  PagedListState.firstPage(PaginatedResult<T> page)
      : items = page.items,
        nextPage = page.nextPage,
        hasMore = page.hasMore,
        isLoadingMore = false,
        loadMoreError = null,
        total = page.total;

  /// Every row fetched so far, in server order, oldest page first.
  final List<T> items;

  /// The page number a [appendPage] would ask for.
  final int nextPage;

  final bool hasMore;

  /// A page *after* the first is in flight. Renders as a footer spinner, never
  /// as a replacement for the list.
  final bool isLoadingMore;

  /// The last "load more" failed. Renders as a footer with its own retry —
  /// and, importantly, stops the automatic scroll trigger, so a server that is
  /// down doesn't get hammered once per frame at the bottom of the list.
  final AppError? loadMoreError;

  /// Rows across every page, when the server counts them.
  final int? total;

  bool get isEmpty => items.isEmpty;

  /// Whether the list should show a footer at all.
  bool get hasFooter => isLoadingMore || loadMoreError != null;

  /// Folds a freshly-fetched page onto the rows already held.
  ///
  /// Rows whose identity is already present are dropped. Pagination reads a
  /// moving table: a student added or renamed between page 1 and page 2 shifts
  /// the offsets, and the visible symptom is the same row arriving twice —
  /// which, in a `ListView` keyed by that identity, is a duplicate-key crash
  /// rather than a cosmetic repeat.
  PagedListState<T> appendPage(
    PaginatedResult<T> page, {
    required Object Function(T item) identity,
  }) {
    final Set<Object> seen = items.map(identity).toSet();
    final List<T> merged = <T>[
      ...items,
      ...page.items.where((T item) => seen.add(identity(item))),
    ];

    return PagedListState<T>(
      items: List<T>.unmodifiable(merged),
      nextPage: page.nextPage,
      hasMore: page.hasMore,
      total: page.total ?? total,
    );
  }

  PagedListState<T> loadingMore() => PagedListState<T>(
        items: items,
        nextPage: nextPage,
        hasMore: hasMore,
        isLoadingMore: true,
        total: total,
      );

  PagedListState<T> failedToLoadMore(AppError error) => PagedListState<T>(
        items: items,
        nextPage: nextPage,
        hasMore: hasMore,
        loadMoreError: error,
        total: total,
      );

  @override
  bool operator ==(Object other) {
    return other is PagedListState<T> &&
        listEquals(other.items, items) &&
        other.nextPage == nextPage &&
        other.hasMore == hasMore &&
        other.isLoadingMore == isLoadingMore &&
        other.loadMoreError == loadMoreError &&
        other.total == total;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        nextPage,
        hasMore,
        isLoadingMore,
        loadMoreError,
        total,
      );

  @override
  String toString() => 'PagedListState(items: ${items.length}, '
      'nextPage: $nextPage, hasMore: $hasMore, '
      'isLoadingMore: $isLoadingMore, loadMoreError: $loadMoreError)';
}
