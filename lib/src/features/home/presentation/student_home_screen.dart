import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../../activity/presentation/widgets/activity_row.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/home_entity.dart';
import 'home_controller.dart';
import 'widgets/continue_rail.dart';

/// Student **Home** (mobile plan §5.1).
///
/// A bare body, not a `Scaffold` — the shell owns the app bar and tab bar.
///
/// Two of the plan's four rails are rendered here. **My Tasks** and **Saved
/// Items** need the tasks and bookmarks features, which are phases 4 and 3;
/// their payloads arrive with this aggregate and are surfaced as counts on the
/// summary strip rather than as rails that would link nowhere.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({this.studentName, super.key});

  final String? studentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<StudentHomeEntity> home = ref.watch(
      studentHomeControllerProvider,
    );

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(studentHomeControllerProvider.notifier).refresh(),
      child: home.when(
        data: (StudentHomeEntity data) =>
            _StudentHomeBody(home: data, studentName: studentName),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () => unawaited(
            ref.read(studentHomeControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _StudentHomeBody extends StatelessWidget {
  const _StudentHomeBody({required this.home, this.studentName});

  final StudentHomeEntity home;
  final String? studentName;

  @override
  Widget build(BuildContext context) {
    if (home.isEmpty) {
      return const _StudentHomeEmptyState();
    }

    final List<ResourceActivityEntity> recent = home.recent
        .take(5)
        .toList(growable: false);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
      children: <Widget>[
        if (_greeting case final String greeting)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              0,
            ),
            child: Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        _SummaryStrip(home: home),
        if (home.continueLearning.isNotEmpty)
          HomeSection(
            title: 'Continue learning',
            child: ContinueRail(items: home.continueLearning),
          ),
        if (recent.isNotEmpty)
          HomeSection(
            title: 'Recently viewed',
            onViewAll: () => context.push(AppRoutes.history),
            child: Column(
              children: <Widget>[
                for (final ResourceActivityEntity activity in recent)
                  ActivityRow(
                    activity: activity,
                    onTap: () => _open(context, activity),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String? get _greeting {
    final String name = studentName?.trim() ?? '';
    if (name.isEmpty) {
      return null;
    }
    // First name only: a full name in a greeting reads like a form letter.
    return 'Hi, ${name.split(RegExp(r'\s+')).first}';
  }

  void _open(BuildContext context, ResourceActivityEntity activity) {
    final String id = activity.resourceId;
    if (id.isEmpty) {
      return;
    }
    context.push(
      activity.isVideo ? AppRoutes.videoPath(id) : AppRoutes.documentPath(id),
      extra: activity.title,
    );
  }
}

/// The at-a-glance strip: progress, plus the counts for the rails that phases
/// 3 and 4 will turn into their own screens.
class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.home});

  final StudentHomeEntity home;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        AppConstants.spacingMd,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SummaryTile(
              icon: Icons.insights_outlined,
              label: 'My progress',
              value: null,
              onTap: () => context.push(AppRoutes.progress),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Both tiles are tabs of this shell, not pushed routes, so neither
          // navigates: switching tabs is local `AppShell` state and is not
          // reachable from a child. The count is the useful half — "you have
          // three waiting" — and the tab bar below is one tap away.
          Expanded(
            child: _SummaryTile(
              icon: Icons.assignment_outlined,
              label: 'Tasks due',
              value: '${home.tasksDueCount}',
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: _SummaryTile(
              icon: Icons.bookmark_border,
              label: 'Saved',
              value: '${home.savedCount}',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingMd,
            horizontal: AppConstants.spacingSm,
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: AppConstants.spacingXs),
              if (value != null)
                Text(value!, style: theme.textTheme.titleMedium),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A student with no active enrollment has an empty library **by design**
/// (mobile plan §5.1). This is the copy that case is owed — never an error.
class _StudentHomeEmptyState extends StatelessWidget {
  const _StudentHomeEmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.school_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'Nothing here yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          "Your class hasn't been set up yet — ask your teacher.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
