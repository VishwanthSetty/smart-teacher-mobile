import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/notification_entity.dart';

/// How many rows `GET /me/notifications` returns.
///
/// The server hardcodes `take: 21` and accepts **no** `limit` parameter, unlike
/// `/me/activity`, which takes one. So this is the server's number read off its
/// own query rather than a client preference, and it is what `hasMore` compares
/// against: a short page is the last page.
const int notificationPageSize = 21;

/// The notification inbox, preferences and push-device registration
/// (backend plan §5.5, mobile plan §5.10).
///
/// Every call is actor-scoped server-side (`userId: actor.sub`), so this
/// repository adds no filtering of its own and takes no user id — the same
/// arrangement as `/me/activity` and the opposite of `/teacher-assignments`.
abstract class NotificationRepository {
  /// `GET /me/notifications?unread=&cursor=`.
  ///
  /// The cursor is a row id, as it is for `/me/activity`: the server passes it
  /// to Prisma's `cursor` with `skip: 1`.
  Future<List<NotificationEntity>> fetchNotifications({
    bool? unread,
    String? cursor,
  });

  /// `POST /me/notifications/:id/read`.
  ///
  /// Idempotent server-side (`readAt: row.readAt ?? new Date()`), which is what
  /// makes it safe to replay from the outbox.
  Future<void> markRead(String id);

  /// `POST /me/notifications/read-all` — returns how many rows it flipped.
  ///
  /// Deliberately **not** outboxed, unlike the per-row read: it is a bulk write
  /// with a count the user is shown, and coalescing it against individual reads
  /// would mean one queue entry standing for an unknown number of rows.
  Future<int> markAllRead();

  /// `GET /me/notification-preferences`.
  Future<NotificationPreferenceEntity> fetchPreferences();

  /// `PATCH /me/notification-preferences`.
  ///
  /// Only the fields passed are sent. [quietFromMins] and [quietToMins] travel
  /// together via [clearQuietHours] / both-non-null, because the API answers
  /// `400` when exactly one of them is provided.
  Future<NotificationPreferenceEntity> updatePreferences({
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? taskRemindersEnabled,
    int? dueSoonLeadMins,
    int? quietFromMins,
    int? quietToMins,
    bool clearQuietHours = false,
  });

  /// `POST /me/devices` — registers or refreshes this device's push token.
  ///
  /// Upserts on the token server-side, so calling it on every launch is correct
  /// and is what keeps the returned id available for the logout delete.
  Future<DeviceRegistrationEntity> registerDevice({
    required String platform,
    required String token,
  });

  /// `DELETE /me/devices/:id` — called on logout **before** secure storage is
  /// cleared, since it is a bearer-authenticated call (mobile plan §5.10).
  Future<void> removeDevice(String id);
}

class DioNotificationRepository implements NotificationRepository {
  const DioNotificationRepository(this._dio);

  final Dio _dio;

  static const String notificationsPath = '/me/notifications';
  static const String preferencesPath = '/me/notification-preferences';
  static const String devicesPath = '/me/devices';

  @override
  Future<List<NotificationEntity>> fetchNotifications({
    bool? unread,
    String? cursor,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        notificationsPath,
        queryParameters: <String, dynamic>{
          // Only ever sent as `true`. The DTO reads the parameter as
          // `value === true || value === 'true'`, so `?unread=false` would be
          // parsed as `false` and mean the same as omitting it — but sending it
          // would still claim a filter the user did not ask for.
          if (unread ?? false) 'unread': 'true',
          if (_trimToNull(cursor) case final String value) 'cursor': value,
        },
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <NotificationEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(NotificationEntity.fromJson)
          .toList(growable: false);
    });
  }

  @override
  Future<void> markRead(String id) {
    return guardApiCall(() async {
      await _dio.post<dynamic>('$notificationsPath/$id/read');
    });
  }

  @override
  Future<int> markAllRead() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '$notificationsPath/read-all',
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data['updated'] is num) {
        return (data['updated'] as num).toInt();
      }
      // A write that answered with something unreadable still happened; the
      // screen re-reads the list rather than treating it as a failure.
      return 0;
    });
  }

  @override
  Future<NotificationPreferenceEntity> fetchPreferences() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        preferencesPath,
      );
      return _parsePreferences(response.data);
    });
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
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.patch<dynamic>(
        preferencesPath,
        data: <String, dynamic>{
          // Null-aware elements: an omitted toggle is absent from the body
          // rather than sent as null, which the DTO would reject.
          'inAppEnabled': ?inAppEnabled,
          'pushEnabled': ?pushEnabled,
          'taskRemindersEnabled': ?taskRemindersEnabled,
          if (dueSoonLeadMins != null)
            'dueSoonLeadMins': dueSoonLeadMins.clamp(0, maxDueSoonLeadMins),
          // Set or cleared **together** — the API rejects exactly one of the
          // pair with a `400`, so there is no call shape here that can send one
          // alone. Clearing wins over setting, since it is the explicit ask.
          if (clearQuietHours) ...<String, dynamic>{
            'quietFromMins': null,
            'quietToMins': null,
          } else if (quietFromMins != null && quietToMins != null)
            ...<String, dynamic>{
              'quietFromMins': quietFromMins.clamp(0, 1439),
              'quietToMins': quietToMins.clamp(0, 1439),
            },
        },
      );
      return _parsePreferences(response.data);
    });
  }

  @override
  Future<DeviceRegistrationEntity> registerDevice({
    required String platform,
    required String token,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        devicesPath,
        data: <String, dynamic>{'platform': platform, 'token': token},
      );
      final dynamic data = response.data;
      return data is Map<String, dynamic>
          ? DeviceRegistrationEntity.fromJson(data)
          : const DeviceRegistrationEntity(id: '');
    });
  }

  @override
  Future<void> removeDevice(String id) {
    return guardApiCall(() async {
      await _dio.delete<dynamic>('$devicesPath/$id');
    });
  }
}

/// An unreadable body degrades to the server's own defaults rather than
/// throwing: those defaults are what `getPreferenceFor` would have returned for
/// a user who never saved a preference, so the screen shows the truth either
/// way.
NotificationPreferenceEntity _parsePreferences(dynamic data) =>
    data is Map<String, dynamic>
    ? NotificationPreferenceEntity.fromJson(data)
    : const NotificationPreferenceEntity();

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>(
      (Ref ref) => DioNotificationRepository(ref.watch(dioProvider)),
    );
