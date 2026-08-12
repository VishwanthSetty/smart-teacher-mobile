import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_entity.freezed.dart';
part 'student_entity.g.dart';

/// A student account's lifecycle state (PRD §8.5).
///
/// The roster is read-only for a TEACHER (§5.5.2) — nothing here is an action,
/// only a label, and `PENDING` in particular is the one a teacher needs to see:
/// it explains why a student they can name has never signed in.
///
/// [unknown] is the landing spot for a value this build doesn't know, so a
/// status added later can't fail deserialisation of a whole page.
enum StudentStatus {
  @JsonValue('ACTIVE')
  active,

  @JsonValue('PENDING')
  pending,

  @JsonValue('DISABLED')
  disabled,

  unknown;

  /// What `GET /students?status=` takes. `null` for [unknown] — the app must
  /// never send a filter value it didn't get from the server.
  String? get wireValue => switch (this) {
        StudentStatus.active => 'ACTIVE',
        StudentStatus.pending => 'PENDING',
        StudentStatus.disabled => 'DISABLED',
        StudentStatus.unknown => null,
      };

  /// Row-level wording. [active] has none on purpose: it is the norm, and
  /// badging every row with "Active" would bury the two that aren't.
  String? get label => switch (this) {
        StudentStatus.active || StudentStatus.unknown => null,
        StudentStatus.pending => 'Invite pending',
        StudentStatus.disabled => 'Disabled',
      };
}

/// Where a student sits — the `enrollment` object of PRD §8.5.
///
/// Every field is nullable. The parent's `enrollment` being `null` is the
/// documented "unplaced student" case the roster renders as *Unassigned*
/// (§5.5.2); a *present* enrollment missing a name or a roll number is not
/// documented, but it degrades the same way rather than failing the page.
@freezed
abstract class StudentEnrollmentEntity with _$StudentEnrollmentEntity {
  const factory StudentEnrollmentEntity({
    String? id,
    String? sectionId,
    String? sectionName,
    String? gradeLevelId,
    String? gradeLevelName,
    String? rollNumber,
  }) = _StudentEnrollmentEntity;

  const StudentEnrollmentEntity._();

  factory StudentEnrollmentEntity.fromJson(Map<String, dynamic> json) =>
      _$StudentEnrollmentEntityFromJson(json);

  /// `'Grade 5 - A'`, or whichever half of it arrived — `null` when neither
  /// did, which reads exactly like an unplaced student and is treated as one.
  ///
  /// Same precedence as `SectionEntity.displayLabel` and
  /// `TeacherAssignmentEntity.classLabel`, minus the server-composed `label`:
  /// §8.5 documents no such field on an enrollment.
  String? get displayLabel {
    final String? grade = _trimToNull(gradeLevelName);
    final String? section = _trimToNull(sectionName);

    return switch ((grade, section)) {
      (final String g, final String s) => '$g - $s',
      (final String g, null) => g,
      (null, final String s) => s,
      _ => null,
    };
  }
}

/// One row of `GET /students` (PRD §8.5) — a student on the roster (§5.5.2).
///
/// Only [id] is required. The name fields are what the row draws and the API
/// sends all three, but a page of thirty students failing because one row is
/// missing a surname would be the wrong trade for a screen whose whole job is
/// to be browsed; [displayName] falls through them in turn and ends at the
/// email.
///
/// **Read-only.** `PATCH /students/:id` and the password routes are
/// SCHOOL_ADMIN-only and out of mobile scope entirely (§5.5.2, §8.6), so
/// nothing on this entity is ever written back.
@freezed
abstract class StudentEntity with _$StudentEntity {
  const factory StudentEntity({
    required String id,
    String? email,
    String? firstName,
    String? lastName,
    String? name,
    @JsonKey(unknownEnumValue: StudentStatus.unknown)
    @Default(StudentStatus.unknown)
    StudentStatus status,
    DateTime? activatedAt,
    DateTime? createdAt,
    // `null` is the documented unplaced-student case (§5.5.2), not a parse
    // failure — see [isUnassigned].
    StudentEnrollmentEntity? enrollment,
  }) = _StudentEntity;

  const StudentEntity._();

  factory StudentEntity.fromJson(Map<String, dynamic> json) =>
      _$StudentEntityFromJson(json);

  /// The server's composed `name` wins; then the parts; then the email; and at
  /// the very end the id, so a row always renders as *something* tappable-
  /// looking rather than a blank line.
  String get displayName {
    final String? composed = _trimToNull(name);
    if (composed != null) {
      return composed;
    }

    final String parts =
        <String?>[firstName, lastName].map(_trimToNull).nonNulls.join(' ');
    if (parts.isNotEmpty) {
      return parts;
    }

    return _trimToNull(email) ?? id;
  }

  /// The student has no enrollment at all — the case §5.5.2 calls out. Also
  /// true for an enrollment that carries no grade or section to name, which
  /// tells a teacher the same thing.
  bool get isUnassigned => enrollment?.displayLabel == null;

  /// `'Grade 5 - A'`, or `null` when [isUnassigned]. The *Unassigned* wording
  /// lives in the row, not here — this is data, and the label is UI copy.
  String? get sectionLabel => enrollment?.displayLabel;

  /// `'Roll no. 12'`'s value, or `null`.
  String? get rollNumber => _trimToNull(enrollment?.rollNumber);
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
