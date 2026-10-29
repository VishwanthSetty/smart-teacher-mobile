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
import '../../profile/presentation/profile_view.dart';
import '../domain/task_entity.dart';
import 'assign_task_controller.dart';
import 'assign_task_sheet.dart';
import 'teacher_tasks_controller.dart';
import 'widgets/task_row.dart';

/// The teacher's **Tasks** tab (mobile plan §5.9) — a bare body.
///
/// Filterable by status and by class. Subject is in the plan's list too and the
/// endpoint takes it, but there is no subject picker in the app that isn't the
/// library's own list of curricula; it joins this when there is one to reuse.
///
/// The **New** action opens the three-step assign sheet. It is present whenever
/// this screen is — the screen only exists in the teacher tab set — and the
/// sheet itself explains the one case it cannot proceed in.
class TeacherTasksScreen extends ConsumerWidget {
  const TeacherTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(schoolSuspensionProvider)) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    final AsyncValue<List<TaskEntity>> tasks = ref.watch(
      teacherTasksControllerProvider,
    );

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            const _TaskFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(teacherTasksControllerProvider.notifier).refresh(),
                child: tasks.when(
                  data: (List<TaskEntity> rows) =>
                      rows.isEmpty ? const _NoTasks() : _TaskList(tasks: rows),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace _) => ErrorRetryView(
                    error: AppError.from(error),
                    onRetry: () => unawaited(
                      ref
                          .read(teacherTasksControllerProvider.notifier)
                          .refresh(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: AppConstants.spacingMd,
          bottom: AppConstants.spacingMd,
          child: FloatingActionButton.extended(
            key: const ValueKey<String>('new-task'),
            heroTag: 'new-task',
            onPressed: () => unawaited(showAssignTaskSheet(context)),
            icon: const Icon(Icons.add),
            label: const Text('New'),
          ),
        ),
      ],
    );
  }
}

class _TaskFilters extends ConsumerWidget {
  const _TaskFilters();

  static const List<(String, TaskLifecycleStatus?)> _statuses =
      <(String, TaskLifecycleStatus?)>[
        ('Active', TaskLifecycleStatus.active),
        ('Cancelled', TaskLifecycleStatus.cancelled),
        ('All', null),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TeacherTaskQuery query = ref.watch(teacherTaskQueryProvider);
    // The same section list the assign flow uses: what this teacher may act on,
    // not the school's whole set.
    final List<HomeClassEntity> sections = ref.watch(
      assignableSectionsProvider,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          for (final (String label, TaskLifecycleStatus? status)
              in _statuses) ...<Widget>[
            ChoiceChip(
              label: Text(label),
              selected: query.status == status,
              onSelected: (bool _) => ref
                  .read(teacherTaskQueryProvider.notifier)
                  .setStatus(status),
            ),
            const SizedBox(width: AppConstants.spacingSm),
          ],
          if (sections.isNotEmpty) ...<Widget>[
            const SizedBox(width: AppConstants.spacingSm),
            ActionChip(
              avatar: Icon(
                query.sectionId == null ? Icons.filter_list : Icons.filter_alt,
                size: 18,
              ),
              label: Text(
                sections
                        .where(
                          (HomeClassEntity row) => row.id == query.sectionId,
                        )
                        .map((HomeClassEntity row) => row.displayLabel)
                        .firstOrNull ??
                    'All classes',
              ),
              onPressed: () => unawaited(
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (BuildContext context) =>
                      _SectionSheet(sections: sections),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionSheet extends ConsumerWidget {
  const _SectionSheet({required this.sections});

  final List<HomeClassEntity> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? selected = ref.watch(
      teacherTaskQueryProvider.select((TeacherTaskQuery q) => q.sectionId),
    );

    void select(String? sectionId) {
      ref.read(teacherTaskQueryProvider.notifier).setSection(sectionId);
      Navigator.of(context).pop();
    }

    return SafeArea(
      child: RadioGroup<String?>(
        groupValue: selected,
        onChanged: select,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // Always first and always available: clearing the filter must not
            // depend on the class list.
            const RadioListTile<String?>(
              value: null,
              title: Text('All classes'),
            ),
            for (final HomeClassEntity section in sections)
              RadioListTile<String?>(
                value: section.id,
                title: Text(section.displayLabel),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks});

  final List<TaskEntity> tasks;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    // A flat array from the endpoint, so no paging affordance — but built
    // lazily, since a term's worth of tasks is a long list.
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl * 2),
      itemCount: tasks.length,
      separatorBuilder: (BuildContext context, int _) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final TaskEntity task = tasks[index];
        return TeacherTaskRow(
          task: task,
          now: now,
          onTap: () => context.push(
            AppRoutes.taskPath(task.id),
            extra: task.displayTitle,
          ),
        );
      },
    );
  }
}

/// No tasks under the current filter — an answer, not a failure (PRD §6.4).
class _NoTasks extends ConsumerWidget {
  const _NoTasks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final TeacherTaskQuery query = ref.watch(teacherTaskQueryProvider);
    final bool isFiltered =
        query.sectionId != null || query.status != TaskLifecycleStatus.active;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.assignment_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          isFiltered ? 'Nothing matches this filter' : 'No tasks yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          isFiltered
              ? 'Try a different status or class.'
              : 'Assign a video or a document to one of your classes and it '
                    'will show up here with its completion count.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
