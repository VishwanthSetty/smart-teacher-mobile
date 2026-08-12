import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/library/data/content_detail_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/content_detail_entity.dart';

class FakeContentDetailRepository implements ContentDetailRepository {
  FakeContentDetailRepository({
    VideoEntity? video,
    DocumentEntity? document,
    this.error,
  }) : video = video ?? buildVideo(),
       document = document ?? buildDocument();

  VideoEntity video;
  DocumentEntity document;
  AppError? error;

  int videoCallCount = 0;
  int documentCallCount = 0;
  final List<String> requestedVideoIds = <String>[];
  final List<String> requestedDocumentIds = <String>[];

  @override
  Future<VideoEntity> fetchVideo(String videoId) async {
    videoCallCount++;
    requestedVideoIds.add(videoId);
    if (error != null) {
      throw error!;
    }
    return video;
  }

  @override
  Future<DocumentEntity> fetchDocument(String documentId) async {
    documentCallCount++;
    requestedDocumentIds.add(documentId);
    if (error != null) {
      throw error!;
    }
    return document;
  }
}

VideoEntity buildVideo({
  String id = 'video-1',
  String title = 'Video title',
  String? description = 'Video description',
  int? durationSecs = 90,
  String contentNodeId = 'node-1',
  String contentNodeTitle = 'Chapter 1',
  String curriculumId = 'curriculum-1',
  String gradeLevelId = 'grade-1',
  String subjectId = 'subject-1',
}) {
  return VideoEntity(
    id: id,
    title: title,
    description: description,
    durationSecs: durationSecs,
    contentNodeId: contentNodeId,
    contentNodeTitle: contentNodeTitle,
    curriculumId: curriculumId,
    gradeLevelId: gradeLevelId,
    subjectId: subjectId,
  );
}

DocumentEntity buildDocument({
  String id = 'document-1',
  String title = 'Document title',
  String? description = 'Document description',
  String contentNodeId = 'node-1',
  String contentNodeTitle = 'Chapter 1',
  String curriculumId = 'curriculum-1',
  String gradeLevelId = 'grade-1',
  String subjectId = 'subject-1',
}) {
  return DocumentEntity(
    id: id,
    title: title,
    description: description,
    contentNodeId: contentNodeId,
    contentNodeTitle: contentNodeTitle,
    curriculumId: curriculumId,
    gradeLevelId: gradeLevelId,
    subjectId: subjectId,
  );
}
