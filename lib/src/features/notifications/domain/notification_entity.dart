import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';
part 'notification_entity.g.dart';

/// What a notification is about (backend plan §1.5).
///
/// [unknown] is the usual fallback: the server's enum gains members ahead of
/// the client, and a type this build cannot name must degrade to a plain row
/// rather than fail the whole page.
enum NotificationKind {
  @JsonValue('TASK_ASSIGNED')
  taskAssigned,

  @JsonValue('TASK_REMINDER')
  taskReminder,

  @JsonValue('TASK_DUE_SOON')
  taskDueSoon,

  @JsonValue('TEACHER_DAILY_SUMMARY')
  teacherDailySummary,

  unknown,
}

/// One `Notification` row (backend plan §1.5, `GET /me/notifications`).
///
/// [data] is an opaque JSON bag server-side (`Json @default("{}")`), and it is
/// kept opaque here too — the deep-link getters below read the keys the fan-out
/// and reminder services actually write (`taskId`) and answer `null` for
/// anything else. Parsing it into a typed union would mean a payload from a
/// notification type added later could not be rendered at all.
@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    @JsonKey(unknownEnumValue: NotificationKind.unknown)
    @Default(NotificationKind.unknown)
    NotificationKind type,
    @Default('') String title,
    @Default('') String body,
    @Default(<String, dynamic>{}) Map<String, dynamic> data,

    /// Null while unread. The server stamps it on the first `read` and leaves
    /// it alone afterwards, so it is also "when you first read this".
    DateTime? readAt,
    DateTime? createdAt,
  }) = _NotificationEntity;

  const NotificationEntity._();

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationEntityFromJson(json);

  bool get isUnread => readAt == null;

  /// The task this notification points at, if any.
  ///
  /// Every type the backend writes today carries one except
  /// `TEACHER_DAILY_SUMMARY`, which is a digest and deliberately links nowhere.
  String? get taskId {
    final Object? raw = data['taskId'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  /// What the row draws when the server's title is blank — which a malformed
  /// row can be, and which would otherwise render as an untappable empty tile.
  String get displayTitle {
    final String trimmed = title.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return switch (type) {
      NotificationKind.taskAssigned => 'New task',
      NotificationKind.taskReminder => 'Task reminder',
      NotificationKind.taskDueSoon => 'Task due soon',
      NotificationKind.teacherDailySummary => 'Daily summary',
      NotificationKind.unknown => 'Notification',
    };
  }
}

/// `GET` / `PATCH /me/notification-preferences` (backend plan §5.5).
///
/// The server answers with a **defaulted** object for a user who has never
/// saved one — there is no "unset" state to model, and no 404 to handle. The
/// defaults below match `NotificationsService.getPreferenceFor` exactly, so a
/// payload missing a field renders the same value the server would have used.
///
/// [quietFromMins] and [quietToMins] are **set or cleared together**: the API
/// answers `400` when only one is provided, so nothing here offers a way to
/// send one alone — see [NotificationPreferenceEntity.hasQuietHours].
@freezed
abstract class NotificationPreferenceEntity
    with _$NotificationPreferenceEntity {
  const factory NotificationPreferenceEntity({
    @Default(true) bool inAppEnabled,
    @Default(true) bool pushEnabled,
    @Default(true) bool taskRemindersEnabled,

    /// How long before a due date the "due soon" alert fires, in minutes.
    /// Server default is 1440 (a day); the DTO caps it at 10080 (a week).
    @Default(1440) int? dueSoonLeadMins,

    /// Minutes past UTC midnight. Both null means "no quiet hours".
    int? quietFromMins,
    int? quietToMins,
  }) = _NotificationPreferenceEntity;

  const NotificationPreferenceEntity._();

  factory NotificationPreferenceEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceEntityFromJson(json);

  bool get hasQuietHours => quietFromMins != null && quietToMins != null;
}

/// The upper bound `UpdateNotificationPreferenceDto` puts on `dueSoonLeadMins`.
/// Clamped client-side rather than trusted from a slider, the same way the
/// pagination limits are.
const int maxDueSoonLeadMins = 10080;

/// One registered push device (`POST /me/devices`, backend plan §5.5).
///
/// Only [id] is load-bearing: it is what `DELETE /me/devices/:id` takes on
/// logout, and the sole reason the register call's response is read at all.
@freezed
abstract class DeviceRegistrationEntity with _$DeviceRegistrationEntity {
  const factory DeviceRegistrationEntity({
    required String id,
    @Default('') String platform,
    DateTime? lastSeenAt,
  }) = _DeviceRegistrationEntity;

  const DeviceRegistrationEntity._();

  factory DeviceRegistrationEntity.fromJson(Map<String, dynamic> json) =>
      _$DeviceRegistrationEntityFromJson(json);
}
