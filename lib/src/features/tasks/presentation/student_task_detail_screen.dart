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
import 'my_tasks_controller.dart';
import 'widgets/task_row.dart';

/// One assigned task, as the student sees it (mobile plan §5.6).
///
/// Instructions, due date, the resource card and the primary action — which
/// **opens the player or reader**. That is the only action there is.
///
/// **There is no "mark task done" button for videos, and none for documents
/// either.** Status is derived server-side from the resource's progress
/// (backend plan §6). For a document the completion control is *Mark as read*,
/// which lives in the reader's app bar and is labelled identically there
/// (mobile plan §4) — duplicating it here under a different name would imply
/// two different completions.
class StudentTaskDetailScreen extends ConsumerWidget {
  const StudentTaskDetailScreen({required this.taskId, this.title, super.key});

  final String taskId;

  /// Optimistic title from the row that pushed this. `extra` does not survive a
  /// deep link, so the fetched task remains the authority.
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TaskEntity> task = ref.watch(
      studentTaskDetailControllerProvider(taskId),
    );
    final bool suspended = ref.watch(schoolSuspensionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_displayTitle(task.value))),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : task.when(
                data: (TaskEntity data) => _TaskDetailBody(task: data),
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
    // A `404` is the entitlement answer here — "no such task" and "not yours"
    // are the same response by design (backend plan §4.4) — so it gets the
    // shared not-found state, with no retry and no wording that reads as a
    // refusal.
    if (appError is NotFoundError) {
      return NotFoundView(
        message: appError.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to my tasks',
      );
    }
    return ErrorRetryView(
      error: appError,
      onRetry: () => unawaited(
        ref.read(studentTaskDetailControllerProvider(taskId).notifier).refresh(),
      ),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final DateTime now = DateTime.now();
    final String? due = dueLabel(task.dueAt, now, isCompleted: false);
    final String? instructions = task.instructions?.trim();
    final String resourceId = task.resourceId;

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
                'Your teacher cancelled this task. You can still open the '
                'material if you want to.',
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
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        FilledButton.icon(
          key: const ValueKey<String>('open-task-resource'),
          // Disabled only when there is genuinely nothing to open — a payload
          // that lost its resource reference. Never on completion: rewatching
          // is allowed, and the union rule means it contributes nothing.
          onPressed: resourceId.isEmpty
              ? null
              : () => context.push(
                  task.isVideo
                      ? AppRoutes.videoPath(resourceId)
                      : AppRoutes.documentPath(resourceId),
                  extra: task.resourceTitle,
                ),
          icon: Icon(task.isVideo ? Icons.play_arrow : Icons.menu_book),
          label: Text(task.isVideo ? 'Watch the video' : 'Open the document'),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          // Says plainly how each kind completes, because the two differ and
          // guessing wrong wastes the student's time. Neither sentence offers a
          // control here: the video's is automatic, the document's is the
          // reader's own "Mark as read".
          task.isVideo
              ? 'This finishes itself once you have watched enough of the '
                    'video.'
              : 'Use "Mark as read" inside the document to finish this task.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
