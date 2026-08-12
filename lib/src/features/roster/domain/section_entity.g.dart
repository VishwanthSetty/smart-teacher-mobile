// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SectionEntity _$SectionEntityFromJson(Map<String, dynamic> json) =>
    _SectionEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      gradeLevelId: json['gradeLevelId'] as String?,
      gradeLevelName: json['gradeLevelName'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$SectionEntityToJson(_SectionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gradeLevelId': instance.gradeLevelId,
      'gradeLevelName': instance.gradeLevelName,
      'label': instance.label,
    };
