import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/pagination/paginated_result.dart';
import '../../home/domain/home_entity.dart';
import '../../roster/data/student_repository.dart';
import '../../roster/domain/student_entity.dart';
import 'assign_task_controller.dart';
import 'widgets/resource_picker_sheet.dart';

/// Opens the assign flow. Answers `true` when a task was created.
Future<bool> showAssignTaskSheet(
  BuildContext context, {
  AssignableResource? resource,
}) async {
  final bool? created = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: AssignTaskSheet(initialResource: resource),
    ),
  );
  return created ?? false;
}

/// **Assign a resource** (mobile plan §5.8) — resource, recipients, details.
///
/// A stepper rather than one long form, because the three steps have genuinely
/// different failure modes and the review at the end is where the recipient
/// count belongs.
///
/// A teacher with no section-bearing assignment cannot get past step 2 and is
/// told why — this matches the server, which refuses such a teacher outright
/// (backend plan §4.2). The flow is not merely hidden: it explains itself.
class AssignTaskSheet extends ConsumerStatefulWidget {
  const AssignTaskSheet({this.initialResource, super.key});

  /// Pre-filled when the flow was entered from a resource rather than from
  /// Tasks → New.
  final AssignableResource? initialResource;

  @override
  ConsumerState<AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends ConsumerState<AssignTaskSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _instructions = TextEditingController();

  int _step = 0;

  @override
  void initState() {
    super.initState();
    final AssignableResource? resource = widget.initialResource;
    if (resource != null) {
      // After the first frame: the controller cannot be written to during a
      // widget's initState, and the sheet has nothing to show before then.
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (!mounted) {
          return;
        }
        ref
            .read(assignTaskControllerProvider.notifier)
            .selectResource(resource);
        _title.text = resource.title;
        setState(() => _step = 1);
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AssignTaskState state = ref.watch(assignTaskControllerProvider);
    final List<HomeClassEntity> sections = ref.watch(
      assignableSectionsProvider,
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
              vertical: AppConstants.spacingSm,
            ),
            child: Text(
              'New task',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (state.error case final AppError error)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingSm,
              ),
              child: _ErrorBanner(
                message: error.displayMessage,
                unreachableCount: state.unreachableStudentIds.length,
              ),
            ),
          Expanded(
            child: switch (_step) {
              0 => _ResourceStep(
                state: state,
                onPick: () => unawaited(_pickResource()),
              ),
              1 => _RecipientsStep(state: state, sections: sections),
              _ => _DetailsStep(
                state: state,
                title: _title,
                instructions: _instructions,
              ),
            },
          ),
          _Footer(
            step: _step,
            state: state,
            onBack: _step == 0 ? null : () => setState(() => _step -= 1),
            onNext: _canAdvance(state) ? () => setState(() => _step += 1) : null,
            onSubmit: state.canSubmit ? () => unawaited(_submit()) : null,
          ),
        ],
      ),
    );
  }

  bool _canAdvance(AssignTaskState state) => switch (_step) {
    0 => state.hasResource,
    1 => state.hasRecipients,
    _ => false,
  };

  Future<void> _pickResource() async {
    final AssignableResource? picked = await showResourcePickerSheet(context);
    if (picked == null || !mounted) {
      return;
    }
    ref.read(assignTaskControllerProvider.notifier).selectResource(picked);
    if (_title.text.trim().isEmpty) {
      _title.text = picked.title;
    }
  }

  Future<void> _submit() async {
    final AssignTaskController controller = ref.read(
      assignTaskControllerProvider.notifier,
    );
    controller
      ..setTitle(_title.text)
      ..setInstructions(_instructions.text);
    final bool created = await controller.submit();
    if (created && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      // A 422 names recipients, which is a step-2 problem — take the teacher
      // back to where they can act on it rather than leaving them on review.
      if (ref.read(assignTaskControllerProvider).unreachableStudentIds.isNotEmpty) {
        setState(() => _step = 1);
      }
    }
  }
}

class _ResourceStep extends StatelessWidget {
  const _ResourceStep({required this.state, required this.onPick});

  final AssignTaskState state;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AssignableResource? resource = state.resource;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        Text('What are they working on?', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppConstants.spacingMd),
        if (resource == null)
          FilledButton.tonalIcon(
            onPressed: onPick,
            icon: const Icon(Icons.library_books_outlined),
            label: const Text('Choose from my library'),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(resource.title),
              subtitle: Text(
                resource.type.wireValue == 'VIDEO' ? 'Video' : 'Document',
              ),
              trailing: TextButton(
                onPressed: onPick,
                child: const Text('Change'),
              ),
            ),
          ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'Only material published for students can be assigned.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Step 2 — a class, or selected students within one (mobile plan §5.8).
class _RecipientsStep extends ConsumerWidget {
  const _RecipientsStep({required this.state, required this.sections});

