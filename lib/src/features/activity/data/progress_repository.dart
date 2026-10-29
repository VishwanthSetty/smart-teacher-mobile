import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/sync/watch_interval.dart';
import '../domain/progress_summary_entity.dart';
import '../domain/resource_activity_entity.dart';

/// The progress write surface (backend plan §5.1).
///
/// **Nothing in presentation calls this directly.** Every write goes through
/// the outbox, which owns retry, coalescing and the discard rules; a screen
/// that called a method here would grow its own ad-hoc retry, which is the
/// duplication the outbox exists to prevent (mobile plan §2.2). The one
/// exception is [fetchSummary], a read.
///
/// Progress is not a back door into the library: each write resolves its
/// resource through the same scope service the player does, so a beat for an
/// unreachable video answers `404` exactly as `GET /videos/:id` would.
abstract class ProgressRepository {
  /// `PUT /me/progress/videos/:id` — the playback heartbeat.
  ///
  /// Sends **intervals actually played**, never a computed percentage: the
  /// union is the server's job, and a client-computed percent would be
  /// unverifiable and forgeable (backend plan §3.1).
  Future<ResourceActivityEntity> updateVideoProgress({
    required String videoId,
    required int positionSecs,
    required List<WatchInterval> intervals,
    required DateTime clientUpdatedAt,
  });

  /// `PUT /me/progress/documents/:id` — position only.
  ///
  /// This can never complete a document. It sets `IN_PROGRESS` and nothing
  /// else, because opening a PDF is not reading it.
  Future<ResourceActivityEntity> updateDocumentProgress({
    required String documentId,
    required int lastPage,
    required DateTime clientUpdatedAt,
    int? pageCount,
  });

  /// `POST /me/progress/documents/:id/complete` — the learner's explicit
  /// assertion, and the **only** way a document reaches `COMPLETED`.
  Future<ResourceActivityEntity> markDocumentComplete(String documentId);

  /// `DELETE /me/progress/documents/:id/complete` — students change their
  /// minds, and the teacher's report must reflect reality.
  Future<ResourceActivityEntity> unmarkDocumentComplete(String documentId);

  /// `GET /me/progress/summary` — per-subject rollup over the actor's scope.
  Future<List<ProgressSummaryEntity>> fetchSummary();
}

class DioProgressRepository implements ProgressRepository {
  const DioProgressRepository(this._dio);

  final Dio _dio;

  static const String videoProgressPath = '/me/progress/videos';
  static const String documentProgressPath = '/me/progress/documents';
  static const String summaryPath = '/me/progress/summary';

  @override
  Future<ResourceActivityEntity> updateVideoProgress({
    required String videoId,
    required int positionSecs,
    required List<WatchInterval> intervals,
    required DateTime clientUpdatedAt,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.put<dynamic>(
        '$videoProgressPath/${Uri.encodeComponent(videoId)}',
        data: <String, dynamic>{
          // Clamped at zero: the DTO is `@Min(0)`, and a negative position
          // from a player reporting mid-seek would be a 400, not a beat.
          'positionSecs': positionSecs < 0 ? 0 : positionSecs,
          'intervals': intervals
              .map((WatchInterval interval) => interval.toJson())
              .toList(),
          'clientUpdatedAt': clientUpdatedAt.toUtc().toIso8601String(),
        },
      );
      return _parseActivity(response.data);
    });
  }

  @override
  Future<ResourceActivityEntity> updateDocumentProgress({
    required String documentId,
    required int lastPage,
    required DateTime clientUpdatedAt,
    int? pageCount,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.put<dynamic>(
        '$documentProgressPath/${Uri.encodeComponent(documentId)}',
        data: <String, dynamic>{
          // `@Min(1)` server-side — pages are 1-based, and a reader reporting
          // page 0 before its first settle must not become a validation error.
          'lastPage': lastPage < 1 ? 1 : lastPage,
          if (pageCount != null && pageCount > 0) 'pageCount': pageCount,
          'clientUpdatedAt': clientUpdatedAt.toUtc().toIso8601String(),
        },
      );
      return _parseActivity(response.data);
    });
  }

  @override
  Future<ResourceActivityEntity> markDocumentComplete(String documentId) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '$documentProgressPath/${Uri.encodeComponent(documentId)}/complete',
      );
      return _parseActivity(response.data);
    });
  }

  @override
  Future<ResourceActivityEntity> unmarkDocumentComplete(String documentId) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.delete<dynamic>(
        '$documentProgressPath/${Uri.encodeComponent(documentId)}/complete',
      );
      return _parseActivity(response.data);
    });
  }

  @override
  Future<List<ProgressSummaryEntity>> fetchSummary() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(summaryPath);
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <ProgressSummaryEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(ProgressSummaryEntity.fromJson)
          .toList(growable: false);
    });
  }
}

/// The progress endpoints all answer with one activity row.
///
/// A non-object body is a contract break rather than a degradable case — the
/// caller needs the server's `status` and `percent` to reconcile the cache, and
/// a silent empty entity would write "0%, in progress" over a completed row.
ResourceActivityEntity _parseActivity(dynamic data) {
  if (data is! Map<String, dynamic>) {
    throw const UnknownError(
      message: 'Something went wrong. Please try again.',
    );
  }
  return ResourceActivityEntity.fromJson(data);
}

final Provider<ProgressRepository> progressRepositoryProvider =
    Provider<ProgressRepository>(
      (Ref ref) => DioProgressRepository(ref.watch(dioProvider)),
    );
