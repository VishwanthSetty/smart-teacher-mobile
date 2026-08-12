import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/content_detail_entity.dart';

/// Entitlement-gated single-item reads for the curriculum tree handoff
/// (PRD §5.4.2–§5.4.3).
///
/// Both endpoints deliberately answer `404` for a missing record and for a
/// record outside the actor's server-computed scope. The repository preserves
/// that answer as [NotFoundError]; it never tries to distinguish the causes.
abstract class ContentDetailRepository {
  /// Throws an [AppError], never a `DioException`.
  Future<VideoEntity> fetchVideo(String videoId);

  /// Throws an [AppError], never a `DioException`.
  Future<DocumentEntity> fetchDocument(String documentId);
}

class DioContentDetailRepository implements ContentDetailRepository {
  const DioContentDetailRepository(this._dio);

  final Dio _dio;

  static String videoPath(String videoId) =>
      '/videos/${Uri.encodeComponent(videoId)}';

  static String documentPath(String documentId) =>
      '/documents/${Uri.encodeComponent(documentId)}';

  @override
  Future<VideoEntity> fetchVideo(String videoId) {
    return guardApiCall(() async {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(videoPath(videoId));
      return VideoEntity.fromJson(response.data ?? <String, dynamic>{});
    });
  }

  @override
  Future<DocumentEntity> fetchDocument(String documentId) {
    return guardApiCall(() async {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(documentPath(documentId));
      return DocumentEntity.fromJson(response.data ?? <String, dynamic>{});
    });
  }
}

final Provider<ContentDetailRepository> contentDetailRepositoryProvider =
    Provider<ContentDetailRepository>(
      (Ref ref) => DioContentDetailRepository(ref.watch(dioProvider)),
    );
