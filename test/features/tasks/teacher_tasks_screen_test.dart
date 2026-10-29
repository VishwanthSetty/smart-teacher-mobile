import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/teacher_tasks_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_task_repository.dart';

void main() {
  group('teacher task list (mobile plan §5.9)', () {
    testWidgets('defaults to active tasks, not to everything', (
      WidgetTester tester,
    ) async {
      // A teacher opening Tasks wants what is outstanding; cancelled tasks are
      // kept for the record and are a deliberate thing to go looking for.
      final FakeTaskRepository tasks = FakeTaskRepository();
      await _pumpList(tester, tasks);

      expect(tasks.listCalls.single.status, TaskLifecycleStatus.active);
    });

    testWidgets('shows completed / total from the assignments it already has', (
      WidgetTester tester,
    ) async {
      // No separate report call: `GET /tasks` includes the assignment rows, and
      // the per-student report endpoint is phase 5.
      await _pumpList(
        tester,
        FakeTaskRepository(
          tasks: <TaskEntity>[
            buildTask(
              assignments: <TaskAssignmentEntity>[
                buildAssignment(
                  id: 'a1',
                  status: ActivityProgressStatus.completed,
                ),
                buildAssignment(id: 'a2'),
                buildAssignment(id: 'a3'),
              ],
            ),
          ],
        ),
      );

      expect(find.text('1 of 3 completed'), findsOneWidget);
    });

    testWidgets('changing the status chip re-queries', (
      WidgetTester tester,
    ) async {
      final FakeTaskRepository tasks = FakeTaskRepository();
      await _pumpList(tester, tasks);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Cancelled'));
      await tester.pumpAndSettle();

      // The controller watches the query notifier, so the re-query happens by
      // construction rather than by remembering to trigger it.
      expect(tasks.listCalls, hasLength(2));
      expect(tasks.listCalls.last.status, TaskLifecycleStatus.cancelled);
    });

    testWidgets('an empty list under a filter reads differently', (
      WidgetTester tester,
    ) async {
      final FakeTaskRepository tasks = FakeTaskRepository();
      await _pumpList(tester, tasks);

      expect(find.text('No tasks yet'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Cancelled'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches this filter'), findsOneWidget);
    });
  });

  group('teacher task detail (mobile plan §5.9)', () {
    testWidgets('says the material and recipients cannot be changed', (
      WidgetTester tester,
    ) async {
      // Changing either would invalidate every status already derived from the
      // old resource and silently re-fan-out, so both are a cancel-and-recreate
      // (backend plan §5.4).
      await _pumpDetail(tester, buildTask());

      expect(
        find.textContaining('cannot be changed'),
        findsOneWidget,
      );
      expect(find.textContaining('cancel this task and create a new one'),
          findsOneWidget);
    });

    testWidgets('counts pre-completions separately', (
      WidgetTester tester,
    ) async {
      // So a 100% rate that was 100% on day one is legible as such.
      await _pumpDetail(
        tester,
        buildTask(
          assignments: <TaskAssignmentEntity>[
            buildAssignment(
              id: 'a1',
              status: ActivityProgressStatus.completed,
              preCompletedAt: DateTime(2026, 9, 1),
            ),
            buildAssignment(id: 'a2'),
          ],
        ),
      );

      expect(find.text('1 of 2 completed'), findsOneWidget);
      expect(
        find.textContaining('had already completed this before it was assigned'),
        findsOneWidget,
      );
    });

    testWidgets('a cancelled task offers no edit or cancel action', (
      WidgetTester tester,
    ) async {
      await _pumpDetail(
        tester,
        buildTask(status: TaskLifecycleStatus.cancelled),
      );

      expect(find.byType(PopupMenuButton<String>), findsNothing);
      expect(find.textContaining('This task is cancelled'), findsOneWidget);
    });

    testWidgets('status is stated as derived, never as something to set', (
      WidgetTester tester,
    ) async {
      await _pumpDetail(tester, buildTask());

      expect(
        find.textContaining('it is never set by hand'),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpList(WidgetTester tester, FakeTaskRepository tasks) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(tasks: tasks),
      child: const MaterialApp(home: Scaffold(body: TeacherTasksScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpDetail(WidgetTester tester, TaskEntity task) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        tasks: FakeTaskRepository(tasks: <TaskEntity>[task]),
      ),
      child: MaterialApp(home: TaskDetailScreen(taskId: task.id)),
    ),
  );
  await tester.pumpAndSettle();
}
