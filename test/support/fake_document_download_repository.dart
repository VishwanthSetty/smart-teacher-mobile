import 'package:smart_teacher_mobile/src/features/library/data/document_download_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/document_download_entity.dart';

class FakeDocumentDownloadRepository implements DocumentDownloadRepository {
  FakeDocumentDownloadRepository({
    List<DocumentDownloadEntity>? downloads,
    this.error,
  }) : downloads = downloads ?? <DocumentDownloadEntity>[buildDownload()];

  final List<DocumentDownloadEntity> downloads;
  Object? error;
  final List<String> requestedDocumentIds = <String>[];

  int get callCount => requestedDocumentIds.length;

  @override
  Future<DocumentDownloadEntity> fetchDownload(String documentId) async {
    requestedDocumentIds.add(documentId);
    final Object? failure = error;
    if (failure != null) {
      throw failure;
    }
    final int index = (callCount - 1).clamp(0, downloads.length - 1).toInt();
    return downloads[index];
  }
}

DocumentDownloadEntity buildDownload({
  String url = 'https://s3.example.test/document.pdf?signature=first',
  int expiresInSecs = 300,
  String fileName = 'worksheet.pdf',
}) => DocumentDownloadEntity(
  url: url,
  expiresInSecs: expiresInSecs,
  fileName: fileName,
);
