import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/section_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/section_entity.dart';

/// Scripted [SectionRepository] for tests.
class FakeSectionRepository implements SectionRepository {
  FakeSectionRepository({
    List<SectionEntity>? sections,
    this.error,
  }) : sections = sections ?? <SectionEntity>[buildSection()];

  /// Mutable so a test can change what the *next* call answers — `refresh()`
  /// is only interesting when the second fetch differs.
  List<SectionEntity> sections;

  /// When set, [fetchSections] throws this instead of returning [sections].
  AppError? error;

  /// The controller is held for the session rather than auto-disposed
  /// (§5.5.3), so "did re-opening the picker re-fetch?" is a real assertion.
  int callCount = 0;

  @override
  Future<List<SectionEntity>> fetchSections() async {
    callCount++;
    if (error != null) {
      throw error!;
    }
    return sections;
  }
}

/// One `GET /sections` row with sane defaults.
///
/// Defaults to a fully-populated section carrying the server's own composed
/// `label`. Pass `label: null` to exercise the grade/name fallback, and
/// `gradeLevelName: null` alongside it for a section the API sends unqualified.
SectionEntity buildSection({
  String? id,
  String name = 'A',
  String? gradeLevelName = 'Grade 5',
  String? label = 'Grade 5 - A',
}) {
  return SectionEntity(
    id: id ?? 'section-$name',
    name: name,
    gradeLevelId: gradeLevelName == null ? null : 'grade-$gradeLevelName',
    gradeLevelName: gradeLevelName,
    label: label,
  );
}
