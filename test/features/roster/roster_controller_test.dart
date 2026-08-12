import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/pagination/paged_list_state.dart';
import 'package:smart_teacher_mobile/src/features/roster/data/student_repository.dart';
import 'package:smart_teacher_mobile/src/features/roster/domain/student_entity.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/roster_controller.dart';
import 'package:smart_teacher_mobile/src/features/roster/presentation/roster_query.dart';

import '../../support/fake_student_repository.dart';

/// PRD §5.5.2 / §6.5 — paging, and what a filter change does to it.
void main() {
  ProviderContainer makeContainer(FakeStudentRepository repository) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        studentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('the first page', () {
    test('fetches page one at the PRD default limit', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(50));
      final ProviderContainer container = makeContainer(repository);

      final PagedListState<StudentEntity> state =
          await container.read(rosterControllerProvider.future);

      expect(repository.lastCall?.page, 1);
      expect(repository.lastCall?.limit, 20);
      expect(state.items, hasLength(20));
      expect(state.hasMore, isTrue);
      expect(state.total, 50);
    });

    test('sends no filters when none are set', () async {
      final FakeStudentRepository repository = FakeStudentRepository();
      final ProviderContainer container = makeContainer(repository);

      await container.read(rosterControllerProvider.future);

      expect(repository.lastCall?.search, isNull);
      expect(repository.lastCall?.sectionId, isNull);
      expect(repository.lastCall?.status, isNull);
    });

    test('surfaces a failure as an error state, with no silent retry',
        () async {
      final FakeStudentRepository repository = FakeStudentRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      final ProviderContainer container = makeContainer(repository);

      await expectLater(
        container.read(rosterControllerProvider.future),
        throwsA(isA<NetworkError>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repository.callCount, 1);
    });
  });

  group('loading more', () {
    test('appends the next page to the rows already held', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(45));
      final ProviderContainer container = makeContainer(repository);
      await container.read(rosterControllerProvider.future);

      await container.read(rosterControllerProvider.notifier).loadMore();

      final PagedListState<StudentEntity> state =
          container.read(rosterControllerProvider).value!;
      expect(repository.lastCall?.page, 2);
      expect(state.items, hasLength(40));
      expect(state.items.first.displayName, 'Student 1');
      expect(state.items.last.displayName, 'Student 40');
      expect(state.hasMore, isTrue);
    });

    test('stops asking once the last page is in', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(25));
      final ProviderContainer container = makeContainer(repository);
      final RosterController controller =
          container.read(rosterControllerProvider.notifier);
      await container.read(rosterControllerProvider.future);

      await controller.loadMore();
      expect(container.read(rosterControllerProvider).value?.hasMore, isFalse);

      // A widget that keeps firing the scroll trigger must not keep calling.
      await controller.loadMore();
      expect(repository.callCount, 2);
    });

    test('carries the filters into every later page', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(45));
      final ProviderContainer container = makeContainer(repository);
      container.read(rosterQueryProvider.notifier).setSection('section-A');
      await container.read(rosterControllerProvider.future);

      await container.read(rosterControllerProvider.notifier).loadMore();

      // Page 2 of an unfiltered list is a different set of students entirely —
      // a dropped filter here shows rows the user has filtered out.
      expect(repository.lastCall?.page, 2);
      expect(repository.lastCall?.sectionId, 'section-A');
    });

    test('a failed later page keeps the rows and offers a retry', () async {
      final FakeStudentRepository repository = FakeStudentRepository(
        students: buildStudents(45),
        laterPageError: const NetworkError(message: 'Could not reach.'),
      );
      final ProviderContainer container = makeContainer(repository);
      final RosterController controller =
          container.read(rosterControllerProvider.notifier);
      await container.read(rosterControllerProvider.future);

      await controller.loadMore();

      final PagedListState<StudentEntity> failed =
          container.read(rosterControllerProvider).value!;
      expect(failed.items, hasLength(20));
      expect(failed.loadMoreError, isA<NetworkError>());
      expect(failed.isLoadingMore, isFalse);

      repository.laterPageError = null;
      await controller.loadMore();

      expect(
        container.read(rosterControllerProvider).value?.items,
        hasLength(40),
      );
    });

    test('does nothing while the first page is still in flight', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(45));
      final ProviderContainer container = makeContainer(repository);

      // Reading the notifier starts page one; asking for more before it lands
      // must not queue a page two against a list that doesn't exist yet.
      await container.read(rosterControllerProvider.notifier).loadMore();

      expect(repository.calls.map((StudentQuery call) => call.page), <int>[1]);
    });
  });

  group('changing the query', () {
    test('restarts from page one', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(45));
      final ProviderContainer container = makeContainer(repository);
      await container.read(rosterControllerProvider.future);
      await container.read(rosterControllerProvider.notifier).loadMore();

      container.read(rosterQueryProvider.notifier).setSearch('Student 4');
      final PagedListState<StudentEntity> state =
          await container.read(rosterControllerProvider.future);

      expect(repository.lastCall?.page, 1);
      expect(repository.lastCall?.search, 'Student 4');
      // Not appended to the 40 rows from before.
      expect(state.items.length, lessThan(20));
    });

    test('a search that trims to the same term is not re-issued', () async {
      final FakeStudentRepository repository = FakeStudentRepository();
      final ProviderContainer container = makeContainer(repository);
      container.read(rosterQueryProvider.notifier).setSearch('zainab');
      await container.read(rosterControllerProvider.future);
      final int before = repository.callCount;

      container.read(rosterQueryProvider.notifier).setSearch('zainab  ');
      await container.read(rosterControllerProvider.future);

      expect(repository.callCount, before);
    });

    test('clearing the filters goes back to the whole roster', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(30));
      final ProviderContainer container = makeContainer(repository);
      container.read(rosterQueryProvider.notifier)
        ..setSearch('Student 1')
        ..setSection('section-B');
      await container.read(rosterControllerProvider.future);

      container.read(rosterQueryProvider.notifier).clear();
      final PagedListState<StudentEntity> state =
          await container.read(rosterControllerProvider.future);

      expect(repository.lastCall?.search, isNull);
      expect(repository.lastCall?.sectionId, isNull);
      expect(state.total, 30);
    });
  });

  group('refresh', () {
    test('re-reads page one and drops the pages scrolled past', () async {
      final FakeStudentRepository repository =
          FakeStudentRepository(students: buildStudents(45));
      final ProviderContainer container = makeContainer(repository);
      final RosterController controller =
          container.read(rosterControllerProvider.notifier);
      await container.read(rosterControllerProvider.future);
      await controller.loadMore();

      await controller.refresh();

      expect(repository.lastCall?.page, 1);
      expect(
        container.read(rosterControllerProvider).value?.items,
        hasLength(20),
      );
    });

    test('recovers from a first-page failure', () async {
      final FakeStudentRepository repository = FakeStudentRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      final ProviderContainer container = makeContainer(repository);
      await expectLater(
        container.read(rosterControllerProvider.future),
        throwsA(isA<NetworkError>()),
      );

      repository
        ..error = null
        ..students = buildStudents(3);
      await container.read(rosterControllerProvider.notifier).refresh();

      expect(
        container.read(rosterControllerProvider).value?.items,
        hasLength(3),
      );
    });

    test('a second refresh mid-flight is dropped, not queued', () async {
      final FakeStudentRepository repository = FakeStudentRepository();
      final ProviderContainer container = makeContainer(repository);
      await container.read(rosterControllerProvider.future);

      final RosterController controller =
          container.read(rosterControllerProvider.notifier);
      await Future.wait<void>(<Future<void>>[
        controller.refresh(),
        controller.refresh(),
      ]);

      expect(repository.callCount, 2);
    });
  });
}
