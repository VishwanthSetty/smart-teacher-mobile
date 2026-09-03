import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/document_download_entity.dart';

void main() {
  test('parses only the existing whole-file download response', () {
    final DocumentDownloadEntity download =
        DocumentDownloadEntity.fromJson(<String, dynamic>{
          'url': 'https://s3.example.test/worksheet.pdf?signature=abc',
          'expiresInSecs': 300,
          'fileName': 'worksheet.pdf',
        });

    expect(download.url, contains('signature=abc'));
    expect(download.expiresInSecs, 300);
    expect(download.fileName, 'worksheet.pdf');
    expect(download.toJson().keys, <String>{
      'url',
      'expiresInSecs',
      'fileName',
    });
  });
}
