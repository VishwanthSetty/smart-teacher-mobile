import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../auth/presentation/logout_controller.dart';
import '../domain/me_entity.dart';
import 'profile_controller.dart';
import 'widgets/role_badge.dart';

/// Profile / "Me" (PRD §5.2) as a bare body — name, email, role badge, school
/// name, and the sign-out action (§5.1.3), with no `Scaffold` or app bar of
/// its own.
///
/// Two things render it and they own different chrome: [ProfileScreen] wraps
/// it in a standalone route, and the student shell (§5.7) drops it straight
/// into its Profile tab, under the shell's own app bar. Keeping the chrome out
/// of here is what stops the tab from stacking two app bars.
///
/// Shared by both roles: nothing here is teacher- or student-specific beyond
/// the badge, which reads the role off `GET /users/me` rather than assuming
/// one (§5.7).
///
/// The profile is normally already in hand — login fetched it — so this opens
/// painted, and only a pull-to-refresh goes back to the network. See
/// [ProfileController].
///
/// Suspension pre-empts everything below it: once [schoolSuspensionProvider]
/// latches, this is replaced by [SchoolSuspendedView] rather than showing
/// whichever error the last call happened to produce (§5.2).
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<MeEntity> profile = ref.watch(profileControllerProvider);
    final ThemeMode themeMode = ref.watch(themeControllerProvider);

    if (suspended) {
      return SchoolSuspendedView(
        // The cached profile may still name the school even when the refresh
        // that revealed the suspension failed.
        schoolName: profile.value?.school.name,
        onSignOut: () => signOut(ref),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
      child: profile.when(
        data: (MeEntity user) => _ProfileBody(
          user: user,
          themeMode: themeMode,
          onThemeChanged: ref.read(themeControllerProvider.notifier).set,
          onSignOut: () => signOut(ref),
          onSignOutEverywhere: () =>
              unawaited(_confirmSignOutEverywhere(context, ref)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () =>
              unawaited(ref.read(profileControllerProvider.notifier).refresh()),
        ),
      ),
    );
  }
}

/// Never navigates: ending the session is what moves the router (§6.6).
///
/// Shared with the shell, which offers sign-out on its own failure state for
/// the same reason this screen does — it is the one action always available
/// when nothing else in the app works.
void signOut(WidgetRef ref, {LogoutScope scope = LogoutScope.thisDevice}) =>
    unawaited(ref.read(logoutControllerProvider).logout(scope: scope));

Future<void> _confirmSignOutEverywhere(
  BuildContext context,
  WidgetRef ref,
) async {
  final bool confirmed =
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Sign out everywhere?'),
          content: const Text(
            'This will sign you out on this device and every other device '
            'where your account is currently signed in.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign out everywhere'),
            ),
          ],
        ),
      ) ??
      false;

  if (confirmed && context.mounted) {
    signOut(ref, scope: LogoutScope.allDevices);
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onSignOut,
    required this.onSignOutEverywhere,
  });

  final MeEntity user;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onSignOut;
  final VoidCallback onSignOutEverywhere;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      // Always scrollable, or a short profile can't be pulled to refresh.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              _Avatar(name: user.name),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                user.name,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              RoleBadge(role: user.role),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingXl),
        _DetailTile(
          icon: Icons.school_outlined,
          label: 'School',
          value: user.school.name,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        _DetailTile(
          icon: Icons.mail_outline,
          label: 'Email',
          value: user.email,
        ),
        if (user.enrollment
            case final StudentEnrollmentSummary enrollment) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          _DetailTile(
            icon: Icons.class_outlined,
            label: 'Class',
            value: enrollment.sectionLabel,
          ),
          if (enrollment.rollNumber case final String rollNumber) ...<Widget>[
            const SizedBox(height: AppConstants.spacingSm),
            _DetailTile(
              icon: Icons.numbers_outlined,
              label: 'Roll number',
              value: rollNumber,
            ),
          ],
        ],
        const SizedBox(height: AppConstants.spacingSm),
        _ThemeTile(value: themeMode, onChanged: onThemeChanged),
        const SizedBox(height: AppConstants.spacingXl),
        FilledButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton.icon(
          onPressed: onSignOutEverywhere,
          icon: const Icon(Icons.devices_outlined),
          label: const Text('Sign out everywhere'),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.palette_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Theme', style: theme.textTheme.bodyLarge),
                Text(
                  'Choose how the app looks',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: value,
              borderRadius: BorderRadius.circular(AppConstants.radius),
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  onChanged(mode);
                }
              },
              items: const <DropdownMenuItem<ThemeMode>>[
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Initials rather than a photo: the API carries no avatar field (§8.2).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return CircleAvatar(
      radius: 40,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _initials,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  String get _initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return '${parts.first.characters.first}'
            '${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
