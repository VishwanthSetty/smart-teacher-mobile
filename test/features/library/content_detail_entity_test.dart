import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/content_detail_entity.dart';

void main() {
  test('VideoEntity parses the public detail response', () {
    final VideoEntity video = VideoEntity.fromJson(<String, dynamic>{
      'id': 'video-7',
      'title': 'What is a fraction?',
      'description': 'A short introduction.',
      'durationSecs': 125,
      'contentNodeId': 'node-2',
      'contentNodeTitle': 'Fractions',
      'curriculumId': 'curriculum-1',
      'gradeLevelId': 'grade-5',
      'subjectId': 'maths',
    });

    expect(video.id, 'video-7');
    expect(video.durationSecs, 125);
    expect(video.contentNodeTitle, 'Fractions');
  });

  test('DocumentEntity parses the public detail response', () {
    final DocumentEntity document = DocumentEntity.fromJson(<String, dynamic>{
      'id': 'document-7',
      'title': 'Worksheet 1',
      'description': null,
      'contentNodeId': 'node-2',
      'contentNodeTitle': 'Fractions',
      'curriculumId': 'curriculum-1',
      'gradeLevelId': 'grade-5',
      'subjectId': 'maths',
    });

    expect(document.id, 'document-7');
    expect(document.description, isNull);
    expect(document.contentNodeTitle, 'Fractions');
  });
}
