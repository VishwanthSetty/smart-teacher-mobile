import 'package:freezed_annotation/freezed_annotation.dart';

part 'section_entity.freezed.dart';
part 'section_entity.g.dart';

/// One row of `GET /sections` (PRD §5.5.3) — a section the roster's "filter by
/// section" picker can offer.
///
/// **The PRD names this entity but never pins its shape** (§8 documents
/// `MeEntity`, `CurriculumEntity`, `TeacherAssignmentEntity` and
/// `StudentEntity`, and stops there). It is modelled from the two places the
/// same fields already arrive: `StudentEntity.enrollment`
/// (`sectionId`/`sectionName`/`gradeLevelId`/`gradeLevelName`) and
/// `TeacherAssignmentEntity`, which additionally carries the server's
/// pre-composed `sectionLabel` — `'Grade 5 - A'`. Only [id] and [name] are
/// required; everything the two references disagree about, or that a section
/// could plausibly be missing, is nullable, so one odd row can't fail a picker
/// whose entire job is to hand `id` back to `GET /students?sectionId=`.
///
/// [id] is exactly that opaque filter value. The picker never parses or
/// interprets it — §5.5.3 exists precisely because `/students` takes the id and
/// returns no joined section list of its own.
@freezed
abstract class SectionEntity with _$SectionEntity {
  const factory SectionEntity({
    required String id,
    required String name,
    String? gradeLevelId,
    String? gradeLevelName,
    // The server's own composed form, when it sends one. Mirrors
    // `TeacherAssignmentEntity.sectionLabel`.
    String? label,
  }) = _SectionEntity;

  const SectionEntity._();

  /// What the picker draws: `'Grade 5 - A'`, falling back to the bare section
  /// name when there is no grade to qualify it with.
  ///
  /// [label] is the server's own composition and wins whenever it is there, so
  /// the app and the API can't disagree about how a section is written; the
  /// grade/name join exists only for a payload that carries the parts without
  /// the label. Same precedence as `TeacherAssignmentEntity.classLabel`, which
  /// is where a reader will have seen this rule first.
  String get displayLabel {
    final String? composed = _trimToNull(label);
    if (composed != null) {
      return composed;
    }

    final String? grade = _trimToNull(gradeLevelName);
    final String section = _trimToNull(name) ?? id;

    return grade == null ? section : '$grade - $section';
  }

  factory SectionEntity.fromJson(Map<String, dynamic> json) =>
      _$SectionEntityFromJson(json);
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
