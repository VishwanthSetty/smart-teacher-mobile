import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/task_entity.dart';
import 'teacher_tasks_controller.dart';
import 'widgets/task_row.dart';

/// The teacher's task detail (mobile plan §5.9).
///
/// **Title, instructions and due date are editable. The resource and the
/// recipients are not** — they are shown read-only with the note §5.9 asks for,
/// because changing either would invalidate every `TaskAssignment.status`
/// already derived from the old resource and silently re-fan-out (backend plan
/// §5.4). Both are a cancel-and-recreate.
///
/// The completion **count** shown here comes from the assignment rows
/// `GET /tasks/:id` already includes, so this screen needs no report endpoint
/// to draw it. Naming the students behind those counts is what
/// `/tasks/:id/progress` is for, and that — with the individual report and
/// *Remind pending* — lives one push away in [TaskProgressScreen], reached by
/// the **Student progress** button below. A task with no recipients does not
/// offer it: there would be nothing on the other side.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({required this.taskId, this.title, super.key});

  final String taskId;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TaskEntity> task = ref.watch(
      taskDetailControllerProvider(taskId),
    );
    final bool suspended = ref.watch(schoolSuspensionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_displayTitle(task.value)),
        actions: <Widget>[
          if (!suspended && (task.value?.isCancelled ?? true) == false)
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (String action) => unawaited(
                switch (action) {
                  'edit' => _showEditSheet(context, ref, task.value!),
                  _ => _confirmCancel(context, ref, task.value!),
                },
              ),
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                    PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text('Cancel task'),
                    ),
                  ],
            ),
        ],
      ),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : task.when(
                data: (TaskEntity data) => _Body(task: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) =>
                    _buildError(context, ref, error),
              ),
      ),
    );
  }

  String _displayTitle(TaskEntity? task) {
    final String fetched = task?.title.trim() ?? '';
    if (fetched.isNotEmpty) {
      return fetched;
    }
    final String handedOver = title?.trim() ?? '';
    return handedOver.isEmpty ? 'Task' : handedOver;
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    final AppError appError = AppError.from(error);
    // `404` is "no such task **or** not yours" (backend plan §4.4) — a settled
    // answer, so no retry and no wording that reads as a refusal.
    if (appError is NotFoundError) {
      return NotFoundView(
        message: appError.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to tasks',
      );
    }
    return ErrorRetryView(
      error: appError,
      onRetry: () => unawaited(
        ref.read(taskDetailControllerProvider(taskId).notifier).refresh(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final DateTime now = DateTime.now();
    final String? due = dueLabel(task.dueAt, now, isCompleted: false);
    final String? instructions = task.instructions?.trim();
    final int total = task.recipientCount;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: <Widget>[
        if (task.isCancelled)
          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            color: colors.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(AppConstants.spacingMd),
              child: Text(
                'This task is cancelled. Its record and the progress against '
                'it are kept, but students are no longer asked to do it.',
              ),
            ),
          ),
        Text(task.displayTitle, style: theme.textTheme.headlineSmall),
        if (due != null) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            due,
            style: theme.textTheme.titleSmall?.copyWith(
              color: task.isOverdueAt(now)
                  ? colors.error
                  : colors.onSurfaceVariant,
            ),
          ),
        ],
        if (instructions != null && instructions.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppConstants.spacingLg),
          Text('Instructions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingSm),
          Text(instructions, style: theme.textTheme.bodyMedium),
        ],

        const SizedBox(height: AppConstants.spacingLg),
        Text('Completion', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spacingSm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  total == 0
                      ? 'No recipients'
                      : '${task.completedCount} of $total completed',
                  style: theme.textTheme.titleSmall,
                ),
                if (total > 0) ...<Widget>[
                  const SizedBox(height: AppConstants.spacingSm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: task.completedCount / total,
                      minHeight: 6,
                      backgroundColor: colors.surfaceContainerHighest,
                    ),
                  ),
                ],
                if (task.preCompletedCount > 0) ...<Widget>[
                  const SizedBox(height: AppConstants.spacingSm),
                  // Counted separately so a 100% rate that was 100% on day one
                  // is legible as such (backend plan §6).
                  Text(
                    '${task.preCompletedCount} had already completed this '
                    'before it was assigned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Status follows each student\'s progress on the resource — '
                  'it is never set by hand.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (total > 0) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          // Who, by name — which is the whole reason `/tasks/:id/progress`
          // exists, since the counts above come from the assignment rows this
          // screen already has.
          OutlinedButton.icon(
            onPressed: () => context.push(
              AppRoutes.taskProgressPath(task.id),
              extra: task.displayTitle,
            ),
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Student progress'),
          ),
        ],

        const SizedBox(height: AppConstants.spacingLg),
        Text('Material', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spacingSm),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.surfaceContainerHighest,
              child: Icon(
                task.isVideo
                    ? Icons.play_circle_outline
                    : Icons.picture_as_pdf_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),
            title: Text(task.resourceTitle),
            subtitle: Text(task.isVideo ? 'Video' : 'Document'),
            trailing: const Icon(Icons.chevron_right),
            onTap: task.resourceId.isEmpty
                ? null
                : () => context.push(
                    task.isVideo
                        ? AppRoutes.videoPath(task.resourceId)
                        : AppRoutes.documentPath(task.resourceId),
                    extra: task.resourceTitle,
                  ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        // The note §5.9 asks for, said once and plainly.
        Text(
          'The material and the recipients cannot be changed. To change '
          'either, cancel this task and create a new one.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Edits the three fields `PATCH /tasks/:id` accepts. Nothing else is on it.
Future<void> _showEditSheet(
  BuildContext context,
  WidgetRef ref,
  TaskEntity task,
) async {
  final TextEditingController title = TextEditingController(text: task.title);
  final TextEditingController instructions = TextEditingController(
    text: task.instructions ?? '',
  );
  DateTime? dueAt = task.dueAt;
  final bool hadDueDate = task.dueAt != null;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: AppConstants.spacingLg,
          right: AppConstants.spacingLg,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Edit task', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: title,
              maxLength: 160,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: instructions,
              maxLines: 3,
              maxLength: 4000,
              decoration: const InputDecoration(labelText: 'Instructions'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                dueAt == null
                    ? 'No due date'
                    : 'Due ${dueAt!.day}/${dueAt!.month}/${dueAt!.year}',
              ),
              trailing: dueAt == null
                  ? null
                  : IconButton(
                      tooltip: 'Clear due date',
                      icon: const Icon(Icons.close),
                      onPressed: () => setSheetState(() => dueAt = null),
                    ),
              onTap: () async {
                final DateTime now = DateTime.now();
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: dueAt ?? now.add(const Duration(days: 7)),
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setSheetState(
                    () => dueAt = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      23,
                      59,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );

  if (!context.mounted) {
    title.dispose();
    instructions.dispose();
    return;
  }

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(taskDetailControllerProvider(task.id).notifier)
        .updateDetails(
          title: title.text,
          instructions: instructions.text,
          dueAt: dueAt,
          // An explicit null clears it; omitting the key leaves it alone. Only
          // a due date that *was* set and now isn't means "clear".
          clearDueAt: hadDueDate && dueAt == null,
        );
  } on AppError catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
  } finally {
    title.dispose();
    instructions.dispose();
  }
}

/// Cancel is soft and reversible only by creating a new task, so it confirms.
Future<void> _confirmCancel(
  BuildContext context,
  WidgetRef ref,
  TaskEntity task,
) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Cancel this task?'),
      content: const Text(
        'Students will stop being asked to do it. The record and everyone\'s '
        'progress against it are kept.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep it'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cancel task'),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false) || !context.mounted) {
    return;
  }

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(taskDetailControllerProvider(task.id).notifier).cancel();
  } on AppError catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
  }
}
