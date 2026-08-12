import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/curriculum_entity.dart';

void main() {
  group('CurriculumEntity.fromJson (PRD §8.3)', () {
    test('parses the documented payload', () {
      final CurriculumEntity curriculum =
          CurriculumEntity.fromJson(<String, dynamic>{
        'audience': 'STUDENT',
        'id': 'curriculum-1',
        'gradeLevelId': 'grade-5',
        'gradeLevelName': 'Grade 5',
        'subjectId': 'subject-math',
        'subjectName': 'Mathematics',
        'schemaId': 'schema-1',
        'schemaName': 'CBSE',
        'status': 'PUBLISHED',
        'publishedAt': '2026-01-01T00:00:00Z',
        'nodeCount': 12,
        'videoCount': 8,
        'documentCount': 3,
      });

      expect(curriculum.id, 'curriculum-1');
      expect(curriculum.audience, CurriculumAudience.student);
      expect(curriculum.status, CurriculumStatus.published);
      expect(curriculum.gradeLevelName, 'Grade 5');
      expect(curriculum.subjectName, 'Mathematics');
      expect(curriculum.publishedAt, DateTime.utc(2026));
      expect(curriculum.nodeCount, 12);
      expect(curriculum.videoCount, 8);
      expect(curriculum.documentCount, 3);
      expect(curriculum.isEmpty, isFalse);
    });

    test('an unrecognised audience or status falls back to unknown', () {
      // A value added to the API later must not fail the whole list.
      final CurriculumEntity curriculum = CurriculumEntity.fromJson(
        _minimalJson(<String, dynamic>{
          'audience': 'PARENT',
          'status': 'PENDING_REVIEW',
        }),
      );

      expect(curriculum.audience, CurriculumAudience.unknown);
      expect(curriculum.status, CurriculumStatus.unknown);
    });

    test('missing counts, schema and publishedAt are tolerated', () {
      final CurriculumEntity curriculum =
          CurriculumEntity.fromJson(_minimalJson());

      expect(curriculum.nodeCount, 0);
      expect(curriculum.videoCount, 0);
      expect(curriculum.documentCount, 0);
      expect(curriculum.schemaId, isNull);
      expect(curriculum.schemaName, isNull);
      expect(curriculum.publishedAt, isNull);
      // A curriculum the school is entitled to that has nothing in it — a real
      // state, and not the same thing as an empty library (§6.4).
      expect(curriculum.isEmpty, isTrue);
    });
  });
}

Map<String, dynamic> _minimalJson([Map<String, dynamic> overrides = const {}]) {
  return <String, dynamic>{
    'id': 'curriculum-1',
    'gradeLevelId': 'grade-5',
    'gradeLevelName': 'Grade 5',
    'subjectId': 'subject-math',
    'subjectName': 'Mathematics',
    ...overrides,
  };
}
