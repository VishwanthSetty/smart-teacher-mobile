import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/pagination/paged_list_state.dart';
import 'package:smart_teacher_mobile/src/core/pagination/paginated_result.dart';

/// PRD §6.5 — the one paginated envelope, and the state that accumulates it.
void main() {
  Map<String, dynamic> row(String id) => <String, dynamic>{'id': id};
  String id(Map<String, dynamic> json) => json['id']! as String;

  PaginatedResult<String> parse(
    dynamic data, {
    int page = 1,
    int limit = 20,
  }) {
    return PaginatedResult<String>.fromJson(data, id, page: page, limit: limit);
  }

  group('limits (PRD §5.5.2)', () {
    test('clamps a limit above the server ceiling of 100', () {
      expect(PaginationConstants.resolveLimit(500), 100);
      expect(PaginationConstants.resolveLimit(20), 20);
      expect(PaginationConstants.resolveLimit(0), 1);
    });

    test('pages start at one', () {
      expect(PaginationConstants.resolvePage(0), 1);
      expect(PaginationConstants.resolvePage(-3), 1);
      expect(PaginationConstants.resolvePage(4), 4);
    });

    test('the default limit is the PRD default', () {
      expect(PaginationConstants.defaultLimit, 20);
    });
  });

  group('envelope parsing', () {
    test('reads rows and counters from a nested meta object', () {
      final PaginatedResult<String> result = parse(<String, dynamic>{
        'data': <Map<String, dynamic>>[row('a'), row('b')],
        'meta': <String, dynamic>{
          'page': 2,
          'limit': 2,
          'total': 6,
          'totalPages': 3,
        },
      });

      expect(result.items, <String>['a', 'b']);
      expect(result.page, 2);
      expect(result.total, 6);
      expect(result.hasMore, isTrue);
      expect(result.nextPage, 3);
    });

    test('reads counters sitting alongside the rows', () {
      final PaginatedResult<String> result = parse(<String, dynamic>{
        'items': <Map<String, dynamic>>[row('a')],
        'page': 1,
        'limit': 20,
        'total': 1,
      });

      expect(result.items, <String>['a']);
      expect(result.hasMore, isFalse);
    });

    test('a bare array is one full page', () {
      // The PRD names the response type but not its keys (§8.5 documents the
      // row) — an endpoint that answers with a plain array must still render.
      final PaginatedResult<String> result =
          parse(<Map<String, dynamic>>[row('a'), row('b')]);

      expect(result.items, <String>['a', 'b']);
      expect(result.total, 2);
      expect(result.hasMore, isFalse);
    });

    test('an unrecognised body yields an empty page rather than throwing', () {
      expect(parse('<html>502</html>').items, isEmpty);
      expect(parse(null).hasMore, isFalse);
    });

    test('a row that is not an object is dropped, not fatal', () {
      final PaginatedResult<String> result = parse(<String, dynamic>{
        'data': <dynamic>[row('a'), 'nonsense', row('b')],
        'total': 2,
      });

      expect(result.items, <String>['a', 'b']);
    });

    test('string counters from a loosely-typed server still count', () {
      final PaginatedResult<String> result = parse(<String, dynamic>{
        'data': <Map<String, dynamic>>[row('a')],
        'meta': <String, dynamic>{'page': '2', 'total': '40', 'limit': '20'},
      });

      expect(result.page, 2);
      expect(result.total, 40);
    });
  });

  group('hasMore precedence', () {
    test("the server's own flag wins over the counters", () {
      final PaginatedResult<String> result = parse(<String, dynamic>{
        'data': <Map<String, dynamic>>[row('a')],
        'meta': <String, dynamic>{'total': 99, 'hasMore': false},
      });

      expect(result.hasMore, isFalse);
    });

    test('a page count beats a row count', () {
      final PaginatedResult<String> result = parse(
        <String, dynamic>{
          'data': <Map<String, dynamic>>[row('a')],
          'meta': <String, dynamic>{'totalPages': 1, 'total': 999},
        },
        page: 1,
      );

      expect(result.hasMore, isFalse);
    });

    test('falls back to a full page meaning there is probably another', () {
      // No counters at all. A wrong guess here costs one request answering
      // `[]`; guessing the other way would silently hide rows.
      final PaginatedResult<String> full = parse(
        <String, dynamic>{
          'data': <Map<String, dynamic>>[row('a'), row('b')],
        },
        limit: 2,
      );
      final PaginatedResult<String> partial = parse(
        <String, dynamic>{
          'data': <Map<String, dynamic>>[row('a')],
        },
        limit: 2,
      );

      expect(full.hasMore, isTrue);
      expect(partial.hasMore, isFalse);
    });
  });

  group('PagedListState', () {
    PaginatedResult<String> page(
      List<String> items, {
      required int number,
      bool hasMore = true,
    }) {
      return PaginatedResult<String>(
        items: items,
        page: number,
        limit: 2,
        hasMore: hasMore,
      );
    }

    test('appends the next page after the rows already held', () {
      final PagedListState<String> first = PagedListState<String>.firstPage(
        page(<String>['a', 'b'], number: 1),
      );

      final PagedListState<String> second = first.appendPage(
        page(<String>['c'], number: 2, hasMore: false),
        identity: (String item) => item,
      );

      expect(second.items, <String>['a', 'b', 'c']);
      expect(second.hasMore, isFalse);
      expect(second.nextPage, 3);
    });

    test('drops a row the previous page already carried', () {
      // A roster is a moving table: a student added between page 1 and page 2
      // shifts the offsets, and the same row arrives twice.
      final PagedListState<String> first = PagedListState<String>.firstPage(
        page(<String>['a', 'b'], number: 1),
      );

      final PagedListState<String> second = first.appendPage(
        page(<String>['b', 'c'], number: 2),
        identity: (String item) => item,
      );

      expect(second.items, <String>['a', 'b', 'c']);
    });

    test('a failed later page keeps every row already on screen', () {
      final PagedListState<String> loaded = PagedListState<String>.firstPage(
        page(<String>['a', 'b'], number: 1),
      );

      final PagedListState<String> failed = loaded.failedToLoadMore(
        const NetworkError(message: 'Could not reach the server.'),
      );

      expect(failed.items, <String>['a', 'b']);
      expect(failed.loadMoreError, isA<NetworkError>());
      expect(failed.isLoadingMore, isFalse);
      // Still true: the page that failed is still out there to be retried.
      expect(failed.hasMore, isTrue);
    });

    test('loading a later page is a footer, not a replacement', () {
      final PagedListState<String> loading =
          PagedListState<String>.firstPage(page(<String>['a'], number: 1))
              .loadingMore();

      expect(loading.items, <String>['a']);
      expect(loading.isLoadingMore, isTrue);
      expect(loading.hasFooter, isTrue);
    });

    test('carries a total forward when a later page omits it', () {
      final PagedListState<String> first = PagedListState<String>.firstPage(
        const PaginatedResult<String>(
          items: <String>['a'],
          page: 1,
          limit: 1,
          total: 3,
        ),
      );

      final PagedListState<String> second = first.appendPage(
        const PaginatedResult<String>(items: <String>['b'], page: 2, limit: 1),
        identity: (String item) => item,
      );

      expect(second.total, 3);
    });
  });
}
