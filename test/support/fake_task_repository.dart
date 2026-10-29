import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/student_task_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/task_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_entity.dart';

TaskAssignmentEntity buildAssignment({
  String id = 'assignment-1',
  String studentId = 'student-1',
  ActivityProgressStatus status = ActivityProgressStatus.notStarted,
  DateTime? completedAt,
  DateTime? preCompletedAt,
}) => TaskAssignmentEntity(
  id: id,
  studentId: studentId,
  status: status,
  completedAt: completedAt,
  preCompletedAt: preCompletedAt,
);

TaskEntity buildTask({
  String id = 'task-1',
  String title = 'Watch the photosynthesis video',
  String? instructions = 'Take notes as you go.',
  DateTime? dueAt,
  ActivityResourceType resourceType = ActivityResourceType.video,
  String resourceId = 'video-1',
  String resourceTitle = 'Photosynthesis',
  TaskLifecycleStatus status = TaskLifecycleStatus.active,
  String? sectionId = 'section-1',
  List<TaskAssignmentEntity>? assignments,
}) {
  final bool isVideo = resourceType == ActivityResourceType.video;
  return TaskEntity(
    id: id,
    title: title,
    instructions: instructions,
    dueAt: dueAt,
    resourceType: resourceType,
    videoId: isVideo ? resourceId : null,
    documentId: isVideo ? null : resourceId,
    status: status,
    sectionId: sectionId,
    video: isVideo ? TaskResourceRef(id: resourceId, title: resourceTitle) : null,
    document: isVideo
        ? null
        : TaskResourceRef(id: resourceId, title: resourceTitle),
    assignments: assignments ?? const <TaskAssignmentEntity>[],
  );
}

StudentTaskEntity buildStudentTask({
  String id = 'assignment-1',
  ActivityProgressStatus status = ActivityProgressStatus.notStarted,
  DateTime? completedAt,
  DateTime? preCompletedAt,
  TaskEntity? task,
}) => StudentTaskEntity(
  id: id,
  status: status,
  completedAt: completedAt,
  preCompletedAt: preCompletedAt,
  task: task ?? buildTask(),
);

/// **Records every create's arguments**, since the recipient shape is the thing
/// worth catching: sending both a `sectionId` and `studentIds` — or neither —
/// is a `400` the server would answer, and a fake that only returned a task
/// would let that regression through.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<TaskEntity>? tasks, this.error, this.unreachable})
    : tasks = <TaskEntity>[...?tasks];

  List<TaskEntity> tasks;
  AppError? error;

  /// When set, `createTask` throws it instead of creating — the `422` path.
  TaskRecipientsUnreachable? unreachable;

  final List<
    ({
      String title,
      String resourceId,
      ActivityResourceType type,
      String? sectionId,
      List<String>? studentIds,
      DateTime? dueAt,
    })
  >
  created =
      <({
        String title,
        String resourceId,
        ActivityResourceType type,
        String? sectionId,
        List<String>? studentIds,
        DateTime? dueAt,
      })>[];

  final List<({TaskLifecycleStatus? status, String? sectionId})> listCalls =
      <({TaskLifecycleStatus? status, String? sectionId})>[];

  final List<String> cancelled = <String>[];

  @override
  Future<List<TaskEntity>> fetchTasks({
    TaskLifecycleStatus? status,
    String? sectionId,
    String? subjectId,
  }) async {
    listCalls.add((status: status, sectionId: sectionId));
    _throwIfFailing();
    return tasks
        .where(
          (TaskEntity row) =>
              (status == null || row.status == status) &&
              (sectionId == null || row.sectionId == sectionId),
        )
        .toList(growable: false);
  }

  @override
  Future<TaskEntity> fetchTask(String id) async {
    _throwIfFailing();
    final TaskEntity? found = tasks
        .where((TaskEntity row) => row.id == id)
        .firstOrNull;
    if (found == null) {
      throw const NotFoundError(message: 'Task not found');
    }
    return found;
  }

  @override
  Future<TaskEntity> createTask({
    required String title,
    required ActivityResourceType resourceType,
    required String resourceId,
    String? instructions,
    DateTime? dueAt,
    String? sectionId,
    List<String>? studentIds,
  }) async {
    created.add((
      title: title,
      resourceId: resourceId,
      type: resourceType,
      sectionId: sectionId,
      studentIds: studentIds,
      dueAt: dueAt,
    ));
    final TaskRecipientsUnreachable? rejection = unreachable;
    if (rejection != null) {
      throw rejection;
    }
    _throwIfFailing();
    final TaskEntity task = buildTask(
      id: 'task-${tasks.length + 1}',
      title: title,
      instructions: instructions,
      dueAt: dueAt,
      resourceType: resourceType,
      resourceId: resourceId,
      sectionId: sectionId,
    );
    tasks = <TaskEntity>[task, ...tasks];
    return task;
  }

  @override
  Future<TaskEntity> updateTask({
    required String id,
    String? title,
    String? instructions,
    DateTime? dueAt,
    bool clearDueAt = false,
  }) async {
    _throwIfFailing();
    tasks = tasks
        .map(
          (TaskEntity row) => row.id == id
              ? row.copyWith(
                  title: title ?? row.title,
                  instructions: instructions ?? row.instructions,
                  dueAt: clearDueAt ? null : (dueAt ?? row.dueAt),
                )
              : row,
        )
        .toList();
    return tasks.firstWhere((TaskEntity row) => row.id == id);
  }

  @override
  Future<TaskEntity> cancelTask(String id) async {
    cancelled.add(id);
    _throwIfFailing();
    tasks = tasks
        .map(
          (TaskEntity row) => row.id == id
              ? row.copyWith(
                  status: TaskLifecycleStatus.cancelled,
                  cancelledAt: DateTime.now(),
                )
              : row,
        )
        .toList();
    return tasks.firstWhere((TaskEntity row) => row.id == id);
  }

  void _throwIfFailing() {
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
  }
}

class FakeStudentTaskRepository implements StudentTaskRepository {
  FakeStudentTaskRepository({List<StudentTaskEntity>? assignments, this.error})
    : assignments = <StudentTaskEntity>[...?assignments];

  List<StudentTaskEntity> assignments;
  AppError? error;

  final List<({ActivityProgressStatus? status, bool? overdue})> listCalls =
      <({ActivityProgressStatus? status, bool? overdue})>[];

  @override
  Future<List<StudentTaskEntity>> fetchMyTasks({
    ActivityProgressStatus? status,
    bool? overdue,
  }) async {
    listCalls.add((status: status, overdue: overdue));
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
    return List<StudentTaskEntity>.unmodifiable(assignments);
  }

  @override
  Future<TaskEntity> fetchMyTask(String id) async {
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
    final TaskEntity? found = assignments
        .map((StudentTaskEntity row) => row.task)
        .nonNulls
        .where((TaskEntity row) => row.id == id)
        .firstOrNull;
    if (found == null) {
      throw const NotFoundError(message: 'Task not found');
    }
    return found;
  }
}
