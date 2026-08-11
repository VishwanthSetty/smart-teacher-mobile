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
);

Map<String, dynamic> _$MeEntityToJson(_MeEntity instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$UserRoleEnumMap[instance.role]!,
  'schoolId': instance.schoolId,
  'school': instance.school,
};

const _$UserRoleEnumMap = {
  UserRole.teacher: 'TEACHER',
  UserRole.student: 'STUDENT',
  UserRole.unknown: 'unknown',
};
