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
import '../domain/task_entity.dart';
import 'my_tasks_controller.dart';
import 'widgets/task_row.dart';

/// **My Tasks**, the student's list (mobile plan §5.6).
///
/// A bare body — the shell owns the app bar and tab bar.
///
/// Three sections, **Overdue / Due soon / Completed**, split from one
/// unfiltered read. There is deliberately **no "mark done" control anywhere on
/// this screen or its detail**: a task's status is a projection of the linked
/// resource's progress (backend plan §6), so the only honest action is to open
/// the resource.
class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<List<StudentTaskEntity>> tasks = ref.watch(
      myTasksControllerProvider,
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(myTasksControllerProvider.notifier).refresh(),
      child: tasks.when(
        data: (List<StudentTaskEntity> rows) =>
            rows.isEmpty ? const _NoTasks() : _TaskSections(rows: rows),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () =>
              unawaited(ref.read(myTasksControllerProvider.notifier).refresh()),
        ),
      ),
    );
  }
}

class _TaskSections extends StatelessWidget {
  const _TaskSections({required this.rows});

  final List<StudentTaskEntity> rows;

  @override
  Widget build(BuildContext context) {
    // Captured once per build, so every row in one paint answers "overdue?"
    // against the same instant.
    final DateTime now = DateTime.now();
    final Map<StudentTaskGroup, List<StudentTaskEntity>> grouped =
        groupStudentTasks(rows, now);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
      children: <Widget>[
        for (final StudentTaskGroup group in StudentTaskGroup.values)
          if (grouped[group]!.isNotEmpty)
            _Section(
              title: switch (group) {
                StudentTaskGroup.overdue => 'Overdue',
                StudentTaskGroup.dueSoon => 'Due soon',
                StudentTaskGroup.completed => 'Completed',
              },
              isAlert: group == StudentTaskGroup.overdue,
              rows: grouped[group]!,
              now: now,
            ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.isAlert,
    required this.rows,
    required this.now,
  });

  final String title;
  final bool isAlert;
  final List<StudentTaskEntity> rows;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingMd,
            AppConstants.spacingMd,
            AppConstants.spacingMd,
            AppConstants.spacingXs,
          ),
          child: Text(
            '$title (${rows.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isAlert ? theme.colorScheme.error : null,
            ),
          ),
        ),
        for (final StudentTaskEntity row in rows)
          StudentTaskRow(
            assignment: row,
            now: now,
            onTap: () => _openTask(context, row),
          ),
      ],
    );
  }
}

void _openTask(BuildContext context, StudentTaskEntity assignment) {
  final String? id = assignment.task?.id;
  if (id == null || id.isEmpty) {
    return;
  }
  context.push(AppRoutes.studentTaskPath(id), extra: assignment.displayTitle);
}

/// No tasks — an answer, not a failure (PRD §6.4). A student whose teacher has
/// assigned nothing is the ordinary case at the start of a term.
class _NoTasks extends StatelessWidget {
  const _NoTasks();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.assignment_turned_in_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'Nothing assigned yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'When your teacher assigns a video or a document, it will show up '
          'here with its due date.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
