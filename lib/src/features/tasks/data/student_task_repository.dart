import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../domain/task_entity.dart';

/// The student half of tasks: `GET /me/tasks` and `GET /me/tasks/:id`
/// (backend plan §5.4).
///
/// A separate repository from `TaskRepository` because these are separate
/// endpoints with separate role gates and separate shapes — `/me/tasks` returns
/// **assignments** with the task nested, `/tasks` returns tasks with the
/// assignments nested. Folding them together would mean one method that lied
/// about what it returns depending on who called it.
///
/// **There is no write here, and there must never be one.** A task's status is
/// a projection of the linked resource's progress (backend plan §6): the
/// student completes the video or marks the document read, and the task
/// follows. A `POST /me/tasks/:id/complete` does not exist, and a button that
/// only sometimes worked would be worse than none (mobile plan §5.6).
abstract class StudentTaskRepository {
  /// `GET /me/tasks?status=&overdue=`.
  ///
  /// The screen's three sections are computed locally from one unfiltered
  /// read — the server's `?overdue=` would need a second call to render the
  /// same page, and the split is a pure function of `dueAt` and `status`.
  Future<List<StudentTaskEntity>> fetchMyTasks({
    ActivityProgressStatus? status,
    bool? overdue,
  });

  /// `GET /me/tasks/:id`.
  ///
  /// Answers `404` both for "no such task" and for "exists, but not yours"
  /// (backend plan §4.4) — the detail screen renders `NotFoundView` for it and
  /// never words it as a refusal.
  Future<TaskEntity> fetchMyTask(String id);
}

class DioStudentTaskRepository implements StudentTaskRepository {
  const DioStudentTaskRepository(this._dio);

  final Dio _dio;

  static const String myTasksPath = '/me/tasks';

  @override
  Future<List<StudentTaskEntity>> fetchMyTasks({
    ActivityProgressStatus? status,
    bool? overdue,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        myTasksPath,
        queryParameters: <String, dynamic>{
          if (status?.wireValue case final String value) 'status': value,
          // Only ever sent when true: `?overdue=false` is a filter the server
          // is free to interpret, and "show me everything" is the absence of
          // the parameter, not a false one.
          if (overdue ?? false) 'overdue': true,
        },
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <StudentTaskEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(StudentTaskEntity.fromJson)
          .toList(growable: false);
    });
  }

  @override
  Future<TaskEntity> fetchMyTask(String id) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '$myTasksPath/$id',
      );
      return switch (response.data) {
        final Map<String, dynamic> row => TaskEntity.fromJson(row),
        _ => const TaskEntity(id: ''),
      };
    });
  }
}

final Provider<StudentTaskRepository> studentTaskRepositoryProvider =
    Provider<StudentTaskRepository>(
      (Ref ref) => DioStudentTaskRepository(ref.watch(dioProvider)),
    );
