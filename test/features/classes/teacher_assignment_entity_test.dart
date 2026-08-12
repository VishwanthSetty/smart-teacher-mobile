import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/classes/domain/teacher_assignment_entity.dart';

void main() {
  group('deserialisation (PRD §8.4)', () {
    test('reads a full row', () {
      final TeacherAssignmentEntity assignment =
          TeacherAssignmentEntity.fromJson(<String, dynamic>{
        'id': 'assignment-1',
        'teacherId': 'user-1',
        'teacherName': 'Asha Rao',
        'teacherEmail': 'asha@springfield.edu',
        'subjectId': 'subject-1',
        'subjectName': 'Mathematics',
        'subjectCode': 'MATH',
        'sectionId': 'section-1',
        'sectionName': 'A',
        'gradeLevelId': 'grade-5',
        'gradeLevelName': 'Grade 5',
        'sectionLabel': 'Grade 5 - A',
        'createdAt': '2026-01-01T00:00:00Z',
      });

      expect(assignment.subjectName, 'Mathematics');
      expect(assignment.sectionLabel, 'Grade 5 - A');
      expect(assignment.isSchoolWide, isFalse);
    });

    test('reads a legacy school-wide grant, where all five are null', () {
      // §5.5.1: predates sections, arrives from bulk CSV import. A valid row,
      // not a malformed one — nothing here may throw or drop it.
      final TeacherAssignmentEntity assignment =
          TeacherAssignmentEntity.fromJson(<String, dynamic>{
        'id': 'assignment-2',
        'teacherId': 'user-1',
        'subjectId': 'subject-1',
        'subjectName': 'Mathematics',
        'sectionId': null,
        'sectionName': null,
        'gradeLevelId': null,
        'gradeLevelName': null,
        'sectionLabel': null,
      });

      expect(assignment.isSchoolWide, isTrue);
      expect(assignment.classLabel, isNull);
    });

    test('survives the five fields being absent rather than explicitly null',
        () {
      final TeacherAssignmentEntity assignment =
          TeacherAssignmentEntity.fromJson(<String, dynamic>{
        'id': 'assignment-3',
        'teacherId': 'user-1',
        'subjectId': 'subject-1',
        'subjectName': 'Science',
      });

      expect(assignment.isSchoolWide, isTrue);
      expect(assignment.displayLabel, 'Science — all sections');
    });
  });

  group('the two row forms (PRD §5.5.1)', () {
    test('a sectioned assignment reads subject — section label', () {
      expect(
        _assignment(sectionLabel: 'Grade 5 - A').displayLabel,
        'Mathematics — Grade 5 - A',
      );
    });

    test('a school-wide grant reads subject — all sections', () {
      expect(
        _assignment().displayLabel,
        'Mathematics — all sections',
      );
    });

    test("composes the label from grade and section when the server's is "
        'missing', () {
      // Not a documented shape, but the parts are there and the label is the
      // only thing the row draws — deriving it beats rendering "all sections"
      // over an assignment that plainly has a section.
      final TeacherAssignmentEntity assignment = _assignment(
        gradeLevelName: 'Grade 5',
        sectionName: 'A',
      );

      expect(assignment.classLabel, 'Grade 5 - A');
      expect(assignment.displayLabel, 'Mathematics — Grade 5 - A');
      // Still not the legacy grant: the ids and names are there.
      expect(assignment.isSchoolWide, isFalse);
    });

    test('a blank label is treated as no label, not as an empty class name',
        () {
      expect(_assignment(sectionLabel: '   ').displayLabel,
          'Mathematics — all sections');
    });

    test('falls back to whichever half of the pair arrived', () {
      expect(_assignment(gradeLevelName: 'Grade 5').classLabel, 'Grade 5');
      expect(_assignment(sectionName: 'A').classLabel, 'A');
    });
  });
}

/// A row built field-by-field rather than through `buildAssignment`, so these
/// tests can express the partial-null shapes that helper deliberately can't.
TeacherAssignmentEntity _assignment({
  String subjectName = 'Mathematics',
  String? sectionLabel,
  String? gradeLevelName,
  String? sectionName,
}) {
  return TeacherAssignmentEntity(
    id: 'assignment-1',
    teacherId: 'user-1',
    subjectId: 'subject-1',
    subjectName: subjectName,
    sectionLabel: sectionLabel,
    gradeLevelName: gradeLevelName,
    sectionName: sectionName,
    sectionId: sectionName == null ? null : 'section-1',
    gradeLevelId: gradeLevelName == null ? null : 'grade-5',
  );
}
