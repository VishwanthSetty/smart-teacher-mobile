import 'package:flutter/foundation.dart';

import '../errors/app_error.dart';

/// The cursor-paginated sibling of `PagedListState` (PRD §6.5).
///
/// Same split, for the same reason: the **first** page is the screen's
/// `AsyncValue`, and every page after it is [isLoadingMore] / [loadMoreError]
/// *inside* the data, so a failed page four can never blank pages one to three.
///
/// It is a separate type rather than a generalisation of the page-numbered one
/// because the two disagree on the only question that matters — "is there
/// another page?". A page-numbered endpoint can answer from a total count; a
/// cursor endpoint returns a bare array and can only be asked again. Merging
/// them would mean one of the two lying about [hasMore].
@immutable
class CursorPagedState<T> {
  const CursorPagedState({
    this.items = const <Never>[],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  /// The state after the first page lands.
  ///
  /// [hasMore] is inferred from "a full page probably has another behind it",
  /// which is all a cursor endpoint supports. At worst it costs one extra
  /// request that answers `[]` — the same trade `PaginatedResult` makes as its
  /// last resort.
  CursorPagedState.firstPage(
    List<T> page, {
    required int limit,
    required String? Function(T item) cursorOf,
  }) : items = List<T>.unmodifiable(page),
       cursor = page.isEmpty ? null : cursorOf(page.last),
       hasMore = page.length >= limit,
       isLoadingMore = false,
       loadMoreError = null;

  final List<T> items;

  /// What the next request sends as `?cursor=` — the id of the last row held.
  final String? cursor;

  final bool hasMore;
  final bool isLoadingMore;
  final AppError? loadMoreError;

  bool get isEmpty => items.isEmpty;

  bool get hasFooter => isLoadingMore || loadMoreError != null;

  /// Folds a freshly-fetched page onto the rows already held.
  ///
  /// De-duplicates by identity for the same reason the page-numbered state
  /// does: history is a moving table — a resource touched again between two
  /// requests moves to the top — and the same row arriving twice is a
  /// duplicate-key crash in a keyed `ListView`, not a cosmetic repeat.
  CursorPagedState<T> appendPage(
    List<T> page, {
    required int limit,
    required Object Function(T item) identity,
    required String? Function(T item) cursorOf,
  }) {
    final Set<Object> seen = items.map(identity).toSet();
    final List<T> merged = <T>[
      ...items,
      ...page.where((T item) => seen.add(identity(item))),
    ];

    return CursorPagedState<T>(
      items: List<T>.unmodifiable(merged),
      // The cursor tracks the last row the *server* sent, not the last one
      // kept: a page entirely of duplicates still advances the cursor, or the
      // next request would ask for the same window forever.
      cursor: page.isEmpty ? cursor : cursorOf(page.last),
      hasMore: page.length >= limit,
    );
  }

  CursorPagedState<T> loadingMore() => CursorPagedState<T>(
    items: items,
    cursor: cursor,
    hasMore: hasMore,
    isLoadingMore: true,
  );

  CursorPagedState<T> failedToLoadMore(AppError error) => CursorPagedState<T>(
    items: items,
    cursor: cursor,
    hasMore: hasMore,
    loadMoreError: error,
  );

  @override
  bool operator ==(Object other) =>
      other is CursorPagedState<T> &&
      listEquals(other.items, items) &&
      other.cursor == cursor &&
      other.hasMore == hasMore &&
      other.isLoadingMore == isLoadingMore &&
      other.loadMoreError == loadMoreError;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    cursor,
    hasMore,
    isLoadingMore,
    loadMoreError,
  );

  @override
  String toString() =>
      'CursorPagedState(items: ${items.length}, cursor: $cursor, '
      'hasMore: $hasMore, isLoadingMore: $isLoadingMore, '
      'loadMoreError: $loadMoreError)';
}
