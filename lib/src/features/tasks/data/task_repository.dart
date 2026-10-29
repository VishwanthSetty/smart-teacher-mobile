import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../domain/task_entity.dart';

/// The teacher half of `/tasks` (backend plan §5.4).
///
/// Role-gated to `TEACHER` server-side, and every read is already narrowed to
/// tasks **this** teacher created — `createdById: actor.sub` is baked into the
/// query. Unlike `/teacher-assignments`, there is no unscoped variant of this
/// call to accidentally make.
///
/// Deliberately **not** routed through the outbox. Creating a task fans out to
/// real students and can fail in ways the teacher has to resolve (a `422`
/// naming recipients who cannot reach the resource); reporting it as sent and
/// reconciling later would be the wrong trade entirely.
abstract class TaskRepository {
  /// `GET /tasks?status=&sectionId=&subjectId=` — a flat array, newest first.
  Future<List<TaskEntity>> fetchTasks({
    TaskLifecycleStatus? status,
    String? sectionId,
    String? subjectId,
  });

  /// `GET /tasks/:id` — includes the recipient rows, so the detail screen can
  /// show completion counts without the phase-5 report endpoint.
  Future<TaskEntity> fetchTask(String id);

  /// `POST /tasks`.
  ///
  /// Exactly one of [sectionId] / [studentIds] is sent — the server rejects
  /// both and neither with a `400`, and the assign flow's recipient step is
  /// built so that only one can be chosen.
  ///
  /// Throws [TaskRecipientsUnreachable] on the `422` that names students whose
  /// own scope does not include the resource, so the flow can list them by name
  /// and let the teacher deselect rather than silently dropping them.
  Future<TaskEntity> createTask({
    required String title,
    required ActivityResourceType resourceType,
    required String resourceId,
    String? instructions,
    DateTime? dueAt,
    String? sectionId,
    List<String>? studentIds,
  });

  /// `PATCH /tasks/:id` — title, instructions and due date only. The resource
  /// and the recipient set are immutable (backend plan §5.4); there is no
  /// method here that could change either.
  Future<TaskEntity> updateTask({
    required String id,
    String? title,
    String? instructions,
    DateTime? dueAt,
    bool clearDueAt = false,
  });

  /// `POST /tasks/:id/cancel` — soft; the assignments stay for the record.
  Future<TaskEntity> cancelTask(String id);
}

/// The `422` from `POST /tasks`: some recipients cannot reach the resource.
///
/// A distinct type rather than a [ValidationError] because the ids matter — the
/// flow has to turn them back into names and let the teacher act. A
/// grade-mismatched recipient is a mistake worth surfacing, not a silent drop
/// (backend plan §4.3).
class TaskRecipientsUnreachable implements Exception {
  const TaskRecipientsUnreachable({
    required this.studentIds,
    required this.message,
  });

  final List<String> studentIds;
  final String message;

  @override
  String toString() =>
      'TaskRecipientsUnreachable(${studentIds.length} students)';
}

class DioTaskRepository implements TaskRepository {
  const DioTaskRepository(this._dio);

  final Dio _dio;

  static const String tasksPath = '/tasks';

  @override
  Future<List<TaskEntity>> fetchTasks({
    TaskLifecycleStatus? status,
    String? sectionId,
    String? subjectId,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        tasksPath,
        queryParameters: <String, dynamic>{
          // Blank filters omitted rather than sent empty, as everywhere else.
          if (status?.wireValue case final String value) 'status': value,
          if (_trimToNull(sectionId) case final String id) 'sectionId': id,
          if (_trimToNull(subjectId) case final String id) 'subjectId': id,
        },
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <TaskEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskEntity.fromJson)
          .toList(growable: false);
    });
  }

  @override
  Future<TaskEntity> fetchTask(String id) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '$tasksPath/$id',
      );
      return _parseTask(response.data);
    });
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
    // The 422 carries a body the generic mapper would flatten into a message,
    // so it is read here — the one place that knows what `studentIds` means —
    // before `guardApiCall` turns anything else into an AppError.
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        tasksPath,
        data: <String, dynamic>{
          'title': title.trim(),
          if (_trimToNull(instructions) case final String text)
            'instructions': text,
          if (dueAt != null) 'dueAt': dueAt.toUtc().toIso8601String(),
          'resourceType': resourceType.wireValue ?? 'VIDEO',
          'resourceId': resourceId,
          if (_trimToNull(sectionId) case final String id) 'sectionId': id,
          if (studentIds != null && studentIds.isNotEmpty)
            'studentIds': studentIds,
        },
      );
      return _parseTask(response.data);
    } on DioException catch (error) {
      final TaskRecipientsUnreachable? unreachable = _unreachableFrom(error);
      if (unreachable != null) {
        throw unreachable;
      }
      throw AppError.fromDioException(error);
    }
  }

  @override
  Future<TaskEntity> updateTask({
    required String id,
    String? title,
    String? instructions,
    DateTime? dueAt,
    bool clearDueAt = false,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.patch<dynamic>(
        '$tasksPath/$id',
        data: <String, dynamic>{
          if (_trimToNull(title) case final String value) 'title': value,
          if (instructions != null) 'instructions': instructions.trim(),
          // An explicit null clears the due date; omitting the key leaves it
          // alone. The DTO distinguishes the two, so this must as well.
          if (clearDueAt)
            'dueAt': null
          else if (dueAt != null)
            'dueAt': dueAt.toUtc().toIso8601String(),
        },
      );
      return _parseTask(response.data);
    });
  }

  @override
  Future<TaskEntity> cancelTask(String id) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '$tasksPath/$id/cancel',
      );
      return _parseTask(response.data);
    });
  }
}

/// Reads the `422` body, or answers null if this wasn't one.
TaskRecipientsUnreachable? _unreachableFrom(DioException error) {
  if (error.response?.statusCode != 422) {
    return null;
  }
  final dynamic body = error.response?.data;
  if (body is! Map<String, dynamic>) {
    return null;
  }
  final dynamic ids = body['studentIds'];
  return TaskRecipientsUnreachable(
    studentIds: ids is List<dynamic>
        ? ids.map((dynamic id) => id.toString()).toList(growable: false)
        : const <String>[],
    message:
        body['message']?.toString() ??
        'Some students cannot open this resource.',
  );
}

TaskEntity _parseTask(dynamic data) => switch (data) {
  final Map<String, dynamic> row => TaskEntity.fromJson(row),
  // A write that answered with something unreadable is still a write that
  // happened; the caller re-reads the list rather than treating it as failure.
  _ => const TaskEntity(id: ''),
};

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

final Provider<TaskRepository> taskRepositoryProvider = Provider<TaskRepository>(
  (Ref ref) => DioTaskRepository(ref.watch(dioProvider)),
);
