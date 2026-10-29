import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/notification_entity.dart';
import '../domain/push_token_source.dart';
import 'notification_preferences_controller.dart';

/// Notification preferences (mobile plan §5.10).
///
/// Maps 1:1 onto `PATCH /me/notification-preferences`: in-app, push, task
/// reminders, due-soon lead time, quiet hours. Nothing here is a local-only
/// setting dressed up as a server one.
///
/// **Quiet hours are set and cleared together.** The API answers `400` for
/// exactly one of the pair, so the control is a single switch that opens both
/// pickers, and turning it off clears both — there is no arrangement of taps
/// here that can send one alone.
///
/// When no push provider is configured on this build, the push toggle says so
/// and is disabled rather than pretending to control something. That is §5.10's
/// "present it plainly rather than nagging", applied to the same fact the
/// permission-denied path produces.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<NotificationPreferenceEntity> preferences = ref.watch(
      notificationPreferencesControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : preferences.when(
                data: (NotificationPreferenceEntity data) =>
                    _PreferencesBody(preferences: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) => ErrorRetryView(
                  error: AppError.from(error),
                  onRetry: () => unawaited(
                    ref
                        .read(notificationPreferencesControllerProvider.notifier)
                        .refresh(),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PreferencesBody extends ConsumerWidget {
  const _PreferencesBody({required this.preferences});

  final NotificationPreferenceEntity preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    // Null on a platform the API does not register, and on a build with no push
    // provider wired in. Either way there is nothing for the toggle to affect.
    final bool pushAvailable =
        ref.watch(pushTokenSourceProvider).platform != null;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      children: <Widget>[
        SwitchListTile(
          title: const Text('In-app notifications'),
          subtitle: const Text('Show alerts in your inbox'),
          value: preferences.inAppEnabled,
          onChanged: (bool value) =>
              unawaited(_save(context, ref, inAppEnabled: value)),
        ),
        SwitchListTile(
          title: const Text('Push notifications'),
          subtitle: Text(
            pushAvailable
                ? 'Alert this device even when the app is closed'
                : 'Push is not available on this device. Your inbox still '
                      'shows every alert.',
          ),
          value: preferences.pushEnabled && pushAvailable,
          // Disabled rather than hidden: the preference is real and stored
          // server-side, and hiding it would make a setting that governs the
          // user's other devices invisible from this one.
          onChanged: pushAvailable
              ? (bool value) => unawaited(_save(context, ref, pushEnabled: value))
              : null,
        ),
        SwitchListTile(
          title: const Text('Task reminders'),
          subtitle: const Text('When a teacher nudges a pending task'),
          value: preferences.taskRemindersEnabled,
          onChanged: (bool value) =>
              unawaited(_save(context, ref, taskRemindersEnabled: value)),
        ),

        const Divider(height: AppConstants.spacingLg),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          child: Text('Due soon', style: theme.textTheme.titleSmall),
        ),
        _LeadTimeTile(
          value: preferences.dueSoonLeadMins,
          onChanged: (int minutes) =>
              unawaited(_save(context, ref, dueSoonLeadMins: minutes)),
        ),

        const Divider(height: AppConstants.spacingLg),
        SwitchListTile(
          title: const Text('Quiet hours'),
          subtitle: Text(
            preferences.hasQuietHours
                ? 'No push between ${_time(preferences.quietFromMins!)} and '
                      '${_time(preferences.quietToMins!)} UTC'
                : 'Push at any time',
          ),
          value: preferences.hasQuietHours,
          onChanged: (bool value) => unawaited(
            value
                // A sensible default window rather than an empty picker: the
                // pair must be sent together, so "on" has to mean *something*
                // the moment it is switched.
                ? _save(context, ref, quietFromMins: 22 * 60, quietToMins: 7 * 60)
                : _save(context, ref, clearQuietHours: true),
          ),
        ),
        if (preferences.hasQuietHours) ...<Widget>[
          _QuietBoundTile(
            label: 'From',
            minutes: preferences.quietFromMins!,
            onPicked: (int minutes) => unawaited(
              _save(
                context,
                ref,
                quietFromMins: minutes,
                // Both, always — the API rejects one alone.
                quietToMins: preferences.quietToMins,
              ),
            ),
          ),
          _QuietBoundTile(
            label: 'To',
            minutes: preferences.quietToMins!,
            onPicked: (int minutes) => unawaited(
              _save(
                context,
                ref,
                quietFromMins: preferences.quietFromMins,
                quietToMins: minutes,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Text(
              'Quiet hours are kept in UTC, which is how the server evaluates '
              'them.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Every control funnels through here, so a rejection is reported the same
  /// way whichever switch produced it — and the switch snaps back, because the
  /// state is the server's answer and nothing was written optimistically.
  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? taskRemindersEnabled,
    int? dueSoonLeadMins,
    int? quietFromMins,
    int? quietToMins,
    bool clearQuietHours = false,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(notificationPreferencesControllerProvider.notifier)
          .savePreferences(
            inAppEnabled: inAppEnabled,
            pushEnabled: pushEnabled,
            taskRemindersEnabled: taskRemindersEnabled,
            dueSoonLeadMins: dueSoonLeadMins,
            quietFromMins: quietFromMins,
            quietToMins: quietToMins,
            clearQuietHours: clearQuietHours,
          );
    } on AppError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
    }
  }
}

/// The lead time, as the four choices that mean something rather than a slider
/// over 0–10080 minutes.
class _LeadTimeTile extends StatelessWidget {
  const _LeadTimeTile({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  static const Map<String, int> _options = <String, int>{
    '1 hour': 60,
    '3 hours': 180,
    '1 day': 1440,
    '3 days': 4320,
  };

  @override
  Widget build(BuildContext context) {
    final int current = value ?? 1440;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingSm,
        AppConstants.spacingMd,
        AppConstants.spacingSm,
      ),
      child: Wrap(
        spacing: AppConstants.spacingSm,
        children: <Widget>[
          for (final MapEntry<String, int> option in _options.entries)
            ChoiceChip(
              label: Text(option.key),
              selected: current == option.value,
              onSelected: (_) => onChanged(option.value),
            ),
        ],
      ),
    );
  }
}

class _QuietBoundTile extends StatelessWidget {
  const _QuietBoundTile({
    required this.label,
    required this.minutes,
    required this.onPicked,
  });

  final String label;
  final int minutes;
  final ValueChanged<int> onPicked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bedtime_outlined),
      title: Text(label),
      trailing: Text(_time(minutes)),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        );
        if (picked != null) {
          onPicked(picked.hour * 60 + picked.minute);
        }
      },
    );
  }
}

/// Minutes past midnight as `HH:mm`.
String _time(int minutes) {
  final int safe = minutes.clamp(0, 1439);
  return '${(safe ~/ 60).toString().padLeft(2, '0')}:'
      '${(safe % 60).toString().padLeft(2, '0')}';
}
