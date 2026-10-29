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
import '../../home/domain/home_entity.dart';
import '../../home/presentation/home_controller.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/task_progress_entity.dart';
import 'task_progress_controller.dart';

/// Class progress (mobile plan §5.9) — `GET /teacher/class-progress`.
///
/// A per-task rollup across the teacher's own classes: each active task with
/// its Not started / In progress / Completed counts. Tapping a row opens that
/// task's per-student progress.
///
/// The section filter is built from **`/home/teacher`'s classes** — the same
/// `TeacherClassScopeService`-resolved set the assign flow uses — and not from
/// the school-wide `/sections`. Offering a section outside the teacher's scope
/// would earn a `404` from this endpoint, which refuses to answer for one.
class ClassProgressScreen extends ConsumerWidget {
  const ClassProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<List<ClassProgressRowEntity>> rows = ref.watch(
      classProgressControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Class progress')),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : Column(
                children: <Widget>[
                  const _SectionFilterBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref
                          .read(classProgressControllerProvider.notifier)
                          .refresh(),
                      child: rows.when(
                        data: (List<ClassProgressRowEntity> data) =>
                            data.isEmpty
                            ? const _EmptyClassProgress()
                            : ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppConstants.spacingSm,
                                ),
                                itemCount: data.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        _RollupCard(row: data[index]),
                              ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (Object error, StackTrace _) => ErrorRetryView(
                          error: AppError.from(error),
                          onRetry: () => unawaited(
                            ref
                                .read(classProgressControllerProvider.notifier)
                                .refresh(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// *All classes* plus one chip per section the teacher actually teaches.
///
/// Hidden entirely when the teacher has one class or none: a filter offering a
/// single choice is chrome, not a control.
class _SectionFilterBar extends ConsumerWidget {
  const _SectionFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HomeClassEntity> classes =
        ref.watch(teacherHomeControllerProvider).value?.classes ??
        const <HomeClassEntity>[];
    if (classes.length < 2) {
      return const SizedBox.shrink();
    }
    final String? selected = ref.watch(classProgressQueryProvider).sectionId;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          ChoiceChip(
            label: const Text('All classes'),
            selected: selected == null,
            onSelected: (_) => ref
                .read(classProgressQueryProvider.notifier)
                .setSection(null),
          ),
          for (final HomeClassEntity section in classes) ...<Widget>[
            const SizedBox(width: AppConstants.spacingSm),
            ChoiceChip(
              label: Text(section.displayLabel),
              selected: selected == section.id,
              onSelected: (_) => ref
                  .read(classProgressQueryProvider.notifier)
                  .setSection(section.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _RollupCard extends StatelessWidget {
  const _RollupCard({required this.row});

  final ClassProgressRowEntity row;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double? fraction = row.completionFraction;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        onTap: () => context.push(
          AppRoutes.taskProgressPath(row.taskId),
          extra: row.displayTitle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.displayTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    row.total == 0
                        ? 'No recipients'
                        : '${row.completed} of ${row.total}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (fraction != null) ...<Widget>[
                const SizedBox(height: AppConstants.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                '${row.notStarted} not started · ${row.inProgress} in progress '
                '· ${row.completed} completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (row.preCompleted > 0) ...<Widget>[
                const SizedBox(height: AppConstants.spacingXs),
                // Reported separately so a rollup that was complete on day one
                // is legible as such (backend plan §6).
                Text(
                  '${row.preCompleted} had already completed this before it '
                  'was assigned',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.tertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The zero state, which has two innocent causes and names both.
///
/// `TeacherClassScopeService` fails closed, so a teacher with no section-bearing
/// assignment legitimately gets an empty rollup — and so does a teacher who has
/// classes but has assigned nothing yet. Neither is an error, and the copy does
/// not contradict My Classes, which reads the broader `/teacher-assignments`.
class _EmptyClassProgress extends StatelessWidget {
  const _EmptyClassProgress();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.insights_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'No active tasks to report on',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Progress appears here once you have assigned something to a class '
          'you teach.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
