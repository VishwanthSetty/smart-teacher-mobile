import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/home/domain/home_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/task_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/assign_task_controller.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/assign_task_sheet.dart';
import 'package:smart_teacher_mobile/src/features/tasks/presentation/teacher_tasks_controller.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_home_repository.dart';
import '../../support/fake_task_repository.dart';

const AssignableResource _resource = AssignableResource(
  id: 'video-1',
  type: ActivityResourceType.video,
  title: 'Photosynthesis',
);

void main() {
  group('recipients (backend plan §4.2)', () {
    testWidgets('a teacher with no section-bearing class cannot proceed', (
      WidgetTester tester,
    ) async {
      // `TeacherClassScopeService` fails closed and the server refuses such a
      // teacher outright. The flow says so rather than merely hiding a control.
      // Entered from a resource, so the flow opens straight on the recipient
      // step — which is where it stops.
      await _pumpSheet(tester, sections: const <HomeClassEntity>[]);

      expect(find.text("You aren't assigned to a class yet"), findsOneWidget);
      // Nothing to advance to: the recipient step cannot be satisfied.
      final FilledButton next = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(next.onPressed, isNull);
    });

    test('choosing a section clears any chosen students, and vice versa', () {
      // The server takes exactly one of the two and rejects both or neither
      // with a `400`, so the flow makes the invalid state unreachable.
      final ProviderContainer container = _container();
      final AssignTaskController controller = container.read(
        assignTaskControllerProvider.notifier,
      );

      controller.toggleStudent('student-1');
      expect(container.read(assignTaskControllerProvider).sectionId, isNull);

      controller.selectSection('section-1');
      expect(container.read(assignTaskControllerProvider).studentIds, isEmpty);

      controller.toggleStudent('student-2');
      expect(container.read(assignTaskControllerProvider).sectionId, isNull);
    });
  });

  group('submitting (mobile plan §5.8)', () {
    test('a class task sends a sectionId and no studentIds', () async {
      final FakeTaskRepository tasks = FakeTaskRepository();
      final ProviderContainer container = _container(tasks: tasks);
      final AssignTaskController controller = container.read(
        assignTaskControllerProvider.notifier,
      );

      controller
        ..selectResource(_resource)
        ..selectSection('section-1')
        ..setTitle('Watch this');

      expect(await controller.submit(), isTrue);
      expect(tasks.created.single.sectionId, 'section-1');
      expect(tasks.created.single.studentIds, isNull);
      expect(tasks.created.single.resourceId, 'video-1');
    });

    test('a per-student task sends studentIds and no sectionId', () async {
      final FakeTaskRepository tasks = FakeTaskRepository();
      final ProviderContainer container = _container(tasks: tasks);
      final AssignTaskController controller = container.read(
        assignTaskControllerProvider.notifier,
      );

      controller
        ..selectResource(_resource)
        ..selectStudents(<String>['student-1', 'student-2'])
        ..setTitle('Watch this');

      expect(await controller.submit(), isTrue);
      expect(tasks.created.single.sectionId, isNull);
      expect(tasks.created.single.studentIds, <String>[
        'student-1',
        'student-2',
      ]);
    });

    test('a 422 names the students instead of dropping them', () async {
      // A grade-mismatched recipient is a teacher mistake worth surfacing, not
      // a silent drop (backend plan §4.3).
      final FakeTaskRepository tasks = FakeTaskRepository(
        unreachable: const TaskRecipientsUnreachable(
          studentIds: <String>['student-2'],
          message: 'Some students cannot access this resource',
        ),
      );
      final ProviderContainer container = _container(tasks: tasks);
      final AssignTaskController controller = container.read(
        assignTaskControllerProvider.notifier,
      );

      controller
        ..selectResource(_resource)
        ..selectStudents(<String>['student-1', 'student-2'])
        ..setTitle('Watch this');

      expect(await controller.submit(), isFalse);

      final AssignTaskState state = container.read(assignTaskControllerProvider);
      expect(state.unreachableStudentIds, <String>['student-2']);
      // The selection is kept, so the teacher can deselect and retry rather
      // than rebuilding the whole task.
      expect(state.studentIds, hasLength(2));
      expect(state.isSubmitting, isFalse);
    });

    test('a submit without a resource or recipients does nothing', () async {
      final FakeTaskRepository tasks = FakeTaskRepository();
      final ProviderContainer container = _container(tasks: tasks);
      final AssignTaskController controller = container.read(
        assignTaskControllerProvider.notifier,
      );

      controller.setTitle('Watch this');
      expect(await controller.submit(), isFalse);

      controller.selectResource(_resource);
      expect(await controller.submit(), isFalse);

      expect(tasks.created, isEmpty);
    });

    test('the title defaults to the resource but stays editable', () {
      final ProviderContainer container = _container();
      final AssignTaskController controller = container.read(
        assignTaskControllerProvider.notifier,
      );

      controller.selectResource(_resource);
      expect(container.read(assignTaskControllerProvider).title, 'Photosynthesis');

      controller.setTitle('Homework for Monday');
      controller.selectResource(_resource);
      // A resource re-picked must not clobber what the teacher typed.
      expect(
        container.read(assignTaskControllerProvider).title,
        'Homework for Monday',
      );
    });
  });
}

ProviderContainer _container({FakeTaskRepository? tasks}) {
  final ProviderContainer container = ProviderContainer(
    overrides: activityOverrides(tasks: tasks ?? FakeTaskRepository()),
  );
  addTearDown(container.dispose);
  container.listen(assignTaskControllerProvider, (_, _) {});
  container.listen(teacherTasksControllerProvider, (_, _) {});
  return container;
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required List<HomeClassEntity> sections,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        home: FakeHomeRepository(
          teacher: TeacherHomeEntity(classes: sections),
        ),
      ),
      child: const MaterialApp(
        home: Scaffold(body: AssignTaskSheet(initialResource: _resource)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
