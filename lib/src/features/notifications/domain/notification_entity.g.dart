// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) =>
    _NotificationEntity(
      id: json['id'] as String,
      type:
          $enumDecodeNullable(
            _$NotificationKindEnumMap,
            json['type'],
            unknownValue: NotificationKind.unknown,
          ) ??
          NotificationKind.unknown,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationEntityToJson(_NotificationEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationKindEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$NotificationKindEnumMap = {
  NotificationKind.taskAssigned: 'TASK_ASSIGNED',
  NotificationKind.taskReminder: 'TASK_REMINDER',
  NotificationKind.taskDueSoon: 'TASK_DUE_SOON',
  NotificationKind.teacherDailySummary: 'TEACHER_DAILY_SUMMARY',
  NotificationKind.unknown: 'unknown',
};

_NotificationPreferenceEntity _$NotificationPreferenceEntityFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferenceEntity(
  inAppEnabled: json['inAppEnabled'] as bool? ?? true,
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  taskRemindersEnabled: json['taskRemindersEnabled'] as bool? ?? true,
  dueSoonLeadMins: (json['dueSoonLeadMins'] as num?)?.toInt() ?? 1440,
  quietFromMins: (json['quietFromMins'] as num?)?.toInt(),
  quietToMins: (json['quietToMins'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationPreferenceEntityToJson(
  _NotificationPreferenceEntity instance,
) => <String, dynamic>{
  'inAppEnabled': instance.inAppEnabled,
  'pushEnabled': instance.pushEnabled,
  'taskRemindersEnabled': instance.taskRemindersEnabled,
  'dueSoonLeadMins': instance.dueSoonLeadMins,
  'quietFromMins': instance.quietFromMins,
  'quietToMins': instance.quietToMins,
};

_DeviceRegistrationEntity _$DeviceRegistrationEntityFromJson(
  Map<String, dynamic> json,
) => _DeviceRegistrationEntity(
  id: json['id'] as String,
  platform: json['platform'] as String? ?? '',
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
);

Map<String, dynamic> _$DeviceRegistrationEntityToJson(
  _DeviceRegistrationEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'platform': instance.platform,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
};
