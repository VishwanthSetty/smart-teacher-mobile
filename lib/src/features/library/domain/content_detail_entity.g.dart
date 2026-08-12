// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_detail_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoEntity _$VideoEntityFromJson(Map<String, dynamic> json) => _VideoEntity(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  durationSecs: (json['durationSecs'] as num?)?.toInt(),
  contentNodeId: json['contentNodeId'] as String,
  contentNodeTitle: json['contentNodeTitle'] as String,
  curriculumId: json['curriculumId'] as String,
  gradeLevelId: json['gradeLevelId'] as String,
  subjectId: json['subjectId'] as String,
);

Map<String, dynamic> _$VideoEntityToJson(_VideoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'durationSecs': instance.durationSecs,
      'contentNodeId': instance.contentNodeId,
      'contentNodeTitle': instance.contentNodeTitle,
      'curriculumId': instance.curriculumId,
      'gradeLevelId': instance.gradeLevelId,
      'subjectId': instance.subjectId,
    };

_DocumentEntity _$DocumentEntityFromJson(Map<String, dynamic> json) =>
    _DocumentEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentNodeId: json['contentNodeId'] as String,
      contentNodeTitle: json['contentNodeTitle'] as String,
      curriculumId: json['curriculumId'] as String,
      gradeLevelId: json['gradeLevelId'] as String,
      subjectId: json['subjectId'] as String,
    );

Map<String, dynamic> _$DocumentEntityToJson(_DocumentEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'contentNodeId': instance.contentNodeId,
      'contentNodeTitle': instance.contentNodeTitle,
      'curriculumId': instance.curriculumId,
      'gradeLevelId': instance.gradeLevelId,
      'subjectId': instance.subjectId,
    };
