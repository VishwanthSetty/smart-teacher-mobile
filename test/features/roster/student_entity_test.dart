import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/student_entity.dart';

/// PRD §8.5 / §5.5.2 — the roster's row, and the unplaced-student case.
void main() {
  group('display name', () {
    test("prefers the server's composed name", () {
      const StudentEntity student = StudentEntity(
        id: 'student-1',
        name: 'Zainab Ali',
        firstName: 'Zainab',
        lastName: 'Ali',
        email: 'zainab@example.com',
      );

      expect(student.displayName, 'Zainab Ali');
    });

    test('falls back to the name parts', () {
      const StudentEntity student = StudentEntity(
        id: 'student-1',
        firstName: 'Zainab',
        lastName: 'Ali',
      );

      expect(student.displayName, 'Zainab Ali');
    });

    test('renders one part when only one arrived', () {
      const StudentEntity student =
          StudentEntity(id: 'student-1', firstName: 'Zainab');

      expect(student.displayName, 'Zainab');
    });

    test('falls back to the email, then the id', () {
      const StudentEntity emailOnly =
          StudentEntity(id: 'student-1', email: 'zainab@example.com');
      const StudentEntity bare = StudentEntity(id: 'student-1', name: '  ');

      // A row that renders as a blank line is worse than one that renders as
      // an id: a teacher can at least report the latter.
      expect(emailOnly.displayName, 'zainab@example.com');
      expect(bare.displayName, 'student-1');
    });
  });

  group('enrollment (PRD §5.5.2)', () {
    test('a placed student reads grade - section', () {
      const StudentEntity student = StudentEntity(
        id: 'student-1',
        enrollment: StudentEnrollmentEntity(
          sectionId: 'section-a',
          sectionName: 'A',
          gradeLevelName: 'Grade 5',
          rollNumber: '12',
        ),
      );

      expect(student.sectionLabel, 'Grade 5 - A');
      expect(student.rollNumber, '12');
      expect(student.isUnassigned, isFalse);
    });

    test('a null enrollment is the unplaced student, not missing data', () {
      const StudentEntity student = StudentEntity(id: 'student-1');

      expect(student.isUnassigned, isTrue);
      expect(student.sectionLabel, isNull);
      expect(student.rollNumber, isNull);
    });

    test('an enrollment with nothing to name reads the same way', () {
      // Undocumented, but the teacher's answer is identical: this student is
      // not in a class anyone can name.
      const StudentEntity student = StudentEntity(
        id: 'student-1',
        enrollment: StudentEnrollmentEntity(id: 'enrollment-1'),
      );

      expect(student.isUnassigned, isTrue);
    });

    test('half an enrollment renders the half that arrived', () {
      const StudentEntity gradeOnly = StudentEntity(
        id: 'student-1',
        enrollment: StudentEnrollmentEntity(gradeLevelName: 'Grade 5'),
      );
      const StudentEntity sectionOnly = StudentEntity(
        id: 'student-2',
        enrollment: StudentEnrollmentEntity(sectionName: 'A'),
      );

      expect(gradeOnly.sectionLabel, 'Grade 5');
      expect(sectionOnly.sectionLabel, 'A');
    });
  });

  group('status', () {
    test('maps the three documented values', () {
      expect(
        StudentEntity.fromJson(<String, dynamic>{
          'id': 'student-1',
          'status': 'PENDING',
        }).status,
        StudentStatus.pending,
      );
    });

    test('an unrecognised status degrades instead of failing the page', () {
      final StudentEntity student = StudentEntity.fromJson(<String, dynamic>{
        'id': 'student-1',
        'status': 'GRADUATED',
      });

      expect(student.status, StudentStatus.unknown);
      // And is never sent back as a filter value.
      expect(student.status.wireValue, isNull);
    });

    test('active carries no badge — only the exceptions are labelled', () {
      expect(StudentStatus.active.label, isNull);
      expect(StudentStatus.unknown.label, isNull);
      expect(StudentStatus.pending.label, 'Invite pending');
      expect(StudentStatus.disabled.label, 'Disabled');
    });
  });

  group('deserialisation', () {
    test('reads the §8.5 payload whole', () {
      final StudentEntity student = StudentEntity.fromJson(<String, dynamic>{
        'id': 'student-1',
        'email': 'zainab@example.com',
        'firstName': 'Zainab',
        'lastName': 'Ali',
        'name': 'Zainab Ali',
        'status': 'ACTIVE',
        'activatedAt': '2026-01-02T00:00:00Z',
        'createdAt': '2026-01-01T00:00:00Z',
        'enrollment': <String, dynamic>{
          'id': 'enrollment-1',
          'sectionId': 'section-1',
          'sectionName': 'A',
          'gradeLevelId': 'grade-5',
          'gradeLevelName': 'Grade 5',
          'rollNumber': '12',
        },
      });

      expect(student.displayName, 'Zainab Ali');
      expect(student.sectionLabel, 'Grade 5 - A');
      expect(student.activatedAt, DateTime.utc(2026, 1, 2));
    });

    test('survives a row carrying only an id', () {
      final StudentEntity student =
          StudentEntity.fromJson(<String, dynamic>{'id': 'student-1'});

      expect(student.displayName, 'student-1');
      expect(student.isUnassigned, isTrue);
      expect(student.status, StudentStatus.unknown);
    });
  });
}
