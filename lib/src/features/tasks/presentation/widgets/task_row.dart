import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../activity/presentation/widgets/activity_row.dart';
import '../../domain/task_entity.dart';

/// `'Due 14 Mar'`, `'Due today'`, `'2 days overdue'` — or null for a task with
/// no due date, which is a legitimate thing to set and must not be captioned as
/// anything.
///
/// Day-granular on purpose: a task due "in 4 hours" reads as precision the due
/// date does not have, since `dueAt` is set from a date picker.
String? dueLabel(DateTime? dueAt, DateTime now, {required bool isCompleted}) {
  if (dueAt == null) {
    return null;
  }
  final DateTime dueDay = DateTime(dueAt.year, dueAt.month, dueAt.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  final int days = dueDay.difference(today).inDays;

  if (isCompleted) {
    return 'Due ${_shortDate(dueAt)}';
  }
  if (days < 0) {
    final int late = -days;
    return late == 1 ? '1 day overdue' : '$late days overdue';
  }
  return switch (days) {
    0 => 'Due today',
    1 => 'Due tomorrow',
    < 7 => 'Due in $days days',
    _ => 'Due ${_shortDate(dueAt)}',
  };
}

String _shortDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

/// One row of the student's task list (mobile plan §5.6).
///
/// Carries the **"Completed before this was assigned"** flag, which is the
/// whole reason `preCompletedAt` exists: a student told to watch something they
/// already finished should be able to see that the system knows (backend plan
/// §6).
///
/// Overdue is drawn in the error colour, per the plan. There is deliberately no
/// action on this row — completion is derived from the resource, never asserted
/// here.
class StudentTaskRow extends StatelessWidget {
  const StudentTaskRow({
    required this.assignment,
    required this.now,
    this.onTap,
    super.key,
  });

  final StudentTaskEntity assignment;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TaskEntity? task = assignment.task;
    final bool overdue = assignment.isOverdueAt(now);
    final String? due = dueLabel(
      assignment.dueAt,
      now,
      isCompleted: assignment.isCompleted,
    );

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      leading: CircleAvatar(
        backgroundColor: colors.surfaceContainerHighest,
        child: Icon(
          (task?.isVideo ?? true)
              ? Icons.play_circle_outline
              : Icons.picture_as_pdf_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        assignment.displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (task?.resourceTitle case final String resource) ...<Widget>[
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              resource,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingXs),
          Row(
            children: <Widget>[
              ProgressStatusChip(status: assignment.status),
              if (due != null) ...<Widget>[
                const SizedBox(width: AppConstants.spacingSm),
                Flexible(
                  child: Text(
                    due,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: overdue ? colors.error : colors.onSurfaceVariant,
                      fontWeight: overdue ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (assignment.wasPreCompleted) ...<Widget>[
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'Completed before this was assigned',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One row of the teacher's task list (mobile plan §5.9).
///
/// Shows `completed / total` from the assignments the detail payload already
/// includes, so it needs no separate report call — that endpoint is phase 5.
class TeacherTaskRow extends StatelessWidget {
  const TeacherTaskRow({required this.task, required this.now, this.onTap, super.key});

  final TaskEntity task;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool overdue = task.isOverdueAt(now);
    final String? due = dueLabel(task.dueAt, now, isCompleted: false);
    final int total = task.recipientCount;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      leading: CircleAvatar(
        backgroundColor: colors.surfaceContainerHighest,
        child: Icon(
          task.isVideo
              ? Icons.play_circle_outline
              : Icons.picture_as_pdf_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        task.displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          decoration: task.isCancelled ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            total == 0
                ? 'No recipients'
                : '${task.completedCount} of $total completed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (total > 0) ...<Widget>[
            const SizedBox(height: AppConstants.spacingXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: task.completedCount / total,
                minHeight: 4,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingXs),
          Row(
            children: <Widget>[
              if (task.isCancelled)
                Text(
                  'Cancelled',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                )
              else if (due != null)
                Flexible(
                  child: Text(
                    due,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: overdue ? colors.error : colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
