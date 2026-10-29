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
import '../../activity/domain/resource_activity_entity.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/task_entity.dart';
import '../domain/task_progress_entity.dart';
import 'task_progress_controller.dart';
import 'teacher_tasks_controller.dart';

/// Per-student task progress (mobile plan §5.9).
///
/// Three tabs — **Not started / In progress / Completed** — over one unfiltered
/// read, plus the *Remind pending* action. Tapping a student opens their
/// individual report.
///
/// Nothing on this screen writes a status. A task's status is a projection of
/// the linked resource's progress (backend plan §6), and the only control that
/// can move it is the student's own — the player closing itself, or the
/// reader's *Mark as read*. A teacher-side override would be a second,
/// disagreeing source of truth for the same fact.
class TaskProgressScreen extends ConsumerWidget {
  const TaskProgressScreen({required this.taskId, this.title, super.key});

  final String taskId;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<List<TaskProgressRowEntity>> rows = ref.watch(
      taskProgressControllerProvider(taskId),
    );
    // Only for the heading and for whether *Remind pending* can do anything —
    // the rows themselves come from the report endpoint.
    final AsyncValue<TaskEntity> task = ref.watch(
      taskDetailControllerProvider(taskId),
    );

    return DefaultTabController(
      length: _progressTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_displayTitle(task.value)),
          bottom: suspended
              ? null
              : TabBar(
                  tabs: <Widget>[
                    for (final _ProgressTab tab in _progressTabs)
                      Tab(text: _tabLabel(tab, rows.value)),
                  ],
                ),
        ),
        floatingActionButton: suspended || rows.value == null
            ? null
            : _RemindButton(
                taskId: taskId,
                // A cancelled task reminds nobody — the server returns without
                // looking at the recipients — so the button says so rather than
                // reporting a send that never happened.
                isTaskActive: task.value?.isCancelled == false,
              ),
        body: SafeArea(
          child: suspended
              ? SchoolSuspendedView(onSignOut: () => signOut(ref))
              : rows.when(
                  data: (List<TaskProgressRowEntity> data) => TabBarView(
                    children: <Widget>[
                      for (final _ProgressTab tab in _progressTabs)
                        _ProgressList(
                          taskId: taskId,
                          rows: _rowsFor(tab, data),
                          tab: tab,
                        ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace _) =>
                      _buildError(context, ref, error),
                ),
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
    return handedOver.isEmpty ? 'Task progress' : handedOver;
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    final AppError appError = AppError.from(error);
    // `404` is "no such task **or** not yours" — a settled answer, so no retry
    // and no wording that could read as a refusal (backend plan §4.4).
    if (appError is NotFoundError) {
      return NotFoundView(
        message: appError.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to task',
      );
    }
    return ErrorRetryView(
      error: appError,
      onRetry: () => unawaited(
        ref.read(taskProgressControllerProvider(taskId).notifier).refresh(),
      ),
    );
  }
}

enum _ProgressTab { notStarted, inProgress, completed }

const List<_ProgressTab> _progressTabs = <_ProgressTab>[
  _ProgressTab.notStarted,
  _ProgressTab.inProgress,
  _ProgressTab.completed,
];

String _tabName(_ProgressTab tab) => switch (tab) {
  _ProgressTab.notStarted => 'Not started',
  _ProgressTab.inProgress => 'In progress',
  _ProgressTab.completed => 'Completed',
};

/// The count is appended only once the rows are in hand — a tab labelled
/// "Completed (0)" while still loading would be a claim, not a label.
String _tabLabel(_ProgressTab tab, List<TaskProgressRowEntity>? rows) {
  final String name = _tabName(tab);
  return rows == null ? name : '$name (${_rowsFor(tab, rows).length})';
}

List<TaskProgressRowEntity> _rowsFor(
  _ProgressTab tab,
  List<TaskProgressRowEntity> rows,
) {
  return rows.where((TaskProgressRowEntity row) {
    return switch (tab) {
      // `NOT_STARTED` really is stored on a `TaskAssignment`, unlike on a
      // `ResourceActivity` where the absence of a row is what means it. An
      // unrecognised status falls here too: a student who has demonstrably not
      // finished belongs on the tab the teacher will act from.
      _ProgressTab.notStarted =>
        row.status == ActivityProgressStatus.notStarted ||
            row.status == ActivityProgressStatus.unknown,
      _ProgressTab.inProgress =>
        row.status == ActivityProgressStatus.inProgress,
      _ProgressTab.completed => row.isCompleted,
    };
  }).toList(growable: false);
}

class _ProgressList extends ConsumerWidget {
  const _ProgressList({
    required this.taskId,
    required this.rows,
    required this.tab,
  });

  final String taskId;
  final List<TaskProgressRowEntity> rows;
  final _ProgressTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(taskProgressControllerProvider(taskId).notifier).refresh(),
      child: rows.isEmpty
          ? _EmptyTab(tab: tab)
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                // Clears the Remind pending button.
                bottom: AppConstants.spacingXl * 2,
              ),
              itemCount: rows.length,
              itemBuilder: (BuildContext context, int index) =>
                  _StudentRow(taskId: taskId, row: rows[index]),
            ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.taskId, required this.row});

  final String taskId;
  final TaskProgressRowEntity row;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String? studentId = row.studentId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: row.isCompleted
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        child: Icon(
          row.isCompleted ? Icons.check : Icons.person_outline,
          color: row.isCompleted ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        ),
      ),
      title: Text(row.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (row.subtitle case final String email) Text(email),
          if (row.wasPreCompleted)
            // Counted and captioned separately so a completion that was already
            // true on day one is legible as such (backend plan §6).
            Text(
              'Completed before this was assigned',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.tertiary),
            ),
        ],
      ),
      isThreeLine: row.subtitle != null && row.wasPreCompleted,
      // Only a row that names a student can open one. A `studentId`-less row is
      // a malformed payload, and the report route would 404 on it.
      trailing: studentId == null ? null : const Icon(Icons.chevron_right),
      onTap: studentId == null
          ? null
          : () => context.push(
              AppRoutes.studentReportPath(taskId, studentId),
              extra: row.displayName,
            ),
    );
  }
}

