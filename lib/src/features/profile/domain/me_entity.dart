import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_entity.freezed.dart';
part 'me_entity.g.dart';

/// The actor's role, as returned by `GET /users/me` (PRD §8.2).
///
/// [unknown] is not a value the API documents — it's the landing spot for
/// anything else the server might send (a `SCHOOL_ADMIN` signing in through
/// the mobile app, or a role added later). Deserialising must not throw here:
/// a role we don't render is a degraded shell, not a broken login.
enum UserRole {
  @JsonValue('TEACHER')
  teacher,

  @JsonValue('STUDENT')
  student,

  unknown,
}

/// Tenant status. A `SUSPENDED` school 403s every authenticated call for the
/// rest of the access token's life (PRD §5.2), so it is worth knowing about
/// at the moment of login rather than one error toast at a time.
enum SchoolStatus {
  @JsonValue('ACTIVE')
  active,

  @JsonValue('SUSPENDED')
  suspended,

  unknown,
}

/// The school an actor belongs to, as embedded in `MeEntity` (PRD §8.2).
@freezed
abstract class SchoolSummary with _$SchoolSummary {
  const factory SchoolSummary({
    required String id,
    required String name,
    required String slug,
    @JsonKey(unknownEnumValue: SchoolStatus.unknown)
    required SchoolStatus status,
  }) = _SchoolSummary;

  factory SchoolSummary.fromJson(Map<String, dynamic> json) =>
      _$SchoolSummaryFromJson(json);
}

/// `GET /users/me` (PRD §8.2) — the only source of the actor's role. The
/// role-based shell (§5.7) selects off [role]; nothing else in the app may
/// assume a role.
@freezed
abstract class MeEntity with _$MeEntity {
  const factory MeEntity({
    required String id,
    required String email,
    required String name,
    @JsonKey(unknownEnumValue: UserRole.unknown) required UserRole role,
    required String schoolId,
    required SchoolSummary school,
  }) = _MeEntity;

  const MeEntity._();

  factory MeEntity.fromJson(Map<String, dynamic> json) =>
      _$MeEntityFromJson(json);

  /// True when every subsequent authenticated call is going to 403
  /// (PRD §5.2).
  bool get isSchoolSuspended => school.status == SchoolStatus.suspended;
}
