import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_progress_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/student_task_report_screen.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/task_progress_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_task_progress_repository.dart';
import '../../support/fake_task_repository.dart';

void main() {
  group('task progress tabs (mobile plan §5.9)', () {
    testWidgets('fetches once unfiltered and splits the three tabs locally', (
      WidgetTester tester,
    ) async {
      // Three separately-filtered fetches would let the tabs disagree about the
      // size of the class, and would leave *Remind pending* unable to see how
      // many recipients are actually pending.
      final FakeTaskProgressRepository progress = FakeTaskProgressRepository(
        rows: _threeStudents(),
      );
      await _pumpProgress(tester, progress);

      expect(progress.progressCalls, hasLength(1));
      expect(progress.progressCalls.single.status, isNull);
    });

    testWidgets('labels each tab with its own count', (
      WidgetTester tester,
    ) async {
      await _pumpProgress(
        tester,
        FakeTaskProgressRepository(rows: _threeStudents()),
      );

      expect(find.text('Not started (1)'), findsOneWidget);
      expect(find.text('In progress (1)'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);
    });

    testWidgets('an unrecognised status is filed under Not started', (
      WidgetTester tester,
    ) async {
      // A status this build cannot name still belongs on the tab the teacher
      // will act from — they demonstrably have not finished.
      await _pumpProgress(
        tester,
        FakeTaskProgressRepository(
          rows: <TaskProgressRowEntity>[
            buildProgressRow(status: ActivityProgressStatus.unknown),
          ],
        ),
      );

      expect(find.text('Not started (1)'), findsOneWidget);
      expect(find.text('Completed (0)'), findsOneWidget);
    });

    testWidgets('flags a pre-completion rather than folding it in', (
      WidgetTester tester,
    ) async {
      await _pumpProgress(
        tester,
        FakeTaskProgressRepository(
          rows: <TaskProgressRowEntity>[
            buildProgressRow(
              status: ActivityProgressStatus.notStarted,
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

    testWidgets('falls back to the email when a row has no name', (
      WidgetTester tester,
    ) async {
      // One row missing a name must not leave an unidentifiable line in a
      // report, the same rule `StudentEntity.displayName` follows.
      await _pumpProgress(
        tester,
        FakeTaskProgressRepository(
          rows: <TaskProgressRowEntity>[
            buildProgressRow(name: null, email: 'nobody@example.test'),
          ],
        ),
      );

      expect(find.text('nobody@example.test'), findsOneWidget);
    });
  });

  group('remind pending (mobile plan §5.9)', () {
    testWidgets('reports a real send', (WidgetTester tester) async {
      final FakeTaskProgressRepository progress = FakeTaskProgressRepository(
        rows: _threeStudents(),
      );
      await _pumpProgress(tester, progress);

      await _tapRemind(tester);

      expect(progress.reminded, <String>['task-1']);
      expect(find.text('Reminder sent.'), findsOneWidget);
    });

    testWidgets('says "already sent today" when the server deduped', (
      WidgetTester tester,
    ) async {
      // The per-day unique index swallowed every write, so `{ reminded: 0 }`
      // came back having sent nothing. §5.9 is explicit that the UI must say so
      // rather than pretend it sent another.
      final FakeTaskProgressRepository progress = FakeTaskProgressRepository(
        rows: _threeStudents(),
        remindedCount: 0,
      );
      await _pumpProgress(tester, progress);

      await _tapRemind(tester);

      expect(find.text('Reminder already sent today.'), findsOneWidget);
    });

    testWidgets('does not call the server when nobody is pending', (
      WidgetTester tester,
    ) async {
      // The other cause of `{ reminded: 0 }`, told apart here because the rows
      // are in hand — the wire cannot distinguish the two.
      final FakeTaskProgressRepository progress = FakeTaskProgressRepository(
        rows: <TaskProgressRowEntity>[
          buildProgressRow(status: ActivityProgressStatus.completed),
        ],
      );
      await _pumpProgress(tester, progress);

      await _tapRemind(tester);

      expect(progress.reminded, isEmpty);
      expect(find.text('Everyone has completed this task.'), findsOneWidget);
    });

    testWidgets('a cancelled task reminds nobody', (WidgetTester tester) async {
      final FakeTaskProgressRepository progress = FakeTaskProgressRepository(
        rows: _threeStudents(),
      );
      await _pumpProgress(
        tester,
        progress,
        task: buildTask(status: TaskLifecycleStatus.cancelled),
      );

      await _tapRemind(tester);

      // The server returns without even looking at the recipients, so firing
      // the call would be a round trip that could only report a send that never
      // happened.
      expect(progress.reminded, isEmpty);
      expect(
        find.text('This task is cancelled, so nobody was reminded.'),
        findsOneWidget,
      );
    });
  });

  group('individual student report (mobile plan §5.9)', () {
    testWidgets('a null activity reads as "hasn\'t opened", not as zero', (
      WidgetTester tester,
    ) async {
      // `findFirst` answers null for a student who never opened the resource.
      // A zeroed progress bar would claim a measurement nobody took.
      await _pumpReport(tester, FakeTaskProgressRepository());

      expect(
        find.text("This student hasn't opened the material yet."),
        findsOneWidget,
      );
    });

    testWidgets('shows the server\'s percent for a video', (
      WidgetTester tester,
    ) async {
      await _pumpReport(
        tester,
        FakeTaskProgressRepository(
          studentActivity: const ResourceActivityEntity(
            id: 'activity-1',
            resourceType: ActivityResourceType.video,
            videoId: 'video-1',
            status: ActivityProgressStatus.inProgress,
            percent: 42,
            positionSecs: 125,
          ),
        ),
      );

      expect(find.text('42%'), findsOneWidget);
      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('a document shows a bare page when the count is unknown', (
      WidgetTester tester,
    ) async {
      // `Document.pageCount` is null for anything ingested before that work
      // landed; guessing a denominator would be worse than omitting it.
      await _pumpReport(
        tester,
        FakeTaskProgressRepository(
          studentActivity: const ResourceActivityEntity(
            id: 'activity-1',
            resourceType: ActivityResourceType.document,
            documentId: 'doc-1',
            status: ActivityProgressStatus.inProgress,
            lastPage: 7,
          ),
        ),
      );

      expect(find.text('page 7'), findsOneWidget);
    });

    testWidgets('a document that was never marked read says so', (
      WidgetTester tester,
    ) async {
      // Marking as read is the *only* route to COMPLETED for a document, and
      // this screen must never imply that reaching the last page did it.
      await _pumpReport(
        tester,
        FakeTaskProgressRepository(
          studentActivity: const ResourceActivityEntity(
            id: 'activity-1',
            resourceType: ActivityResourceType.document,
            documentId: 'doc-1',
            lastPage: 24,
          ),
        ),
      );

      expect(find.text('Marked as read'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });
  });
}

List<TaskProgressRowEntity> _threeStudents() => <TaskProgressRowEntity>[
  buildProgressRow(
    id: 'a1',
    studentId: 's1',
    name: 'Asha Rao',
    status: ActivityProgressStatus.notStarted,
  ),
  buildProgressRow(
    id: 'a2',
    studentId: 's2',
    name: 'Bilal Khan',
    status: ActivityProgressStatus.inProgress,
  ),
  buildProgressRow(
    id: 'a3',
    studentId: 's3',
    name: 'Chen Wei',
    status: ActivityProgressStatus.completed,
  ),
];

Future<void> _tapRemind(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FloatingActionButton, 'Remind pending'));
  await tester.pumpAndSettle();
}

Future<void> _pumpProgress(
  WidgetTester tester,
  FakeTaskProgressRepository progress, {
  TaskEntity? task,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        taskProgress: progress,
        tasks: FakeTaskRepository(tasks: <TaskEntity>[task ?? buildTask()]),
      ),
      child: const MaterialApp(home: TaskProgressScreen(taskId: 'task-1')),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpReport(
  WidgetTester tester,
  FakeTaskProgressRepository progress,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(taskProgress: progress),
      child: const MaterialApp(
        home: StudentTaskReportScreen(taskId: 'task-1', studentId: 'student-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
