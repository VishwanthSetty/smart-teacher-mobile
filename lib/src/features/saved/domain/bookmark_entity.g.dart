// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkCollectionRef _$BookmarkCollectionRefFromJson(
  Map<String, dynamic> json,
) => _BookmarkCollectionRef(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$BookmarkCollectionRefToJson(
  _BookmarkCollectionRef instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_BookmarkEntity _$BookmarkEntityFromJson(Map<String, dynamic> json) =>
    _BookmarkEntity(
      id: json['id'] as String,
      resourceType:
          $enumDecodeNullable(
            _$ActivityResourceTypeEnumMap,
            json['resourceType'],
            unknownValue: ActivityResourceType.unknown,
          ) ??
          ActivityResourceType.unknown,
      videoId: json['videoId'] as String?,
      documentId: json['documentId'] as String?,
      collectionId: json['collectionId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      video: json['video'] == null
          ? null
          : ActivityVideoEntity.fromJson(json['video'] as Map<String, dynamic>),
      document: json['document'] == null
          ? null
          : ActivityDocumentEntity.fromJson(
              json['document'] as Map<String, dynamic>,
            ),
      collection: json['collection'] == null
          ? null
          : BookmarkCollectionRef.fromJson(
              json['collection'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$BookmarkEntityToJson(_BookmarkEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resourceType': _$ActivityResourceTypeEnumMap[instance.resourceType]!,
      'videoId': instance.videoId,
      'documentId': instance.documentId,
      'collectionId': instance.collectionId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'video': instance.video,
      'document': instance.document,
      'collection': instance.collection,
    };

const _$ActivityResourceTypeEnumMap = {
  ActivityResourceType.video: 'VIDEO',
  ActivityResourceType.document: 'DOCUMENT',
  ActivityResourceType.unknown: 'unknown',
};
