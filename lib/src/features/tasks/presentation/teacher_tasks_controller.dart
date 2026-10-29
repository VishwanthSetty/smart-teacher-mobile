import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/session/session_scoped_cache.dart';
import '../data/task_repository.dart';
import '../domain/task_entity.dart';

/// The teacher's task-list filters (mobile plan §5.9).
///
/// Its own notifier, watched by the controller, so **changing a filter
/// re-queries by construction** rather than by remembering to — the same
/// arrangement as `rosterQueryProvider` and the history chips.
@immutable
class TeacherTaskQuery {
  const TeacherTaskQuery({this.status = TaskLifecycleStatus.active, this.sectionId});

  /// Defaults to **Active**, not to "all". A teacher opening Tasks wants what
  /// is outstanding; cancelled tasks are kept for the record and are a
  /// deliberate thing to go looking for.
  final TaskLifecycleStatus? status;
  final String? sectionId;

  TeacherTaskQuery copyWith({
    TaskLifecycleStatus? status,
    String? sectionId,
    bool clearStatus = false,
    bool clearSection = false,
  }) => TeacherTaskQuery(
    status: clearStatus ? null : (status ?? this.status),
    sectionId: clearSection ? null : (sectionId ?? this.sectionId),
  );

  @override
  bool operator ==(Object other) =>
      other is TeacherTaskQuery &&
      other.status == status &&
      other.sectionId == sectionId;

  @override
  int get hashCode => Object.hash(status, sectionId);
}

class TeacherTaskQueryNotifier extends Notifier<TeacherTaskQuery> {
  @override
  TeacherTaskQuery build() => const TeacherTaskQuery();

  void setStatus(TaskLifecycleStatus? status) {
    final TeacherTaskQuery next = status == null
        ? state.copyWith(clearStatus: true)
        : state.copyWith(status: status);
    if (next != state) {
      state = next;
    }
  }

  void setSection(String? sectionId) {
    final TeacherTaskQuery next = sectionId == null
        ? state.copyWith(clearSection: true)
        : state.copyWith(sectionId: sectionId);
    if (next != state) {
      state = next;
    }
  }
}

/// The teacher's tasks (mobile plan §5.9).
///
/// `GET /tasks` is already narrowed server-side to tasks **this** teacher
/// created, so nothing here filters by author. It returns a flat array, so
/// there is no paging affordance — the same call the rest of the app's flat
/// lists make.
class TeacherTasksController extends AsyncNotifier<List<TaskEntity>> {
  bool _refreshing = false;

  @override
  Future<List<TaskEntity>> build() {
    invalidateOnSignOut(ref);
    final TeacherTaskQuery query = ref.watch(teacherTaskQueryProvider);
    return _fetch(query);
  }

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<TaskEntity>> next = await AsyncValue.guard(
        () => _fetch(ref.read(teacherTaskQueryProvider)),
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<List<TaskEntity>> _fetch(TeacherTaskQuery query) => ref
      .read(taskRepositoryProvider)
      .fetchTasks(status: query.status, sectionId: query.sectionId);
}

/// One task, for the teacher's detail screen.
///
/// Auto-disposing and keyed by id, like the curriculum tree: opening twenty
/// tasks over a session should not pin twenty of them.
class TaskDetailController extends AsyncNotifier<TaskEntity> {
  TaskDetailController(this.taskId);

  final String taskId;

  @override
  Future<TaskEntity> build() =>
      ref.read(taskRepositoryProvider).fetchTask(taskId);

  Future<void> refresh() async {
    final AsyncValue<TaskEntity> next = await AsyncValue.guard(
      () => ref.read(taskRepositoryProvider).fetchTask(taskId),
    );
    if (ref.mounted) {
      state = next;
    }
  }

  /// Title, instructions and due date only. The resource and the recipients are
  /// immutable (backend plan §5.4) and there is no method here that could
  /// change either.
  ///
  /// Throws its `AppError` at the caller rather than parking it in [state]: the
  /// edit sheet needs to keep the teacher's typing on screen while it reports
  /// what went wrong.
  /// Named `updateDetails` rather than `update`, which `AsyncNotifier` already
  /// defines with an incompatible signature.
  Future<void> updateDetails({
    String? title,
    String? instructions,
    DateTime? dueAt,
    bool clearDueAt = false,
  }) async {
    final TaskEntity updated = await ref
        .read(taskRepositoryProvider)
        .updateTask(
          id: taskId,
          title: title,
          instructions: instructions,
          dueAt: dueAt,
          clearDueAt: clearDueAt,
        );
    if (ref.mounted) {
      state = AsyncData<TaskEntity>(updated);
    }
    // The list behind this screen shows the title and due date, so it would
    // otherwise keep the old ones until the teacher pulled to refresh.
    await ref.read(teacherTasksControllerProvider.notifier).refresh();
  }

  /// **Soft** — the assignments stay for the record, which is why the list
  /// still shows the task under its Cancelled filter afterwards.
  Future<void> cancel() async {
    final TaskEntity cancelled = await ref
        .read(taskRepositoryProvider)
        .cancelTask(taskId);
    if (ref.mounted) {
      state = AsyncData<TaskEntity>(cancelled);
    }
    await ref.read(teacherTasksControllerProvider.notifier).refresh();
  }
}

final NotifierProvider<TeacherTaskQueryNotifier, TeacherTaskQuery>
teacherTaskQueryProvider =
    NotifierProvider<TeacherTaskQueryNotifier, TeacherTaskQuery>(
      TeacherTaskQueryNotifier.new,
    );

final AsyncNotifierProvider<TeacherTasksController, List<TaskEntity>>
teacherTasksControllerProvider =
    AsyncNotifierProvider<TeacherTasksController, List<TaskEntity>>(
      TeacherTasksController.new,
      retry: (int retryCount, Object error) => null,
    );

final AsyncNotifierProviderFamily<TaskDetailController, TaskEntity, String>
taskDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TaskDetailController, TaskEntity, String>(
      TaskDetailController.new,
      retry: (int retryCount, Object error) => null,
    );
