import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../domain/task_progress_entity.dart';

/// The teacher's reporting reads (backend plan §5.4, mobile plan §5.9).
///
/// Separate from [TaskRepository] because these are a different question about
/// the same records: that one owns a task's *lifecycle* (create, edit, cancel),
/// this one owns what has happened against it. Keeping them apart is also what
/// stops the assign flow from depending on a class-scope service it never uses.
///
/// **Every call here is narrower than the school.** `forTask` and
/// `studentActivity` resolve through `createdById: actor.sub`, and
/// `studentActivity` additionally runs `TeacherClassScopeService.includesStudent`
/// — a student outside the teacher's class scope is a `404`, not a `403`
/// (backend plan §4.4). There is deliberately **no school-wide student picker**
/// anywhere in this feature: the server would refuse it, and offering one would
/// advertise students this teacher cannot report on.
abstract class TaskProgressRepository {
  /// `GET /tasks/:id/progress?status=` — one row per recipient, by student name.
  Future<List<TaskProgressRowEntity>> fetchTaskProgress(
    String taskId, {
    ActivityProgressStatus? status,
  });

  /// `GET /tasks/:id/students/:studentId` — that student's `ResourceActivity`
  /// for the task's resource.
  ///
  /// **Nullable, and `null` is a real answer**: the server returns Prisma's
  /// `findFirst`, which is `null` for a student who has never opened the
  /// resource. That is "not started", not a failure, and it is different again
  /// from the `404` a student outside the teacher's scope produces.
  Future<ResourceActivityEntity?> fetchStudentActivity({
    required String taskId,
    required String studentId,
  });

  /// `POST /tasks/:id/remind` — reminds every pending recipient.
  ///
  /// Returns how many were actually sent. The server dedupes per UTC day, so a
  /// repeat press answers `0`; the caller turns that into
  /// [TaskReminderOutcome], which is what the UI reports.
  Future<TaskReminderResult> remindPending(String taskId);

  /// `GET /teacher/class-progress?sectionId=&subjectId=&taskId=` — a per-task
  /// rollup across the teacher's own class scope.
  Future<List<ClassProgressRowEntity>> fetchClassProgress({
    String? sectionId,
    String? subjectId,
    String? taskId,
  });
}

class DioTaskProgressRepository implements TaskProgressRepository {
  const DioTaskProgressRepository(this._dio);

  final Dio _dio;

  static const String tasksPath = '/tasks';
  static const String classProgressPath = '/teacher/class-progress';

  @override
  Future<List<TaskProgressRowEntity>> fetchTaskProgress(
    String taskId, {
    ActivityProgressStatus? status,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '$tasksPath/$taskId/progress',
        queryParameters: <String, dynamic>{
          // Omitted rather than sent blank, as everywhere else — `?status=` is
          // a value the server is free to read as a filter matching nothing.
          if (status?.wireValue case final String value) 'status': value,
        },
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <TaskProgressRowEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskProgressRowEntity.fromJson)
          .toList(growable: false);
    });
  }

  @override
  Future<ResourceActivityEntity?> fetchStudentActivity({
    required String taskId,
    required String studentId,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '$tasksPath/$taskId/students/$studentId',
      );
      final dynamic data = response.data;
      // A `null` body is the documented "this student has not opened it" answer
      // and must not be turned into an empty row: an activity with id `''`
      // would render as started-at-zero rather than as not started.
      return data is Map<String, dynamic>
          ? ResourceActivityEntity.fromJson(data)
          : null;
    });
  }

  @override
  Future<TaskReminderResult> remindPending(String taskId) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '$tasksPath/$taskId/remind',
      );
      final dynamic data = response.data;
      return data is Map<String, dynamic>
          ? TaskReminderResult.fromJson(data)
          : const TaskReminderResult();
    });
  }

  @override
  Future<List<ClassProgressRowEntity>> fetchClassProgress({
    String? sectionId,
    String? subjectId,
    String? taskId,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        classProgressPath,
        queryParameters: <String, dynamic>{
          if (_trimToNull(sectionId) case final String id) 'sectionId': id,
          if (_trimToNull(subjectId) case final String id) 'subjectId': id,
          if (_trimToNull(taskId) case final String id) 'taskId': id,
        },
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <ClassProgressRowEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(ClassProgressRowEntity.fromJson)
          .toList(growable: false);
    });
  }
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

final Provider<TaskProgressRepository> taskProgressRepositoryProvider =
    Provider<TaskProgressRepository>(
      (Ref ref) => DioTaskProgressRepository(ref.watch(dioProvider)),
    );
