import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/resource_activity_entity.dart';

/// Default page size for `GET /me/activity`. The DTO defaults to 20 and caps
/// at 100; both are the server's numbers, clamped here rather than trusted
/// from a call site.
const int activityPageLimit = 20;
const int activityMaxLimit = 100;

/// The history feed and the continue rail (backend plan §5.1).
///
/// Both are **cursor**-paginated, unlike `/students`, which is the app's only
/// page-numbered endpoint. The cursor is a row id: the server passes it to
/// Prisma's `cursor` with `skip: 1`, so paging asks for "everything after this
/// row" rather than "offset N". That is what makes an infinite scroll stable
/// while the underlying table moves — a newly-touched resource jumping to the
/// top cannot shift a page boundary and duplicate a row.
///
/// Both calls are scoped server-side to the actor's reachable curricula, so an
/// entitlement that lapses simply stops returning those rows. This repository
/// adds no filtering of its own.
abstract class HistoryRepository {
  /// `GET /me/activity?type=&status=&cursor=&limit=`.
  ///
  /// An empty list is a legitimate answer, not an error: a user who has opened
  /// nothing, and a filter that matches nothing, both land there.
  Future<List<ResourceActivityEntity>> fetchHistory({
    ActivityResourceType? type,
    ActivityProgressStatus? status,
    String? cursor,
    int limit,
  });

  /// `GET /me/continue` — `IN_PROGRESS`, newest first, capped at 10 by the
  /// server. Takes no arguments because it accepts none.
  Future<List<ResourceActivityEntity>> fetchContinueLearning();
}

class DioHistoryRepository implements HistoryRepository {
  const DioHistoryRepository(this._dio);

  final Dio _dio;

  static const String activityPath = '/me/activity';
  static const String continuePath = '/me/continue';

  @override
  Future<List<ResourceActivityEntity>> fetchHistory({
    ActivityResourceType? type,
    ActivityProgressStatus? status,
    String? cursor,
    int limit = activityPageLimit,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        activityPath,
        queryParameters: <String, dynamic>{
          'limit': limit.clamp(1, activityMaxLimit),
          // Every blank filter is omitted rather than sent empty, for the same
          // reason the roster omits them: `?status=` is a value the server is
          // free to read as a filter that matches nothing, and that guess
          // should never come from an unselected chip.
          if (type?.wireValue case final String value) 'type': value,
          if (status?.wireValue case final String value) 'status': value,
          if (_trimToNull(cursor) case final String value) 'cursor': value,
        },
      );
      return _parseActivityList(response.data);
    });
  }

  @override
  Future<List<ResourceActivityEntity>> fetchContinueLearning() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(continuePath);
      return _parseActivityList(response.data);
    });
  }
}

/// Both endpoints answer with a bare array.
///
/// A non-list body degrades to empty rather than throwing: unlike a progress
/// write, nothing downstream is reconciled from this, so an odd payload costs
/// an empty feed rather than a wrong one. Individual rows that aren't objects
/// are skipped for the same reason one malformed row must not fail a page.
List<ResourceActivityEntity> _parseActivityList(dynamic data) {
  if (data is! List<dynamic>) {
    return const <ResourceActivityEntity>[];
  }
  return data
      .whereType<Map<String, dynamic>>()
      .map(ResourceActivityEntity.fromJson)
      .toList(growable: false);
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

final Provider<HistoryRepository> historyRepositoryProvider =
    Provider<HistoryRepository>(
      (Ref ref) => DioHistoryRepository(ref.watch(dioProvider)),
    );
