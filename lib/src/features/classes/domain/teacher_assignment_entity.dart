import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_assignment_entity.freezed.dart';
part 'teacher_assignment_entity.g.dart';

/// One row of `GET /teacher-assignments?teacherId=` (PRD §8.4) — a subject this
/// teacher teaches, and the section they teach it to.
///
/// **The section half of that pair is optional.** `sectionId`, `sectionName`,
/// `gradeLevelId`, `gradeLevelName` and `sectionLabel` can all be `null`
/// *together*: that is a legacy school-wide "teaches this subject" grant,
/// predating sections, created by bulk CSV import (§5.5.1). It is a valid
/// assignment, not a malformed row, so every one of those five is modelled
/// nullable and the row renders in a second form rather than being dropped.
///
/// The teacher fields are echoed back by the endpoint (it is not scoped to
/// "me" — see [TeacherAssignmentRepository]); they are modelled because they
/// arrive, not because this screen draws them.
@freezed
abstract class TeacherAssignmentEntity with _$TeacherAssignmentEntity {
  const factory TeacherAssignmentEntity({
    required String id,
    // Kept because it is the one field that proves the response really was
    // scoped to the actor who asked (§5.5.1).
    required String teacherId,
    required String subjectId,
    required String subjectName,
    String? teacherName,
    String? teacherEmail,
    String? subjectCode,
    // The five that are null together on a school-wide grant.
    String? sectionId,
    String? sectionName,
    String? gradeLevelId,
    String? gradeLevelName,
    String? sectionLabel,
    DateTime? createdAt,
  }) = _TeacherAssignmentEntity;

  const TeacherAssignmentEntity._();

  factory TeacherAssignmentEntity.fromJson(Map<String, dynamic> json) =>
      _$TeacherAssignmentEntityFromJson(json);

  /// The legacy school-wide grant of §5.5.1: this teacher teaches the subject,
  /// but to no particular section.
  ///
  /// Strictly all five fields, which is how the PRD describes the case. What
  /// the row *renders* keys off [classLabel] instead, so a partially-null row —
  /// undocumented, but not worth crashing or mislabelling over — degrades the
  /// same way rather than falling between the two forms.
  bool get isSchoolWide =>
      sectionId == null &&
      sectionName == null &&
      gradeLevelId == null &&
      gradeLevelName == null &&
      sectionLabel == null;

  /// The class this assignment names — `'Grade 5 - A'` — or `null` when there
  /// isn't one to name.
  ///
  /// `sectionLabel` is the server's own pre-composed form and is preferred
  /// whenever it is there; the grade/section fallback exists only so a row that
  /// carries the parts but not the label still reads correctly.
  String? get classLabel {
    final String? label = _trimToNull(sectionLabel);
    if (label != null) {
      return label;
    }

    final String? grade = _trimToNull(gradeLevelName);
    final String? section = _trimToNull(sectionName);

    return switch ((grade, section)) {
      (final String g, final String s) => '$g - $s',
      (final String g, null) => g,
      (null, final String s) => s,
      _ => null,
    };
  }

  /// The two forms §5.5.1 asks for, as one line:
  /// `'Mathematics — Grade 5 - A'` for a normal assignment, and
  /// `'Mathematics — all sections'` for a school-wide grant.
  String get displayLabel => '$subjectName — ${classLabel ?? 'all sections'}';
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
