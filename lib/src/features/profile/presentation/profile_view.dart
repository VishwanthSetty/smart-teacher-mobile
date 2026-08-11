import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
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
          onSignOut: () => signOut(ref),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => _ProfileError(
          error: AppError.from(error),
          onRetry: () => unawaited(
            ref.read(profileControllerProvider.notifier).refresh(),
          ),
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
void signOut(WidgetRef ref) =>
    unawaited(ref.read(logoutControllerProvider).logout());

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user, required this.onSignOut});

  final MeEntity user;
  final VoidCallback onSignOut;

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
        const SizedBox(height: AppConstants.spacingXl),
        OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
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

/// The failure state for a profile that could not be loaded at all — i.e. the
/// restored-session case, since a cached profile means there is something to
/// show even when a refresh fails.
///
/// A suspended school never reaches here: it is caught above and replaced by
/// [SchoolSuspendedView].
class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          _icon,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          error.message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Center(
          child: FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  /// Exhaustive over [AppError] — a new variant surfaces here as an analyzer
  /// error rather than silently picking the generic icon (§6.3).
  IconData get _icon => switch (error) {
        NetworkError() => Icons.wifi_off_outlined,
        UnauthorizedError() || ForbiddenError() => Icons.block_outlined,
        NotFoundError() => Icons.search_off_outlined,
        RateLimitedError() => Icons.timer_outlined,
        ValidationError() || UnknownError() => Icons.error_outline,
      };
}
