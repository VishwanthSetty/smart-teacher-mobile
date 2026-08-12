import 'package:flutter/foundation.dart';

/// The page/limit contract shared by every paginated call (PRD §6.5).
///
/// There is exactly one such call today — `GET /students` (§5.5.2) — and the
/// PRD is explicit that no other list endpoint gets pagination affordances.
/// The numbers live here rather than in the roster feature so the *limits* and
/// the reusable widget that honours them can't drift apart if a second
/// paginated endpoint ever lands.
class PaginationConstants {
  const PaginationConstants._();

  /// The API's pages are 1-based.
  static const int firstPage = 1;

  /// `limit` when the caller doesn't say (§5.5.2).
  static const int defaultLimit = 20;

  /// The server's ceiling (§5.5.2, §6.5). Asking for more is not a bigger
  /// page — it is an argument the server is free to reject, so the app clamps
  /// rather than finding out.
  static const int maxLimit = 100;

  /// Coerces a caller's `limit` into the range the API accepts.
  static int resolveLimit(int limit) => limit.clamp(1, maxLimit);

  /// Coerces a caller's `page` onto a real page.
  static int resolvePage(int page) => page < firstPage ? firstPage : page;
}

/// One page of a paginated response — the PRD's `PaginatedStudentsEntity`
/// generalised over its row type (§5.5.2, §8.5).
///
/// Deliberately **not** freezed: `freezed`/`json_serializable` don't generate
/// for a generic envelope whose row type is only known at the call site, and
/// the alternative — a concrete `PaginatedStudentsEntity` — would mean writing
/// this parsing again for the second paginated endpoint. The rows themselves
/// are freezed as usual; only the envelope is hand-written, and it carries its
/// own value equality so an unchanged page doesn't churn a `Notifier`.
///
/// [fromJson] is forgiving about the envelope's shape on purpose. The PRD names
/// the response type but never pins its keys (§8.5 documents the *row*), and
/// the same payload is described in the wild as `data`/`items`/`results` with
/// the counters either alongside or nested under `meta`/`pagination`. Guessing
/// wrong should cost a missing count, not a failed screen — so an unrecognised
/// envelope still yields its rows, and [hasMore] falls back to the one signal
/// that is always available: a full page probably has another behind it.
@immutable
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.limit,
    this.total,
    this.totalPages,
    bool? hasMore,
  }) : _hasMore = hasMore;

  /// Parses `data` — an envelope object, or a bare array from an endpoint that
  /// forgot to wrap it — into a page of [T].
  ///
  /// [page] and [limit] are what the app *asked for*; they are used when the
  /// response doesn't echo them back, so the caller can always work out what to
  /// request next.
  factory PaginatedResult.fromJson(
    dynamic data,
    T Function(Map<String, dynamic> json) itemFromJson, {
    required int page,
    required int limit,
  }) {
    if (data is List<dynamic>) {
      // No envelope at all: every row there is, on one page.
      return PaginatedResult<T>(
        items: _mapItems<T>(data, itemFromJson),
        page: page,
        limit: limit,
        total: data.length,
        hasMore: false,
      );
    }

    if (data is! Map<String, dynamic>) {
      return PaginatedResult<T>(
        items: const <Never>[],
        page: page,
        limit: limit,
        total: 0,
        hasMore: false,
      );
    }

    final Map<String, dynamic> meta = _meta(data);
    final List<dynamic> rows = _rows(data);

    return PaginatedResult<T>(
      items: _mapItems<T>(rows, itemFromJson),
      page: _int(meta['page'] ?? meta['currentPage']) ?? page,
      limit: _int(meta['limit'] ?? meta['perPage'] ?? meta['pageSize']) ?? limit,
      total: _int(meta['total'] ?? meta['totalCount'] ?? meta['count']),
      totalPages: _int(meta['totalPages'] ?? meta['pageCount'] ?? meta['pages']),
      hasMore: _bool(meta['hasMore'] ?? meta['hasNextPage'] ?? meta['hasNext']),
    );
  }

  /// This page's rows, in server order.
  final List<T> items;

  /// 1-based, per [PaginationConstants.firstPage].
  final int page;

  final int limit;

  /// Rows across every page, when the server counts them. `null` is not an
  /// error — it only means the UI can't say "12 of 340".
  final int? total;

  final int? totalPages;

  final bool? _hasMore;

  /// Whether asking for [nextPage] is worth doing.
  ///
  /// Preference order — the server's own flag, then a page count, then a row
  /// count, and only as a last resort the shape of this page. That last rule
  /// costs at most one extra request answering `[]`, which is the failure mode
  /// to prefer: stopping early would silently hide rows.
  bool get hasMore {
    final bool? flagged = _hasMore;
    if (flagged != null) {
      return flagged;
    }

    final int? pages = totalPages;
    if (pages != null) {
      return page < pages;
    }

    final int? count = total;
    if (count != null) {
      return page * limit < count;
    }

    return items.length >= limit;
  }

  /// The page to ask for next. Meaningless unless [hasMore].
  int get nextPage => page + 1;

  bool get isEmpty => items.isEmpty;

  @override
  bool operator ==(Object other) {
    return other is PaginatedResult<T> &&
        listEquals(other.items, items) &&
        other.page == page &&
        other.limit == limit &&
        other.total == total &&
        other.totalPages == totalPages &&
        other._hasMore == _hasMore;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        page,
        limit,
        total,
        totalPages,
        _hasMore,
      );

  @override
  String toString() =>
      'PaginatedResult(page: $page, limit: $limit, items: ${items.length}, '
      'total: $total, hasMore: $hasMore)';
}

/// The rows, wherever this envelope keeps them.
List<dynamic> _rows(Map<String, dynamic> data) {
  for (final String key in <String>['data', 'items', 'results', 'rows']) {
    final dynamic value = data[key];
    if (value is List<dynamic>) {
      return value;
    }
  }
  return const <dynamic>[];
}

/// The counters, whether they are nested or sit alongside the rows.
Map<String, dynamic> _meta(Map<String, dynamic> data) {
  for (final String key in <String>['meta', 'pagination', 'page_info']) {
    final dynamic value = data[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }
  return data;
}

/// A row that isn't an object is dropped rather than failing the page — the
/// same tolerance the flat list endpoints already apply.
List<T> _mapItems<T>(
  List<dynamic> rows,
  T Function(Map<String, dynamic> json) itemFromJson,
) {
  return rows
      .whereType<Map<String, dynamic>>()
      .map(itemFromJson)
      .toList(growable: false);
}

int? _int(dynamic value) => switch (value) {
      final int number => number,
      final num number => number.toInt(),
      final String text => int.tryParse(text.trim()),
      _ => null,
    };

bool? _bool(dynamic value) => switch (value) {
      final bool flag => flag,
      'true' => true,
      'false' => false,
      _ => null,
    };
