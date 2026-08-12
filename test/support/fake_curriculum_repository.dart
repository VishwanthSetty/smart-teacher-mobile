import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/curriculum_entity.dart';

/// Scripted [CurriculumRepository] for tests.
class FakeCurriculumRepository implements CurriculumRepository {
  FakeCurriculumRepository({
    List<CurriculumEntity>? curricula,
    this.error,
  }) : curricula = curricula ?? <CurriculumEntity>[buildCurriculum()];

  /// Mutable so a test can change what the *next* call answers — the library's
  /// pull-to-refresh (PRD §5.4.1) is only interesting when the second fetch
  /// differs from the first.
  List<CurriculumEntity> curricula;

  /// When set, [fetchCurricula] throws this instead of returning [curricula].
  AppError? error;

  int callCount = 0;

  @override
  Future<List<CurriculumEntity>> fetchCurricula() async {
    callCount++;
    if (error != null) {
      throw error!;
    }
    return curricula;
  }
}

/// One `GET /curricula` row with sane defaults, for tests that only care about
/// a field or two of it.
CurriculumEntity buildCurriculum({
  String id = 'curriculum-1',
  String subjectName = 'Mathematics',
  String gradeLevelName = 'Grade 5',
  CurriculumAudience audience = CurriculumAudience.student,
  CurriculumStatus status = CurriculumStatus.published,
  int nodeCount = 12,
  int videoCount = 8,
  int documentCount = 3,
}) {
  return CurriculumEntity(
    id: id,
    gradeLevelId: 'grade-$gradeLevelName',
    gradeLevelName: gradeLevelName,
    subjectId: 'subject-$subjectName',
    subjectName: subjectName,
    audience: audience,
    status: status,
    schemaId: 'schema-1',
    schemaName: 'CBSE',
    publishedAt: DateTime.utc(2026),
    nodeCount: nodeCount,
    videoCount: videoCount,
    documentCount: documentCount,
  );
}
