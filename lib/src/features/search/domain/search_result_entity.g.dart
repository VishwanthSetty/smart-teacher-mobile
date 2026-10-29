// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchResultNode _$SearchResultNodeFromJson(Map<String, dynamic> json) =>
    _SearchResultNode(
      title: json['title'] as String? ?? '',
      curriculumId: json['curriculumId'] as String?,
    );

Map<String, dynamic> _$SearchResultNodeToJson(_SearchResultNode instance) =>
    <String, dynamic>{
      'title': instance.title,
      'curriculumId': instance.curriculumId,
    };

_SearchResultEntity _$SearchResultEntityFromJson(Map<String, dynamic> json) =>
    _SearchResultEntity(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      resourceType:
          $enumDecodeNullable(
            _$ActivityResourceTypeEnumMap,
            json['resourceType'],
            unknownValue: ActivityResourceType.unknown,
          ) ??
          ActivityResourceType.unknown,
      durationSecs: (json['durationSecs'] as num?)?.toInt(),
      pageCount: (json['pageCount'] as num?)?.toInt(),
      node: json['node'] == null
          ? null
          : SearchResultNode.fromJson(json['node'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResultEntityToJson(_SearchResultEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'resourceType': _$ActivityResourceTypeEnumMap[instance.resourceType]!,
      'durationSecs': instance.durationSecs,
      'pageCount': instance.pageCount,
      'node': instance.node,
    };

const _$ActivityResourceTypeEnumMap = {
  ActivityResourceType.video: 'VIDEO',
  ActivityResourceType.document: 'DOCUMENT',
  ActivityResourceType.unknown: 'unknown',
};
