import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/tasks/data/task_progress_repository.dart';
import 'package:smart_teacher_mobile/src/features/tasks/domain/task_progress_entity.dart';

TaskProgressRowEntity buildProgressRow({
  String id = 'assignment-1',
  String? studentId = 'student-1',
  String? name = 'Asha Rao',
  String? email = 'asha@example.test',
  ActivityProgressStatus status = ActivityProgressStatus.notStarted,
  DateTime? completedAt,
  DateTime? preCompletedAt,
}) => TaskProgressRowEntity(
  id: id,
  studentId: studentId,
  status: status,
  completedAt: completedAt,
  preCompletedAt: preCompletedAt,
  student: TaskProgressStudentRef(name: name, email: email),
);

ClassProgressRowEntity buildClassProgressRow({
  String taskId = 'task-1',
  String title = 'Watch the photosynthesis video',
  String? sectionId = 'section-1',
  int total = 3,
  int notStarted = 1,
  int inProgress = 1,
  int completed = 1,
  int preCompleted = 0,
}) => ClassProgressRowEntity(
  taskId: taskId,
  title: title,
  sectionId: sectionId,
  total: total,
  notStarted: notStarted,
  inProgress: inProgress,
  completed: completed,
  preCompleted: preCompleted,
);

/// **Records every remind and every class-progress query**, for the same reason
/// the task and student fakes record theirs: a *Remind pending* that fired twice
/// on one press, or a section filter that quietly wasn't sent, both return a
/// plausible-looking screen either way.
///
/// [remindedCount] is what `POST /tasks/:id/remind` answers. Setting it to `0`
/// is how a test exercises the per-day dedupe — which is indistinguishable on
/// the wire from "nobody was pending", and is exactly the ambiguity the
/// controller resolves.
class FakeTaskProgressRepository implements TaskProgressRepository {
  FakeTaskProgressRepository({
    List<TaskProgressRowEntity>? rows,
    List<ClassProgressRowEntity>? classRows,
    this.studentActivity,
    this.remindedCount = 1,
    this.error,
    this.studentActivityError,
  }) : rows = <TaskProgressRowEntity>[...?rows],
       classRows = <ClassProgressRowEntity>[...?classRows];

  List<TaskProgressRowEntity> rows;
  List<ClassProgressRowEntity> classRows;

  /// `null` is a real answer here — the student has never opened the resource —
  /// and is the fake's default for exactly that reason.
  ResourceActivityEntity? studentActivity;

  int remindedCount;
  AppError? error;

  /// Thrown only by [fetchStudentActivity], so a test can exercise the `404`
  /// for an out-of-scope student without failing the list behind it.
  AppError? studentActivityError;

  final List<({String taskId, ActivityProgressStatus? status})> progressCalls =
      <({String taskId, ActivityProgressStatus? status})>[];

  final List<String> reminded = <String>[];

  final List<({String? sectionId, String? subjectId, String? taskId})>
  classProgressCalls =
      <({String? sectionId, String? subjectId, String? taskId})>[];

  @override
  Future<List<TaskProgressRowEntity>> fetchTaskProgress(
    String taskId, {
    ActivityProgressStatus? status,
  }) async {
    progressCalls.add((taskId: taskId, status: status));
    _throwIfFailing();
    // Implements the filter the endpoint offers, even though the screen never
    // sends one — so a regression to per-tab fetching would be visible rather
    // than silently returning the same rows.
    return rows
        .where(
          (TaskProgressRowEntity row) => status == null || row.status == status,
        )
        .toList(growable: false);
  }

  @override
  Future<ResourceActivityEntity?> fetchStudentActivity({
    required String taskId,
    required String studentId,
  }) async {
    final AppError? failure = studentActivityError;
    if (failure != null) {
      throw failure;
    }
    _throwIfFailing();
    return studentActivity;
  }

  @override
  Future<TaskReminderResult> remindPending(String taskId) async {
    reminded.add(taskId);
    _throwIfFailing();
    return TaskReminderResult(reminded: remindedCount);
  }

  @override
  Future<List<ClassProgressRowEntity>> fetchClassProgress({
    String? sectionId,
    String? subjectId,
    String? taskId,
  }) async {
    classProgressCalls.add((
      sectionId: sectionId,
      subjectId: subjectId,
      taskId: taskId,
    ));
    _throwIfFailing();
    return classRows
        .where(
          (ClassProgressRowEntity row) =>
              sectionId == null || row.sectionId == sectionId,
        )
        .toList(growable: false);
  }

  void _throwIfFailing() {
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
  }
}
