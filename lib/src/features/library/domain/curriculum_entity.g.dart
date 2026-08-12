// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurriculumEntity _$CurriculumEntityFromJson(Map<String, dynamic> json) =>
    _CurriculumEntity(
      id: json['id'] as String,
      gradeLevelId: json['gradeLevelId'] as String,
      gradeLevelName: json['gradeLevelName'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      audience:
          $enumDecodeNullable(
            _$CurriculumAudienceEnumMap,
            json['audience'],
            unknownValue: CurriculumAudience.unknown,
          ) ??
          CurriculumAudience.unknown,
      status:
          $enumDecodeNullable(
            _$CurriculumStatusEnumMap,
            json['status'],
            unknownValue: CurriculumStatus.unknown,
          ) ??
          CurriculumStatus.unknown,
      schemaId: json['schemaId'] as String?,
      schemaName: json['schemaName'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      nodeCount: (json['nodeCount'] as num?)?.toInt() ?? 0,
      videoCount: (json['videoCount'] as num?)?.toInt() ?? 0,
      documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CurriculumEntityToJson(_CurriculumEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gradeLevelId': instance.gradeLevelId,
      'gradeLevelName': instance.gradeLevelName,
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'audience': _$CurriculumAudienceEnumMap[instance.audience]!,
      'status': _$CurriculumStatusEnumMap[instance.status]!,
      'schemaId': instance.schemaId,
      'schemaName': instance.schemaName,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'nodeCount': instance.nodeCount,
      'videoCount': instance.videoCount,
      'documentCount': instance.documentCount,
    };

const _$CurriculumAudienceEnumMap = {
  CurriculumAudience.student: 'STUDENT',
  CurriculumAudience.teacher: 'TEACHER',
  CurriculumAudience.unknown: 'unknown',
};

const _$CurriculumStatusEnumMap = {
  CurriculumStatus.published: 'PUBLISHED',
  CurriculumStatus.draft: 'DRAFT',
  CurriculumStatus.archived: 'ARCHIVED',
  CurriculumStatus.unknown: 'unknown',
};
