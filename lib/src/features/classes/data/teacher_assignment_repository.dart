import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/teacher_assignment_entity.dart';

/// `GET /teacher-assignments?teacherId=` (PRD §5.5.1) — the classes one teacher
/// is assigned to.
///
/// **This endpoint is not auto-scoped to the caller.** Unlike `/curricula`,
/// which the server narrows to exactly what the actor may see (§4), a bare
/// `GET /teacher-assignments` returns *every assignment in the school* — a
/// documented footgun the PRD flags twice (§5.5.1, §9.3). The `teacherId` must
/// come from `GET /users/me`.
///
/// That is why [fetchAssignments] takes it as a **required named argument**
/// rather than reading it from a provider or defaulting it: there is no way to
/// call this repository that forgets the scoping, and a reader can see at every
/// call site which id was passed. The blank-id guard below closes the other
/// half of it — `?teacherId=` with an empty value is a query parameter the
/// server may well read as "no filter", which is the unscoped call wearing a
/// disguise.
///
/// Unpaginated (§6.5) — a flat array, no page/limit affordances.
abstract class TeacherAssignmentRepository {
  /// Throws an [AppError] — never a `DioException`.
  ///
  /// An empty list is a legitimate answer (§6.4), not an error: a newly
  /// onboarded teacher has no assignments yet, and §4 gives them the school's
  /// full library rather than nothing.
  Future<List<TeacherAssignmentEntity>> fetchAssignments({
    required String teacherId,
  });
}

class DioTeacherAssignmentRepository implements TeacherAssignmentRepository {
  const DioTeacherAssignmentRepository(this._dio);

  final Dio _dio;

  static const String assignmentsPath = '/teacher-assignments';

  @override
  Future<List<TeacherAssignmentEntity>> fetchAssignments({
    required String teacherId,
  }) {
    return guardApiCall(() async {
      final String id = teacherId.trim();
      if (id.isEmpty) {
        // Deliberately fails the call rather than issuing it. An unscoped
        // response would look like success and quietly show a teacher the
        // whole school's timetable (§5.5.1).
        throw const UnknownError(
          message: 'Something went wrong. Please try again.',
        );
      }

      final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
        assignmentsPath,
        queryParameters: <String, dynamic>{'teacherId': id},
      );

      return (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(TeacherAssignmentEntity.fromJson)
          .toList(growable: false);
    });
  }
}

final Provider<TeacherAssignmentRepository> teacherAssignmentRepositoryProvider =
    Provider<TeacherAssignmentRepository>(
  (Ref ref) => DioTeacherAssignmentRepository(ref.watch(dioProvider)),
);
