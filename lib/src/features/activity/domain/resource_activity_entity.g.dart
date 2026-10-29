// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_activity_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityVideoEntity _$ActivityVideoEntityFromJson(Map<String, dynamic> json) =>
    _ActivityVideoEntity(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      durationSecs: (json['durationSecs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ActivityVideoEntityToJson(
  _ActivityVideoEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'durationSecs': instance.durationSecs,
};

_ActivityDocumentEntity _$ActivityDocumentEntityFromJson(
  Map<String, dynamic> json,
) => _ActivityDocumentEntity(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  pageCount: (json['pageCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ActivityDocumentEntityToJson(
  _ActivityDocumentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'pageCount': instance.pageCount,
};

_ResourceActivityEntity _$ResourceActivityEntityFromJson(
  Map<String, dynamic> json,
) => _ResourceActivityEntity(
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
  status:
      $enumDecodeNullable(
        _$ActivityProgressStatusEnumMap,
        json['status'],
        unknownValue: ActivityProgressStatus.unknown,
      ) ??
      ActivityProgressStatus.unknown,
  positionSecs: (json['positionSecs'] as num?)?.toInt() ?? 0,
  coveredSecs: (json['coveredSecs'] as num?)?.toInt() ?? 0,
  percent: (json['percent'] as num?)?.toInt() ?? 0,
  lastPage: (json['lastPage'] as num?)?.toInt(),
  pageCount: (json['pageCount'] as num?)?.toInt(),
  markedCompleteAt: json['markedCompleteAt'] == null
      ? null
      : DateTime.parse(json['markedCompleteAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  firstAccessedAt: json['firstAccessedAt'] == null
      ? null
      : DateTime.parse(json['firstAccessedAt'] as String),
  lastAccessedAt: json['lastAccessedAt'] == null
      ? null
      : DateTime.parse(json['lastAccessedAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  video: json['video'] == null
      ? null
      : ActivityVideoEntity.fromJson(json['video'] as Map<String, dynamic>),
  document: json['document'] == null
      ? null
      : ActivityDocumentEntity.fromJson(
          json['document'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ResourceActivityEntityToJson(
  _ResourceActivityEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'resourceType': _$ActivityResourceTypeEnumMap[instance.resourceType]!,
  'videoId': instance.videoId,
  'documentId': instance.documentId,
  'status': _$ActivityProgressStatusEnumMap[instance.status]!,
  'positionSecs': instance.positionSecs,
  'coveredSecs': instance.coveredSecs,
  'percent': instance.percent,
  'lastPage': instance.lastPage,
  'pageCount': instance.pageCount,
  'markedCompleteAt': instance.markedCompleteAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'firstAccessedAt': instance.firstAccessedAt?.toIso8601String(),
  'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'video': instance.video,
  'document': instance.document,
};

const _$ActivityResourceTypeEnumMap = {
  ActivityResourceType.video: 'VIDEO',
  ActivityResourceType.document: 'DOCUMENT',
  ActivityResourceType.unknown: 'unknown',
};

const _$ActivityProgressStatusEnumMap = {
  ActivityProgressStatus.notStarted: 'NOT_STARTED',
  ActivityProgressStatus.inProgress: 'IN_PROGRESS',
  ActivityProgressStatus.completed: 'COMPLETED',
  ActivityProgressStatus.unknown: 'unknown',
};