/// Each tab's zero state says something different, because each means something
/// different: an empty *Not started* is good news, an empty *Completed* is not.
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.tab});

  final _ProgressTab tab;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String message = switch (tab) {
      _ProgressTab.notStarted => 'Everyone has opened this.',
      _ProgressTab.inProgress => 'Nobody is part-way through this right now.',
      _ProgressTab.completed => 'Nobody has completed this yet.',
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.group_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// *Remind pending* (mobile plan §5.9).
///
/// The server dedupes per UTC day, so a repeat press sends nothing and answers
/// `{ reminded: 0 }`. §5.9 is explicit that the UI must then report **"Reminder
/// already sent today"** rather than pretend it sent another — see
/// [TaskProgressController.remindPending] for how that is told apart from
/// "nobody was pending", which the wire cannot distinguish.
class _RemindButton extends ConsumerStatefulWidget {
  const _RemindButton({required this.taskId, required this.isTaskActive});

  final String taskId;
  final bool isTaskActive;

  @override
  ConsumerState<_RemindButton> createState() => _RemindButtonState();
}

class _RemindButtonState extends ConsumerState<_RemindButton> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // Disabled while in flight rather than merely debounced: each press that
      // got through would be a real fan-out of notifications on the first one
      // of the day.
      onPressed: _sending ? null : () => unawaited(_remind()),
      icon: _sending
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.notifications_active_outlined),
      label: const Text('Remind pending'),
    );
  }

  Future<void> _remind() async {
    setState(() => _sending = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      final TaskReminderOutcome outcome = await ref
          .read(taskProgressControllerProvider(widget.taskId).notifier)
          .remindPending(isTaskActive: widget.isTaskActive);
      messenger.showSnackBar(SnackBar(content: Text(_messageFor(outcome))));
    } on AppError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  String _messageFor(TaskReminderOutcome outcome) => switch (outcome) {
    TaskReminderOutcome.sent => 'Reminder sent.',
    TaskReminderOutcome.alreadySentToday => 'Reminder already sent today.',
    TaskReminderOutcome.nonePending => 'Everyone has completed this task.',
    TaskReminderOutcome.notActive =>
      'This task is cancelled, so nobody was reminded.',
  };
}
