import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/classes/data/teacher_assignment_repository.dart';
import 'package:smart_teacher_mobile/src/features/classes/domain/teacher_assignment_entity.dart';

/// Scripted [TeacherAssignmentRepository] for tests.
class FakeTeacherAssignmentRepository implements TeacherAssignmentRepository {
  FakeTeacherAssignmentRepository({
    List<TeacherAssignmentEntity>? assignments,
    this.error,
  }) : assignments =
            assignments ?? <TeacherAssignmentEntity>[buildAssignment()];

  /// Mutable so a test can change what the *next* call answers — pull-to-
  /// refresh (PRD §5.5.1) is only interesting when the second fetch differs.
  List<TeacherAssignmentEntity> assignments;

  /// When set, [fetchAssignments] throws this instead of returning
  /// [assignments].
  AppError? error;

  int callCount = 0;

  /// Every `teacherId` this repository was called with, in order.
  ///
  /// The point of the whole feature: `/teacher-assignments` is not auto-scoped,
  /// so a test asserting on the *arguments* is the only thing that catches a
  /// regression to the unscoped call — the response would look identical.
  final List<String> teacherIds = <String>[];

  @override
  Future<List<TeacherAssignmentEntity>> fetchAssignments({
    required String teacherId,
  }) async {
    callCount++;
    teacherIds.add(teacherId);
    if (error != null) {
      throw error!;
    }
    return assignments;
  }
}

/// One `GET /teacher-assignments` row with sane defaults.
///
/// Defaults to a normal, sectioned assignment. Pass `schoolWide: true` for the
/// legacy grant of §5.5.1 — it nulls all five section/grade fields together,
/// which is the only shape the PRD documents for that case, so a test can't
/// accidentally assert against a half-null row that the API never sends.
TeacherAssignmentEntity buildAssignment({
  String id = 'assignment-1',
  String teacherId = 'user-1',
  String subjectName = 'Mathematics',
  String? subjectCode = 'MATH',
  String gradeLevelName = 'Grade 5',
  String sectionName = 'A',
  String? sectionLabel,
  bool schoolWide = false,
}) {
  return TeacherAssignmentEntity(
    id: id,
    teacherId: teacherId,
    subjectId: 'subject-$subjectName',
    subjectName: subjectName,
    subjectCode: subjectCode,
    teacherName: 'Asha Rao',
    teacherEmail: 'asha@example.com',
    sectionId: schoolWide ? null : 'section-$sectionName',
    sectionName: schoolWide ? null : sectionName,
    gradeLevelId: schoolWide ? null : 'grade-$gradeLevelName',
    gradeLevelName: schoolWide ? null : gradeLevelName,
    sectionLabel:
        schoolWide ? null : sectionLabel ?? '$gradeLevelName - $sectionName',
    createdAt: DateTime.utc(2026),
  );
}
