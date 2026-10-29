import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_repository.dart';
import '../domain/notification_entity.dart';

/// Notification preferences (mobile plan §5.10).
///
/// Maps 1:1 onto `PATCH /me/notification-preferences`, and deliberately adds
/// nothing of its own: every toggle here is a field the DTO accepts, and there
/// is no client-side preference mixed in among them that would look identical
/// on screen but not survive a reinstall.
///
/// **Writes are not optimistic.** Unlike a bookmark or a progress beat, a
/// preference is a setting the user is looking straight at: a switch that
/// flipped and then silently flipped back would be worse than one that waits a
/// moment, and there is no gesture here whose responsiveness is worth that
/// trade. Failures are reported in place and the switch returns to its real
/// value — the same call the collections screen makes.
///
/// Auto-disposing: this is a screen a user opens, changes something on, and
/// leaves. Nothing else in the app reads it.
class NotificationPreferencesController
    extends AsyncNotifier<NotificationPreferenceEntity> {
  bool _saving = false;

  /// True while a `PATCH` is in flight, so the screen can disable the controls
  /// rather than let two writes race.
  bool get isSaving => _saving;

  @override
  Future<NotificationPreferenceEntity> build() =>
      ref.read(notificationRepositoryProvider).fetchPreferences();

  Future<void> refresh() async {
    final AsyncValue<NotificationPreferenceEntity> next =
        await AsyncValue.guard(
          () => ref.read(notificationRepositoryProvider).fetchPreferences(),
        );
    if (ref.mounted) {
      state = next;
    }
  }

  /// Applies one or more changes.
  ///
  /// Throws its `AppError` at the caller rather than parking it in [state]: the
  /// screen keeps the rest of the settings on screen while it reports what went
  /// wrong, exactly as the task edit sheet does.
  ///
  /// [quietFromMins] / [quietToMins] are **sent together or not at all**, and
  /// [clearQuietHours] is the only way to remove them — the API answers `400`
  /// for exactly one of the pair, and the repository has no call shape that
  /// could produce that.
  ///
  /// Named `savePreferences` rather than `update`, which `AsyncNotifier`
  /// already defines with an incompatible signature — the same rename
  /// `TaskDetailController.updateDetails` carries.
  Future<void> savePreferences({
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? taskRemindersEnabled,
    int? dueSoonLeadMins,
    int? quietFromMins,
    int? quietToMins,
    bool clearQuietHours = false,
  }) async {
    if (_saving) {
      return;
    }
    _saving = true;

    try {
      final NotificationPreferenceEntity updated = await ref
          .read(notificationRepositoryProvider)
          .updatePreferences(
            inAppEnabled: inAppEnabled,
            pushEnabled: pushEnabled,
            taskRemindersEnabled: taskRemindersEnabled,
            dueSoonLeadMins: dueSoonLeadMins,
            quietFromMins: quietFromMins,
            quietToMins: quietToMins,
            clearQuietHours: clearQuietHours,
          );
      if (ref.mounted) {
        state = AsyncData<NotificationPreferenceEntity>(updated);
      }
    } finally {
      _saving = false;
    }
  }
}

final AsyncNotifierProvider<
  NotificationPreferencesController,
  NotificationPreferenceEntity
>
notificationPreferencesControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationPreferencesController,
      NotificationPreferenceEntity
    >(
      NotificationPreferencesController.new,
      retry: (int retryCount, Object error) => null,
    );