  final AssignTaskState state;
  final List<HomeClassEntity> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    // The server refuses a teacher with no section-bearing assignment
    // outright, so this is not a hidden control — it is the same answer, said
    // early (backend plan §4.2).
    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.groups_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                "You aren't assigned to a class yet",
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'Ask your school admin to add you to a section, and you will '
                'be able to assign tasks to it.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        Text('Who is it for?', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppConstants.spacingSm),
        RadioGroup<String?>(
          groupValue: state.studentIds.isEmpty ? state.sectionId : null,
          onChanged: (String? id) {
            if (id != null) {
              ref.read(assignTaskControllerProvider.notifier).selectSection(id);
            }
          },
          child: Column(
            children: <Widget>[
              for (final HomeClassEntity section in sections)
                RadioListTile<String?>(
                  value: section.id,
                  title: Text(section.displayLabel),
                  subtitle: const Text('Everyone currently enrolled'),
                ),
            ],
          ),
        ),
        const Divider(),
        // Selecting students clears the section and vice versa: the server
        // takes exactly one of the two and rejects both or neither with a 400.
        for (final HomeClassEntity section in sections)
          ExpansionTile(
            title: Text('Pick students in ${section.displayLabel}'),
            children: <Widget>[
              _StudentPicker(
                sectionId: section.id,
                selected: state.studentIds,
                unreachable: state.unreachableStudentIds,
              ),
            ],
          ),
      ],
    );
  }
}

/// The students of one section, from `GET /students?sectionId=`.
///
/// The roster endpoint is school-wide and role-gated, but filtered by section
/// it returns the same set the server will accept as recipients. A student
/// outside class scope would still be refused with a `404`, so this narrowing
/// is a convenience, not the gate.
class _StudentPicker extends ConsumerWidget {
  const _StudentPicker({
    required this.sectionId,
    required this.selected,
    required this.unreachable,
  });

  final String sectionId;
  final List<String> selected;
  final List<String> unreachable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StudentEntity>> students = ref.watch(
      _sectionStudentsProvider(sectionId),
    );

    return students.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppConstants.spacingLg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace _) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Text(AppError.from(error).displayMessage),
      ),
      data: (List<StudentEntity> rows) => rows.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(AppConstants.spacingLg),
              child: Text('No students are enrolled in this section yet.'),
            )
          : Column(
              children: <Widget>[
                for (final StudentEntity student in rows)
                  CheckboxListTile(
                    value: selected.contains(student.id),
                    // Flagged, never removed: a `422` recipient is a teacher
                    // mistake worth surfacing, not a silent drop.
                    subtitle: unreachable.contains(student.id)
                        ? Text(
                            "Can't open this resource — deselect to continue",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        : null,
                    title: Text(student.displayName),
                    onChanged: (bool? _) => ref
                        .read(assignTaskControllerProvider.notifier)
                        .toggleStudent(student.id),
                  ),
              ],
            ),
    );
  }
}

/// One section's students. Auto-disposing and keyed by section, so expanding
/// three sections over one visit does not pin three rosters.
final FutureProviderFamily<List<StudentEntity>, String>
_sectionStudentsProvider =
    FutureProvider.autoDispose.family<List<StudentEntity>, String>((
      Ref ref,
      String sectionId,
    ) async {
      // One page of 100 — the server's ceiling, and far more than a section
      // holds. A section large enough to page through is a class-management
      // problem, not a picker problem.
      final PaginatedResult<StudentEntity> result = await ref
          .read(studentRepositoryProvider)
          .fetchStudents(sectionId: sectionId, limit: 100);
      return result.items;
    });

class _DetailsStep extends ConsumerWidget {
  const _DetailsStep({
    required this.state,
    required this.title,
    required this.instructions,
  });

  final AssignTaskState state;
  final TextEditingController title;
  final TextEditingController instructions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        TextField(
          key: const ValueKey<String>('assign-title'),
          controller: title,
          maxLength: 160,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: ref.read(assignTaskControllerProvider.notifier).setTitle,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextField(
          controller: instructions,
          maxLines: 4,
          maxLength: 4000,
          decoration: const InputDecoration(
            labelText: 'Instructions (optional)',
          ),
          onChanged: ref
              .read(assignTaskControllerProvider.notifier)
              .setInstructions,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(
            state.dueAt == null
                ? 'No due date'
                : 'Due ${state.dueAt!.day}/${state.dueAt!.month}/'
                      '${state.dueAt!.year}',
          ),
          trailing: state.dueAt == null
              ? null
              : IconButton(
                  tooltip: 'Clear due date',
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(assignTaskControllerProvider.notifier).setDueAt(null),
                ),
          onTap: () => unawaited(_pickDate(context, ref)),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Review', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppConstants.spacingSm),
                Text(state.resource?.title ?? '—'),
                Text(
                  state.sectionId != null
                      ? 'A whole class'
                      : state.studentIds.length == 1
                      ? '1 student'
                      : '${state.studentIds.length} students',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.dueAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      // End of the chosen day: a due date picked as a date should not expire
      // at midnight that morning.
      ref
          .read(assignTaskControllerProvider.notifier)
          .setDueAt(
            DateTime(picked.year, picked.month, picked.day, 23, 59),
          );
    }
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.step,
    required this.state,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final int step;
  final AssignTaskState state;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppConstants.spacingLg),
    child: Row(
      children: <Widget>[
        if (onBack != null)
          TextButton(onPressed: onBack, child: const Text('Back')),
        const Spacer(),
        if (step < 2)
          FilledButton(onPressed: onNext, child: const Text('Next'))
        else
          FilledButton(
            key: const ValueKey<String>('assign-submit'),
            onPressed: onSubmit,
            child: state.isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Assign'),
          ),
      ],
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.unreachableCount});

  final String message;
  final int unreachableCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              unreachableCount == 0
                  ? message
                  : '$message Deselect the flagged students and try again.',
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
