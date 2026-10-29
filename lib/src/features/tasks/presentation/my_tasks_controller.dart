import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/session/session_scoped_cache.dart';
import '../data/student_task_repository.dart';
import '../domain/task_entity.dart';

/// The student's task list (mobile plan §5.6).
///
/// One unfiltered read, split into **Overdue / Due soon / Completed** by
/// [groupStudentTasks]. The server's `?status=` and `?overdue=` exist, but
/// rendering the plan's three sections from them would mean three calls for one
/// screen — and the split is a pure function of `dueAt` and `status`, which is
/// what makes it a unit test rather than an integration one.
///
/// Shaped like `LibraryController`: always fetches in [build], the same
/// `refresh()`, the same suppressed automatic retry.
class MyTasksController extends AsyncNotifier<List<StudentTaskEntity>> {
  bool _refreshing = false;

  @override
  Future<List<StudentTaskEntity>> build() {
    invalidateOnSignOut(ref);
    return ref.read(studentTaskRepositoryProvider).fetchMyTasks();
  }

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<StudentTaskEntity>> next = await AsyncValue.guard(
        () => ref.read(studentTaskRepositoryProvider).fetchMyTasks(),
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }
}

/// One student task, for the detail screen.
///
/// Auto-disposing and keyed by id, so opening twenty tasks over a session does
/// not pin twenty of them — the same shape `CurriculumTreeController` uses.
///
/// A `404` here is the entitlement answer: `/me/tasks/:id` answers it both for
/// "no such task" and for "not assigned to you" (backend plan §4.4), and the
/// screen renders `NotFoundView` with no retry and no wording that reads as a
/// refusal.
class StudentTaskDetailController extends AsyncNotifier<TaskEntity> {
  StudentTaskDetailController(this.taskId);

  final String taskId;

  @override
  Future<TaskEntity> build() =>
      ref.read(studentTaskRepositoryProvider).fetchMyTask(taskId);

  Future<void> refresh() async {
    final AsyncValue<TaskEntity> next = await AsyncValue.guard(
      () => ref.read(studentTaskRepositoryProvider).fetchMyTask(taskId),
    );
    if (ref.mounted) {
      state = next;
    }
  }
}

/// Neither controller confirms the suspension latch: `SuspensionInterceptor`
/// already observes these calls, and both endpoints are role-gated rather than
/// entitlement-scoped, so their `403` has an innocent reading `/curricula`'s
/// does not.
final AsyncNotifierProvider<MyTasksController, List<StudentTaskEntity>>
myTasksControllerProvider =
    AsyncNotifierProvider<MyTasksController, List<StudentTaskEntity>>(
      MyTasksController.new,
      retry: (int retryCount, Object error) => null,
    );

final AsyncNotifierProviderFamily<
  StudentTaskDetailController,
  TaskEntity,
  String
>
studentTaskDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<StudentTaskDetailController, TaskEntity, String>(
      StudentTaskDetailController.new,
      retry: (int retryCount, Object error) => null,
    );
