// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_progress_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskProgressStudentRef _$TaskProgressStudentRefFromJson(
  Map<String, dynamic> json,
) => _TaskProgressStudentRef(
  name: json['name'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$TaskProgressStudentRefToJson(
  _TaskProgressStudentRef instance,
) => <String, dynamic>{'name': instance.name, 'email': instance.email};

_TaskProgressRowEntity _$TaskProgressRowEntityFromJson(
  Map<String, dynamic> json,
) => _TaskProgressRowEntity(
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
  student: json['student'] == null
      ? null
      : TaskProgressStudentRef.fromJson(
          json['student'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$TaskProgressRowEntityToJson(
  _TaskProgressRowEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'status': _$ActivityProgressStatusEnumMap[instance.status]!,
  'completedAt': instance.completedAt?.toIso8601String(),
  'preCompletedAt': instance.preCompletedAt?.toIso8601String(),
  'student': instance.student,
};

const _$ActivityProgressStatusEnumMap = {
  ActivityProgressStatus.notStarted: 'NOT_STARTED',
  ActivityProgressStatus.inProgress: 'IN_PROGRESS',
  ActivityProgressStatus.completed: 'COMPLETED',
  ActivityProgressStatus.unknown: 'unknown',
};

_ClassProgressRowEntity _$ClassProgressRowEntityFromJson(
  Map<String, dynamic> json,
) => _ClassProgressRowEntity(
  taskId: json['taskId'] as String,
  title: json['title'] as String? ?? '',
  sectionId: json['sectionId'] as String?,
  total: (json['total'] as num?)?.toInt() ?? 0,
  notStarted: (json['notStarted'] as num?)?.toInt() ?? 0,
  inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
  completed: (json['completed'] as num?)?.toInt() ?? 0,
  preCompleted: (json['preCompleted'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClassProgressRowEntityToJson(
  _ClassProgressRowEntity instance,
) => <String, dynamic>{
  'taskId': instance.taskId,
  'title': instance.title,
  'sectionId': instance.sectionId,
  'total': instance.total,
  'notStarted': instance.notStarted,
  'inProgress': instance.inProgress,
  'completed': instance.completed,
  'preCompleted': instance.preCompleted,
};

_TaskReminderResult _$TaskReminderResultFromJson(Map<String, dynamic> json) =>
    _TaskReminderResult(reminded: (json['reminded'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$TaskReminderResultToJson(_TaskReminderResult instance) =>
    <String, dynamic>{'reminded': instance.reminded};
