import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/student_entity.dart';

/// `GET /students?page=&limit=&search=&sectionId=&status=` (PRD §5.5.2) — the
/// roster, and **the only paginated endpoint in the API** (§6.5).
///
/// Scoping: role-gated to `SCHOOL_ADMIN`/`TEACHER` (§8.6) and answered for the
/// caller's school. Unlike `/teacher-assignments`, an unqualified call is the
/// correct call — a teacher may legitimately look up any student in their
/// school, and §5.5.2's suggestion to *default* the section filter to one they
/// teach is a client-side convenience, not a scope this repository enforces.
///
/// Every filter is optional and every blank one is **omitted rather than sent
/// empty**: `?sectionId=` is a parameter the server is free to read as "no
/// filter", and `?search=` as a match-nothing term. Neither guess should be
/// made from an empty text field.
///
/// Read-only, permanently. `PATCH /students/:id` and the password routes are
/// SCHOOL_ADMIN-only and explicitly out of mobile scope (§5.5.2, §8.6), so
/// there is no write method here to reach for.
abstract class StudentRepository {
  /// Throws an [AppError] — never a `DioException`.
  ///
  /// An empty page is a legitimate answer (§6.4): a school with no students
  /// yet, and a search that matches nobody, both land there and are the
  /// screen's business to tell apart.
  Future<PaginatedResult<StudentEntity>> fetchStudents({
    int page,
    int limit,
    String? search,
    String? sectionId,
    StudentStatus? status,
  });
}

class DioStudentRepository implements StudentRepository {
  const DioStudentRepository(this._dio);

  final Dio _dio;

  static const String studentsPath = '/students';

  @override
  Future<PaginatedResult<StudentEntity>> fetchStudents({
    int page = PaginationConstants.firstPage,
    int limit = PaginationConstants.defaultLimit,
    String? search,
    String? sectionId,
    StudentStatus? status,
  }) {
    return guardApiCall(() async {
      // Clamped here rather than trusted from the call site: `limit` above the
      // server's ceiling of 100 is not a bigger page, it is an argument the
      // server may reject outright (§5.5.2).
      final int resolvedPage = PaginationConstants.resolvePage(page);
      final int resolvedLimit = PaginationConstants.resolveLimit(limit);

      final Response<dynamic> response = await _dio.get<dynamic>(
        studentsPath,
        queryParameters: <String, dynamic>{
          'page': resolvedPage,
          'limit': resolvedLimit,
          if (_trimToNull(search) case final String term) 'search': term,
          if (_trimToNull(sectionId) case final String id) 'sectionId': id,
          if (status?.wireValue case final String value) 'status': value,
        },
      );

      return PaginatedResult<StudentEntity>.fromJson(
        response.data,
        StudentEntity.fromJson,
        page: resolvedPage,
        limit: resolvedLimit,
      );
    });
  }
}

final Provider<StudentRepository> studentRepositoryProvider =
    Provider<StudentRepository>(
  (Ref ref) => DioStudentRepository(ref.watch(dioProvider)),
);

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
