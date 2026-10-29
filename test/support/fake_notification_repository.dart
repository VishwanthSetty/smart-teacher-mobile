import 'dart:async';

import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/notifications/data/notification_repository.dart';
import 'package:smart_teacher_mobile/src/features/notifications/domain/notification_entity.dart';
import 'package:smart_teacher_mobile/src/features/notifications/domain/push_token_source.dart';

NotificationEntity buildNotification({
  String id = 'notification-1',
  NotificationKind type = NotificationKind.taskAssigned,
  String title = 'New task',
  String body = 'Watch the photosynthesis video',
  String? taskId = 'task-1',
  DateTime? readAt,
  DateTime? createdAt,
}) => NotificationEntity(
  id: id,
  type: type,
  title: title,
  body: body,
  data: <String, dynamic>{'taskId': ?taskId},
  readAt: readAt,
  createdAt: createdAt ?? DateTime(2026, 9, 12, 9),
);

/// *Implements* the endpoints rather than only returning canned rows — like the
/// search and collection fakes, and for the same reason: paging by cursor and
/// the read flipping a row are the behaviours the tests are about, and a fake
/// that merely answered would let a regression in either through.
///
/// It **records every write's arguments** too. A read that sent the wrong id,
/// or a device delete that never fired before the token was cleared, both look
/// like success from the outside.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({
    List<NotificationEntity>? notifications,
    NotificationPreferenceEntity? preferences,
    this.error,
  }) : notifications = <NotificationEntity>[...?notifications],
       preferences = preferences ?? const NotificationPreferenceEntity();

  List<NotificationEntity> notifications;
  NotificationPreferenceEntity preferences;
  AppError? error;

  final List<String> readIds = <String>[];
  int readAllCalls = 0;

  final List<
    ({
      bool? inAppEnabled,
      bool? pushEnabled,
      bool? taskRemindersEnabled,
      int? dueSoonLeadMins,
      int? quietFromMins,
      int? quietToMins,
      bool clearQuietHours,
    })
  >
  preferenceWrites =
      <({
        bool? inAppEnabled,
        bool? pushEnabled,
        bool? taskRemindersEnabled,
        int? dueSoonLeadMins,
        int? quietFromMins,
        int? quietToMins,
        bool clearQuietHours,
      })>[];

  final List<({String platform, String token})> registered =
      <({String platform, String token})>[];
  final List<String> removedDevices = <String>[];

  /// What `POST /me/devices` answers with. The id is the only load-bearing
  /// field — it is what the logout delete takes.
  String registeredDeviceId = 'device-1';

  @override
  Future<List<NotificationEntity>> fetchNotifications({
    bool? unread,
    String? cursor,
  }) async {
    _throwIfFailing();
    final List<NotificationEntity> filtered = unread ?? false
        ? notifications
              .where((NotificationEntity row) => row.isUnread)
              .toList(growable: false)
        : notifications;
    // Cursor semantics as the server implements them: everything *after* the
    // named row, `skip: 1`.
    final int start = cursor == null
        ? 0
        : filtered.indexWhere((NotificationEntity row) => row.id == cursor) + 1;
    return filtered
        .skip(start < 0 ? 0 : start)
        .take(notificationPageSize)
        .toList(growable: false);
  }

  @override
  Future<void> markRead(String id) async {
    readIds.add(id);
    _throwIfFailing();
    notifications = notifications
        .map(
          (NotificationEntity row) => row.id == id && row.isUnread
              ? row.copyWith(readAt: DateTime(2026, 9, 12, 10))
              : row,
        )
        .toList();
  }

  @override
  Future<int> markAllRead() async {
    readAllCalls++;
    _throwIfFailing();
    final int unread = notifications
        .where((NotificationEntity row) => row.isUnread)
        .length;
    notifications = notifications
        .map(
          (NotificationEntity row) => row.isUnread
              ? row.copyWith(readAt: DateTime(2026, 9, 12, 10))
              : row,
        )
        .toList();
    return unread;
  }

  @override
  Future<NotificationPreferenceEntity> fetchPreferences() async {
    _throwIfFailing();
    return preferences;
  }

  @override
  Future<NotificationPreferenceEntity> updatePreferences({
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? taskRemindersEnabled,
    int? dueSoonLeadMins,
    int? quietFromMins,
    int? quietToMins,
    bool clearQuietHours = false,
  }) async {
    preferenceWrites.add((
      inAppEnabled: inAppEnabled,
      pushEnabled: pushEnabled,
      taskRemindersEnabled: taskRemindersEnabled,
      dueSoonLeadMins: dueSoonLeadMins,
      quietFromMins: quietFromMins,
      quietToMins: quietToMins,
      clearQuietHours: clearQuietHours,
    ));
    _throwIfFailing();
    preferences = preferences.copyWith(
      inAppEnabled: inAppEnabled ?? preferences.inAppEnabled,
      pushEnabled: pushEnabled ?? preferences.pushEnabled,
      taskRemindersEnabled:
          taskRemindersEnabled ?? preferences.taskRemindersEnabled,
      dueSoonLeadMins: dueSoonLeadMins ?? preferences.dueSoonLeadMins,
      quietFromMins: clearQuietHours
          ? null
          : (quietFromMins ?? preferences.quietFromMins),
      quietToMins: clearQuietHours
          ? null
          : (quietToMins ?? preferences.quietToMins),
    );
    return preferences;
  }

  @override
  Future<DeviceRegistrationEntity> registerDevice({
    required String platform,
    required String token,
  }) async {
    registered.add((platform: platform, token: token));
    _throwIfFailing();
    return DeviceRegistrationEntity(id: registeredDeviceId, platform: platform);
  }

  @override
  Future<void> removeDevice(String id) async {
    removedDevices.add(id);
    _throwIfFailing();
  }

  void _throwIfFailing() {
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
  }
}

/// A push source that actually has a token, so the registration path can be
/// exercised without an FCM SDK.
///
/// The production default is [NoopPushTokenSource], which answers `null` and
/// registers nothing — see [PushTokenSource] for why no provider is wired in
/// this build.
class FakePushTokenSource implements PushTokenSource {
  FakePushTokenSource({this.platform = 'android', this.token = 'token-abc'});

  @override
  final String? platform;

  String? token;

  final StreamController<String> refreshController =
      StreamController<String>.broadcast();

  @override
  Future<String?> currentToken() async => token;

  @override
  Stream<String> get tokenRefreshes => refreshController.stream;
}
