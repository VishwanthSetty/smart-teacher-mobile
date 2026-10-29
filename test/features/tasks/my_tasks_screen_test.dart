import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/my_tasks_screen.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/student_task_detail_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_task_repository.dart';

void main() {
  group('grouping (mobile plan §5.6)', () {
    final DateTime now = DateTime(2026, 9, 11, 12);

    test('the three sections split on due date and status', () {
      final Map<StudentTaskGroup, List<StudentTaskEntity>> grouped =
          groupStudentTasks(<StudentTaskEntity>[
            buildStudentTask(
              id: 'late',
              task: buildTask(id: 't1', dueAt: DateTime(2026, 9, 1)),
            ),
            buildStudentTask(
              id: 'soon',
              task: buildTask(id: 't2', dueAt: DateTime(2026, 9, 20)),
            ),
            buildStudentTask(
              id: 'done',
              status: ActivityProgressStatus.completed,
              task: buildTask(id: 't3', dueAt: DateTime(2026, 9, 20)),
            ),
          ], now);

      expect(grouped[StudentTaskGroup.overdue]!.single.id, 'late');
      expect(grouped[StudentTaskGroup.dueSoon]!.single.id, 'soon');
      expect(grouped[StudentTaskGroup.completed]!.single.id, 'done');
    });

    test('a completed task past its due date is Completed, not Overdue', () {
      // It is done; filing it under Overdue would ask the student to act on
      // something they have already closed.
      final Map<StudentTaskGroup, List<StudentTaskEntity>> grouped =
          groupStudentTasks(<StudentTaskEntity>[
            buildStudentTask(
              status: ActivityProgressStatus.completed,
              task: buildTask(dueAt: DateTime(2026, 9, 1)),
            ),
          ], now);

      expect(grouped[StudentTaskGroup.overdue], isEmpty);
      expect(grouped[StudentTaskGroup.completed], hasLength(1));
    });

    test('a task with no due date is never overdue', () {
      // An open-ended task is a legitimate thing to set; calling it late would
      // be an invention.
      final Map<StudentTaskGroup, List<StudentTaskEntity>> grouped =
          groupStudentTasks(<StudentTaskEntity>[
            buildStudentTask(task: buildTask()),
          ], now);

      expect(grouped[StudentTaskGroup.overdue], isEmpty);
      expect(grouped[StudentTaskGroup.dueSoon], hasLength(1));
    });
  });

  group('My Tasks (mobile plan §5.6)', () {
    testWidgets('renders the sections it has rows for', (
      WidgetTester tester,
    ) async {
      await _pumpList(
        tester,
        FakeStudentTaskRepository(
          assignments: <StudentTaskEntity>[
            buildStudentTask(
              id: 'a1',
              task: buildTask(id: 't1', title: 'Late one', dueAt: DateTime(2020)),
            ),
            buildStudentTask(
              id: 'a2',
              status: ActivityProgressStatus.completed,
              task: buildTask(id: 't2', title: 'Done one'),
            ),
          ],
        ),
      );

      expect(find.text('Overdue (1)'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);
      // Nothing falls in "Due soon", so that heading is absent rather than
      // drawn empty.
      expect(find.textContaining('Due soon'), findsNothing);
    });

    testWidgets('flags a task completed before it was assigned', (
      WidgetTester tester,
    ) async {
      // The whole reason `preCompletedAt` exists: a student told to watch
      // something they already finished should see that the system knows.
      await _pumpList(
        tester,
        FakeStudentTaskRepository(
          assignments: <StudentTaskEntity>[
            buildStudentTask(
              status: ActivityProgressStatus.completed,
              preCompletedAt: DateTime(2026, 9, 1),
            ),
          ],
        ),
      );

      expect(
        find.text('Completed before this was assigned'),
        findsOneWidget,
      );
    });

    testWidgets('an empty list is an answer, not an error', (
      WidgetTester tester,
    ) async {
      await _pumpList(tester, FakeStudentTaskRepository());

      expect(find.text('Nothing assigned yet'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);
    });

    testWidgets('it reads the list unfiltered and splits locally', (
      WidgetTester tester,
    ) async {
      final FakeStudentTaskRepository tasks = FakeStudentTaskRepository();
      await _pumpList(tester, tasks);

      // One call, no `?status=` and no `?overdue=` — the three sections are a
      // pure function of what came back.
      expect(tasks.listCalls, hasLength(1));
      expect(tasks.listCalls.single.status, isNull);
      expect(tasks.listCalls.single.overdue, isNull);
    });
  });

  group('student task detail (mobile plan §5.6)', () {
    testWidgets('a video task has no "mark done" control', (
      WidgetTester tester,
    ) async {
      // Status is derived server-side from the resource's progress, so a
      // button that only sometimes worked would be worse than none.
      await _pumpDetail(
        tester,
        buildTask(resourceType: ActivityResourceType.video),
      );

      expect(find.textContaining('Mark'), findsNothing);
      expect(find.textContaining('done'), findsNothing);
      expect(find.text('Watch the video'), findsOneWidget);
      expect(
        find.textContaining('finishes itself once you have watched'),
        findsOneWidget,
      );
    });

    testWidgets('a document task points at the reader\'s own control', (
      WidgetTester tester,
    ) async {
      await _pumpDetail(
        tester,
        buildTask(
          resourceType: ActivityResourceType.document,
          resourceId: 'doc-1',
          resourceTitle: 'Worksheet',
        ),
      );

      expect(find.text('Open the document'), findsOneWidget);
      // Named identically to the reader's app-bar control, and not duplicated
      // here — two completions under two names would be a lie.
      expect(
        find.textContaining('"Mark as read" inside the document'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Mark as read'), findsNothing);
    });
  });
}

Future<void> _pumpList(
  WidgetTester tester,
  FakeStudentTaskRepository tasks,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(studentTasks: tasks),
      child: const MaterialApp(home: Scaffold(body: MyTasksScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpDetail(WidgetTester tester, TaskEntity task) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        studentTasks: FakeStudentTaskRepository(
          assignments: <StudentTaskEntity>[buildStudentTask(task: task)],
        ),
      ),
      child: MaterialApp(home: StudentTaskDetailScreen(taskId: task.id)),
    ),
  );
  await tester.pumpAndSettle();
}
