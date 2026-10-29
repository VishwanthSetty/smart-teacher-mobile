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
import '../../profile/presentation/profile_view.dart';
import '../domain/home_entity.dart';
import 'home_controller.dart';
import 'widgets/continue_rail.dart';

/// Teacher **Dashboard** (mobile plan §5.7).
///
/// A bare body, not a `Scaffold` — the shell owns the chrome.
///
/// The **Active Tasks** list (§5.7's second rail) is still not rendered here:
/// `/home/teacher` reduces its task payload to counts in `home_entity.dart`,
/// and the teacher's Tasks tab already lists the same tasks in full. Expanding
/// that payload is a phase-2 loose end, not a phase-5 one. The completion
/// summary *is* rendered, because it is an aggregate the endpoint already
/// computes.
///
/// Class rows are still not tappable. There is no per-class detail endpoint to
/// open — `/teacher/class-progress` is a rollup *by task*, not by section, and
/// it is reached from the card above, where it can be filtered by class. A row
/// that navigated to a screen the API cannot fill would be worse than one that
/// plainly doesn't navigate.
class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<TeacherHomeEntity> home = ref.watch(
      teacherHomeControllerProvider,
    );

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(teacherHomeControllerProvider.notifier).refresh(),
      child: home.when(
        data: (TeacherHomeEntity data) => _TeacherDashboardBody(home: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () => unawaited(
            ref.read(teacherHomeControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _TeacherDashboardBody extends StatelessWidget {
  const _TeacherDashboardBody({required this.home});

  final TeacherHomeEntity home;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingMd,
            AppConstants.spacingMd,
            AppConstants.spacingMd,
            0,
          ),
          child: _PreparationCard(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingMd,
            AppConstants.spacingSm,
            AppConstants.spacingMd,
            0,
          ),
          // The teacher's only way into Saved and Collections: their tab set
          // has no room for a sixth destination (mobile plan §1), so `/saved`
          // is a pushed route. `extra: true` asks for the Collections variant —
          // a nicety the screen falls back from, not a dependency.
          child: _SavedCard(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingMd,
            AppConstants.spacingSm,
            AppConstants.spacingMd,
            0,
          ),
          child: _ClassProgressCard(),
        ),
        HomeSection(
          title: 'My classes',
          child: home.classes.isEmpty
              ? const _NoClassesNotice()
              : Column(
                  children: <Widget>[
                    for (final HomeClassEntity section in home.classes)
                      ListTile(
                        leading: const Icon(Icons.groups_outlined),
                        title: Text(section.displayLabel),
                      ),
                  ],
                ),
        ),
        if (!home.completionSummary.isEmpty)
          HomeSection(
            title: 'Task completion',
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              child: _CompletionSummaryCard(
                summary: home.completionSummary,
                activeTaskCount: home.activeTaskCount,
              ),
            ),
          ),
        if (home.continuePreparation.isNotEmpty)
          HomeSection(
            title: 'Continue preparation',
            child: ContinueRail(items: home.continuePreparation),
          ),
      ],
    );
  }
}

class _PreparationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
        title: const Text('My preparation'),
        subtitle: Text(
          'How far you are through your own teaching material',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.progress),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.bookmark_border, color: theme.colorScheme.primary),
        title: const Text('Saved & collections'),
        subtitle: Text(
          'Material you bookmarked, grouped for a lesson',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.saved, extra: true),
      ),
    );
  }
}

/// The way into the per-task rollups (mobile plan §5.9).
///
/// Always offered, even for a teacher with no classes: the screen behind it
/// explains an empty rollup in its own words, which is more useful than a card
/// that silently isn't there.
class _ClassProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.query_stats_outlined,
          color: theme.colorScheme.primary,
        ),
        title: const Text('Class progress'),
        subtitle: Text(
          'How your classes are doing on what you assigned',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.classProgress),
      ),
    );
  }
}

class _CompletionSummaryCard extends StatelessWidget {
  const _CompletionSummaryCard({
    required this.summary,
    required this.activeTaskCount,
  });

  final TaskCompletionSummary summary;
  final int activeTaskCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              activeTaskCount == 1
                  ? 'Across 1 active task'
                  : 'Across $activeTaskCount active tasks',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: <Widget>[
                _CountColumn(
                  label: 'Not started',
                  count: summary.notStarted,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                _CountColumn(
                  label: 'In progress',
                  count: summary.inProgress,
                  color: theme.colorScheme.tertiary,
                ),
                _CountColumn(
                  label: 'Completed',
                  count: summary.completed,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountColumn extends StatelessWidget {
  const _CountColumn({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(color: color),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A teacher with no **section-bearing** assignment (backend plan §4.2).
///
/// This is a legitimate state, not an error: `TeacherClassScopeService` fails
/// closed by design, and such a teacher can assign nothing and see no student
/// report. The copy says so plainly rather than showing an empty list that
/// looks like a loading bug. It deliberately does not contradict My Classes,
/// which reads the broader `/teacher-assignments` and may well show rows —
/// that endpoint includes the school-wide legacy grant, which carries no
/// section and therefore reaches no class here.
class _NoClassesNotice extends StatelessWidget {
  const _NoClassesNotice();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  "You aren't assigned to a class yet. Ask your school admin "
                  'to add you to a section.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
