// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentEnrollmentEntity _$StudentEnrollmentEntityFromJson(
  Map<String, dynamic> json,
) => _StudentEnrollmentEntity(
  id: json['id'] as String?,
  sectionId: json['sectionId'] as String?,
  sectionName: json['sectionName'] as String?,
  gradeLevelId: json['gradeLevelId'] as String?,
  gradeLevelName: json['gradeLevelName'] as String?,
  rollNumber: json['rollNumber'] as String?,
);

Map<String, dynamic> _$StudentEnrollmentEntityToJson(
  _StudentEnrollmentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'sectionId': instance.sectionId,
  'sectionName': instance.sectionName,
  'gradeLevelId': instance.gradeLevelId,
  'gradeLevelName': instance.gradeLevelName,
  'rollNumber': instance.rollNumber,
};

_StudentEntity _$StudentEntityFromJson(Map<String, dynamic> json) =>
    _StudentEntity(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      name: json['name'] as String?,
      status:
          $enumDecodeNullable(
            _$StudentStatusEnumMap,
            json['status'],
            unknownValue: StudentStatus.unknown,
          ) ??
          StudentStatus.unknown,
      activatedAt: json['activatedAt'] == null
          ? null
          : DateTime.parse(json['activatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      enrollment: json['enrollment'] == null
          ? null
          : StudentEnrollmentEntity.fromJson(
              json['enrollment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$StudentEntityToJson(_StudentEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'name': instance.name,
      'status': _$StudentStatusEnumMap[instance.status]!,
      'activatedAt': instance.activatedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'enrollment': instance.enrollment,
    };

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'ACTIVE',
  StudentStatus.pending: 'PENDING',
  StudentStatus.disabled: 'DISABLED',
  StudentStatus.unknown: 'unknown',
};
