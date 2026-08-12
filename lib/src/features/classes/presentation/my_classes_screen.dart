import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/teacher_assignment_entity.dart';
import 'my_classes_controller.dart';
import 'widgets/assignment_card.dart';

/// The teacher's "My Classes" tab (PRD §5.5.1) — the subject × section pairs
/// they are assigned to, from `GET /teacher-assignments?teacherId={me.id}`.
///
/// The `teacherId` is the whole story of this screen; see [MyClassesController]
/// for where it comes from and [TeacherAssignmentRepository] for why it can't
/// be omitted.
///
/// Three answers, three distinct states, matching the library (§5.4.1):
/// * rows → [AssignmentCard]s, in both of §5.5.1's forms;
/// * `200 []` → [_NoClassesView], a designed empty state — a teacher with no
///   assignments yet is a documented, legitimate case (§4) and not an error;
/// * a thrown [AppError] → [ErrorRetryView], with a retry.
///
/// Not to be confused with the demo `classes` feature deleted when this repo
/// was repointed at the PRD: that one had its own repository, model and detail
/// route and was unrelated to `/teacher-assignments`. Nothing of it survives
/// here.
///
/// Renders a body, not a `Scaffold`: the shell owns the app bar and the tab bar
/// (see `AppShell`).
class MyClassesScreen extends ConsumerWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<List<TeacherAssignmentEntity>> assignments = ref.watch(
      myClassesControllerProvider,
    );

    // Pre-empts everything below: while a school is suspended every
    // authenticated call 403s, and one explanatory screen beats the same
    // generic error on every tab (§5.2).
    if (suspended) {
      return SchoolSuspendedView(onSignOut: () => signOut(ref));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myClassesControllerProvider.notifier).refresh(),
      child: assignments.when(
        data: (List<TeacherAssignmentEntity> items) => items.isEmpty
            ? const _NoClassesView()
            : _AssignmentList(assignments: items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: () => unawaited(
            ref.read(myClassesControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({required this.assignments});

  final List<TeacherAssignmentEntity> assignments;

  @override
  Widget build(BuildContext context) {
    // No pagination affordance: `/teacher-assignments` returns a flat,
    // unpaginated array (§6.5). `.builder` anyway — a teacher of many sections
    // has a long list, and the rows are cheap to build lazily.
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: assignments.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppConstants.spacingMd),
      itemBuilder: (BuildContext context, int index) =>
          AssignmentCard(assignment: assignments[index]),
    );
  }
}

/// `200 []` — this teacher has no assignments (PRD §6.4).
///
/// An expected answer, not a failure: §4 describes exactly this teacher, and
/// gives them the school's **full** entitlement set rather than an empty
/// library, so the copy says so — otherwise an empty My Classes next to a full
/// Library tab reads like one of the two is broken.
///
/// It offers a refresh because the fix is someone else's action in the admin
/// app, and coming back to a screen that can't be re-checked would mean
/// restarting to find out.
class _NoClassesView extends StatelessWidget {
  const _NoClassesView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    // A ListView, not a Center: the pull-to-refresh above needs something
    // scrollable to receive the gesture, and an empty state is exactly where a
    // user will try it.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.class_outlined,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'No classes assigned yet',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Your school admin assigns the subjects and sections you '
                  'teach. Until then your Library still shows everything your '
                  'school has access to.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Pull down to check again.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
