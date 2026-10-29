// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_summary_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProgressSummaryEntity _$ProgressSummaryEntityFromJson(
  Map<String, dynamic> json,
) => _ProgressSummaryEntity(
  subjectId: json['subjectId'] as String,
  subjectName: json['subjectName'] as String? ?? '',
  gradeLevelId: json['gradeLevelId'] as String?,
  total: (json['total'] as num?)?.toInt() ?? 0,
  notStarted: (json['notStarted'] as num?)?.toInt() ?? 0,
  inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
  completed: (json['completed'] as num?)?.toInt() ?? 0,
  percent: (json['percent'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProgressSummaryEntityToJson(
  _ProgressSummaryEntity instance,
) => <String, dynamic>{
  'subjectId': instance.subjectId,
  'subjectName': instance.subjectName,
  'gradeLevelId': instance.gradeLevelId,
  'total': instance.total,
  'notStarted': instance.notStarted,
  'inProgress': instance.inProgress,
  'completed': instance.completed,
  'percent': instance.percent,
};
