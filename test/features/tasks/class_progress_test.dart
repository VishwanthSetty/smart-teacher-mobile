import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/home/domain/home_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_progress_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/class_progress_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_home_repository.dart';
import '../../support/fake_task_progress_repository.dart';

void main() {
  group('class progress (mobile plan §5.9)', () {
    testWidgets('shows each task with its completion counts', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        FakeTaskProgressRepository(
          classRows: <ClassProgressRowEntity>[
            buildClassProgressRow(
              title: 'Watch the photosynthesis video',
              total: 4,
              notStarted: 2,
              inProgress: 1,
              completed: 1,
            ),
          ],
        ),
      );

      expect(find.text('1 of 4'), findsOneWidget);
      expect(
        find.text('2 not started · 1 in progress · 1 completed'),
        findsOneWidget,
      );
    });

    testWidgets('counts pre-completions separately', (
      WidgetTester tester,
    ) async {
      // So a rollup that was complete on day one is legible as such.
      await _pump(
        tester,
        FakeTaskProgressRepository(
          classRows: <ClassProgressRowEntity>[
            buildClassProgressRow(completed: 3, total: 3, preCompleted: 2),
          ],
        ),
      );

      expect(
        find.textContaining('had already completed this before it was assigned'),
        findsOneWidget,
      );
    });

    testWidgets('an empty rollup is explained, not treated as an error', (
      WidgetTester tester,
    ) async {
      // `TeacherClassScopeService` fails closed, so a teacher with no
      // section-bearing assignment legitimately sees nothing here.
      await _pump(tester, FakeTaskProgressRepository());

      expect(find.text('No active tasks to report on'), findsOneWidget);
    });

    testWidgets('offers no section filter for a teacher with one class', (
      WidgetTester tester,
    ) async {
      // A filter with a single choice is chrome, not a control.
      await _pump(
        tester,
        FakeTaskProgressRepository(
          classRows: <ClassProgressRowEntity>[buildClassProgressRow()],
        ),
        classes: <HomeClassEntity>[
          const HomeClassEntity(id: 'section-1', name: 'A'),
        ],
      );

      expect(find.widgetWithText(ChoiceChip, 'All classes'), findsNothing);
    });

    testWidgets('filtering by section re-queries with that id', (
      WidgetTester tester,
    ) async {
      final FakeTaskProgressRepository progress = FakeTaskProgressRepository(
        classRows: <ClassProgressRowEntity>[
          buildClassProgressRow(sectionId: 'section-1'),
          buildClassProgressRow(taskId: 'task-2', sectionId: 'section-2'),
        ],
      );
      await _pump(
        tester,
        progress,
        classes: <HomeClassEntity>[
          const HomeClassEntity(id: 'section-1', name: 'A', gradeLevelName: 'Grade 5'),
          const HomeClassEntity(id: 'section-2', name: 'B', gradeLevelName: 'Grade 5'),
        ],
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Grade 5 - B'));
      await tester.pumpAndSettle();

      // The controller watches the query notifier, so the re-query happens by
      // construction rather than by remembering to trigger it.
      expect(progress.classProgressCalls, hasLength(2));
      expect(progress.classProgressCalls.last.sectionId, 'section-2');
    });

    testWidgets('the filter offers only classes the teacher teaches', (
      WidgetTester tester,
    ) async {
      // Built from `/home/teacher`, not from the school-wide `/sections`: this
      // endpoint answers `404` for a section outside the teacher's scope.
      await _pump(
        tester,
        FakeTaskProgressRepository(
          classRows: <ClassProgressRowEntity>[buildClassProgressRow()],
        ),
        classes: <HomeClassEntity>[
          const HomeClassEntity(id: 'section-1', name: 'A'),
          const HomeClassEntity(id: 'section-2', name: 'B'),
        ],
      );

      expect(find.byType(ChoiceChip), findsNWidgets(3)); // All + two classes
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeTaskProgressRepository progress, {
  List<HomeClassEntity>? classes,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        taskProgress: progress,
        home: FakeHomeRepository(
          teacher: TeacherHomeEntity(
            classes: classes ?? const <HomeClassEntity>[],
          ),
        ),
      ),
      child: const MaterialApp(home: ClassProgressScreen()),
    ),
  );
  await tester.pumpAndSettle();
}
