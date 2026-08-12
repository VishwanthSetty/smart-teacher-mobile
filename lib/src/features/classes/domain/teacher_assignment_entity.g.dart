// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_assignment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeacherAssignmentEntity _$TeacherAssignmentEntityFromJson(
  Map<String, dynamic> json,
) => _TeacherAssignmentEntity(
  id: json['id'] as String,
  teacherId: json['teacherId'] as String,
  subjectId: json['subjectId'] as String,
  subjectName: json['subjectName'] as String,
  teacherName: json['teacherName'] as String?,
  teacherEmail: json['teacherEmail'] as String?,
  subjectCode: json['subjectCode'] as String?,
  sectionId: json['sectionId'] as String?,
  sectionName: json['sectionName'] as String?,
  gradeLevelId: json['gradeLevelId'] as String?,
  gradeLevelName: json['gradeLevelName'] as String?,
  sectionLabel: json['sectionLabel'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TeacherAssignmentEntityToJson(
  _TeacherAssignmentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'teacherId': instance.teacherId,
  'subjectId': instance.subjectId,
  'subjectName': instance.subjectName,
  'teacherName': instance.teacherName,
  'teacherEmail': instance.teacherEmail,
  'subjectCode': instance.subjectCode,
  'sectionId': instance.sectionId,
  'sectionName': instance.sectionName,
  'gradeLevelId': instance.gradeLevelId,
  'gradeLevelName': instance.gradeLevelName,
  'sectionLabel': instance.sectionLabel,
  'createdAt': instance.createdAt?.toIso8601String(),
};
