// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolSummary _$SchoolSummaryFromJson(Map<String, dynamic> json) =>
    _SchoolSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      status: $enumDecode(
        _$SchoolStatusEnumMap,
        json['status'],
        unknownValue: SchoolStatus.unknown,
      ),
    );

Map<String, dynamic> _$SchoolSummaryToJson(_SchoolSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'status': _$SchoolStatusEnumMap[instance.status]!,
    };

const _$SchoolStatusEnumMap = {
  SchoolStatus.active: 'ACTIVE',
  SchoolStatus.suspended: 'SUSPENDED',
  SchoolStatus.unknown: 'unknown',
};

_StudentEnrollmentSummary _$StudentEnrollmentSummaryFromJson(
  Map<String, dynamic> json,
) => _StudentEnrollmentSummary(
  id: json['id'] as String,
  sectionId: json['sectionId'] as String,
  sectionName: json['sectionName'] as String,
  sectionLabel: json['sectionLabel'] as String,
  gradeLevelId: json['gradeLevelId'] as String,
  gradeLevelName: json['gradeLevelName'] as String,
  gradeLevelRank: (json['gradeLevelRank'] as num).toInt(),
  rollNumber: json['rollNumber'] as String?,
);

Map<String, dynamic> _$StudentEnrollmentSummaryToJson(
  _StudentEnrollmentSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'sectionId': instance.sectionId,
  'sectionName': instance.sectionName,
  'sectionLabel': instance.sectionLabel,
  'gradeLevelId': instance.gradeLevelId,
  'gradeLevelName': instance.gradeLevelName,
  'gradeLevelRank': instance.gradeLevelRank,
  'rollNumber': instance.rollNumber,
};

_MeEntity _$MeEntityFromJson(Map<String, dynamic> json) => _MeEntity(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(
    _$UserRoleEnumMap,
    json['role'],
    unknownValue: UserRole.unknown,
  ),
  schoolId: json['schoolId'] as String,
  school: SchoolSummary.fromJson(json['school'] as Map<String, dynamic>),
  enrollment: json['enrollment'] == null
      ? null
      : StudentEnrollmentSummary.fromJson(
          json['enrollment'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MeEntityToJson(_MeEntity instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$UserRoleEnumMap[instance.role]!,
  'schoolId': instance.schoolId,
  'school': instance.school,
  'enrollment': instance.enrollment,
};

const _$UserRoleEnumMap = {
  UserRole.teacher: 'TEACHER',
  UserRole.student: 'STUDENT',
  UserRole.unknown: 'unknown',
};
