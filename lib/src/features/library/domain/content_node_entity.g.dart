// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_node_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContentItemEntity _$ContentItemEntityFromJson(Map<String, dynamic> json) =>
    _ContentItemEntity(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      durationSecs: (json['durationSecs'] as num?)?.toInt(),
      fileName: json['fileName'] as String?,
    );

Map<String, dynamic> _$ContentItemEntityToJson(_ContentItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'durationSecs': instance.durationSecs,
      'fileName': instance.fileName,
    };

_ContentNodeEntity _$ContentNodeEntityFromJson(
  Map<String, dynamic> json,
) => _ContentNodeEntity(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  children:
      (_readChildren(json, 'children') as List<dynamic>?)
          ?.map((e) => ContentNodeEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ContentNodeEntity>[],
  videos:
      (json['videos'] as List<dynamic>?)
          ?.map((e) => ContentItemEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ContentItemEntity>[],
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => ContentItemEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ContentItemEntity>[],
  videoCountDeep: (json['videoCountDeep'] as num?)?.toInt() ?? 0,
  documentCountDeep: (json['documentCountDeep'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ContentNodeEntityToJson(_ContentNodeEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'children': instance.children,
      'videos': instance.videos,
      'documents': instance.documents,
      'videoCountDeep': instance.videoCountDeep,
      'documentCountDeep': instance.documentCountDeep,
    };

_ContentTreeEntity _$ContentTreeEntityFromJson(Map<String, dynamic> json) =>
    _ContentTreeEntity(
      curriculumId: json['curriculumId'] as String?,
      subjectName: json['subjectName'] as String?,
      gradeLevelName: json['gradeLevelName'] as String?,
      nodes:
          (_readNodes(json, 'nodes') as List<dynamic>?)
              ?.map(
                (e) => ContentNodeEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ContentNodeEntity>[],
    );

Map<String, dynamic> _$ContentTreeEntityToJson(_ContentTreeEntity instance) =>
    <String, dynamic>{
      'curriculumId': instance.curriculumId,
      'subjectName': instance.subjectName,
      'gradeLevelName': instance.gradeLevelName,
      'nodes': instance.nodes,
    };
