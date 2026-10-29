// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskResourceRef _$TaskResourceRefFromJson(Map<String, dynamic> json) =>
    _TaskResourceRef(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$TaskResourceRefToJson(_TaskResourceRef instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

_TaskAssignmentEntity _$TaskAssignmentEntityFromJson(
  Map<String, dynamic> json,
) => _TaskAssignmentEntity(
  id: json['id'] as String,
  studentId: json['studentId'] as String?,
  status:
      $enumDecodeNullable(
        _$ActivityProgressStatusEnumMap,
        json['status'],
        unknownValue: ActivityProgressStatus.unknown,
      ) ??
      ActivityProgressStatus.unknown,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  preCompletedAt: json['preCompletedAt'] == null
      ? null
      : DateTime.parse(json['preCompletedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TaskAssignmentEntityToJson(
  _TaskAssignmentEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'status': _$ActivityProgressStatusEnumMap[instance.status]!,
  'completedAt': instance.completedAt?.toIso8601String(),
  'preCompletedAt': instance.preCompletedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$ActivityProgressStatusEnumMap = {
  ActivityProgressStatus.notStarted: 'NOT_STARTED',
  ActivityProgressStatus.inProgress: 'IN_PROGRESS',
  ActivityProgressStatus.completed: 'COMPLETED',
  ActivityProgressStatus.unknown: 'unknown',
};

_TaskEntity _$TaskEntityFromJson(Map<String, dynamic> json) => _TaskEntity(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  instructions: json['instructions'] as String?,
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
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
        _$TaskLifecycleStatusEnumMap,
        json['status'],
        unknownValue: TaskLifecycleStatus.unknown,
      ) ??
      TaskLifecycleStatus.unknown,
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  sectionId: json['sectionId'] as String?,
  createdById: json['createdById'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  video: json['video'] == null
      ? null
      : TaskResourceRef.fromJson(json['video'] as Map<String, dynamic>),
  document: json['document'] == null
      ? null
      : TaskResourceRef.fromJson(json['document'] as Map<String, dynamic>),
  assignments:
      (json['assignments'] as List<dynamic>?)
          ?.map((e) => TaskAssignmentEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TaskAssignmentEntity>[],
);

Map<String, dynamic> _$TaskEntityToJson(_TaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'instructions': instance.instructions,
      'dueAt': instance.dueAt?.toIso8601String(),
      'resourceType': _$ActivityResourceTypeEnumMap[instance.resourceType]!,
      'videoId': instance.videoId,
      'documentId': instance.documentId,
      'status': _$TaskLifecycleStatusEnumMap[instance.status]!,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'sectionId': instance.sectionId,
      'createdById': instance.createdById,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'video': instance.video,
      'document': instance.document,
      'assignments': instance.assignments,
    };

const _$ActivityResourceTypeEnumMap = {
  ActivityResourceType.video: 'VIDEO',
  ActivityResourceType.document: 'DOCUMENT',
  ActivityResourceType.unknown: 'unknown',
};

const _$TaskLifecycleStatusEnumMap = {
  TaskLifecycleStatus.active: 'ACTIVE',
  TaskLifecycleStatus.cancelled: 'CANCELLED',
  TaskLifecycleStatus.unknown: 'unknown',
};

_StudentTaskEntity _$StudentTaskEntityFromJson(Map<String, dynamic> json) =>
    _StudentTaskEntity(
      id: json['id'] as String,
      status:
          $enumDecodeNullable(
            _$ActivityProgressStatusEnumMap,
            json['status'],
            unknownValue: ActivityProgressStatus.unknown,
          ) ??
          ActivityProgressStatus.unknown,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      preCompletedAt: json['preCompletedAt'] == null
          ? null
          : DateTime.parse(json['preCompletedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      task: json['task'] == null
          ? null
          : TaskEntity.fromJson(json['task'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentTaskEntityToJson(_StudentTaskEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$ActivityProgressStatusEnumMap[instance.status]!,
      'completedAt': instance.completedAt?.toIso8601String(),
      'preCompletedAt': instance.preCompletedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'task': instance.task,
    };
