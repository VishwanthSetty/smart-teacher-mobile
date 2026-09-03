import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/data/document_download_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/document_download_entity.dart';

void main() {
  test(
    'calls the existing download endpoint and parses its response',
    () async {
      final _DocumentDownloadAdapter adapter = _DocumentDownloadAdapter();
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'))
        ..httpClientAdapter = adapter;
      final DioDocumentDownloadRepository repository =
          DioDocumentDownloadRepository(dio);

      final DocumentDownloadEntity download = await repository.fetchDownload(
        'document/7',
      );

      expect(adapter.lastRequest?.path, '/documents/document%2F7/download');
      expect(download.url, contains('signature=abc'));
      expect(download.expiresInSecs, 300);
      expect(download.fileName, 'worksheet.pdf');
    },
  );
}

class _DocumentDownloadAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{
        'url': 'https://s3.example.test/worksheet.pdf?signature=abc',
        'expiresInSecs': 300,
        'fileName': 'worksheet.pdf',
      }),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
