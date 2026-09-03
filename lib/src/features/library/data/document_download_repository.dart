import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/document_download_entity.dart';

/// Mints the existing short-lived, whole-PDF presigned download URL.
abstract class DocumentDownloadRepository {
  /// Throws an [AppError], never a `DioException`.
  Future<DocumentDownloadEntity> fetchDownload(String documentId);
}

class DioDocumentDownloadRepository implements DocumentDownloadRepository {
  const DioDocumentDownloadRepository(this._dio);

  final Dio _dio;

  static String downloadPath(String documentId) =>
      '/documents/${Uri.encodeComponent(documentId)}/download';

  @override
  Future<DocumentDownloadEntity> fetchDownload(String documentId) {
    return guardApiCall(() async {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(downloadPath(documentId));
      return DocumentDownloadEntity.fromJson(
        response.data ?? <String, dynamic>{},
      );
    });
  }
}

final Provider<DocumentDownloadRepository> documentDownloadRepositoryProvider =
    Provider<DocumentDownloadRepository>(
      (Ref ref) => DioDocumentDownloadRepository(ref.watch(dioProvider)),
    );
