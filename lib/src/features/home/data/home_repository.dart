import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/home_entity.dart';

/// The two home aggregates (backend plan §5.3).
///
/// Each is **role-gated to exactly one role**: `/home/student` answers only a
/// STUDENT and `/home/teacher` only a TEACHER, so calling the wrong one is a
/// `403` rather than an empty screen. That is why the two are separate methods
/// and why nothing here picks between them — the choice comes from the tab set
/// `shellTabsFor` returned, keeping that function the app's only role check.
abstract class HomeRepository {
  Future<StudentHomeEntity> fetchStudentHome();

  Future<TeacherHomeEntity> fetchTeacherHome();
}

class DioHomeRepository implements HomeRepository {
  const DioHomeRepository(this._dio);

  final Dio _dio;

  static const String studentHomePath = '/home/student';
  static const String teacherHomePath = '/home/teacher';

  @override
  Future<StudentHomeEntity> fetchStudentHome() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        studentHomePath,
      );
      // An unexpected body degrades to an empty home rather than throwing: the
      // screen owes a designed empty state either way, and a home that renders
      // nothing beats one that renders an error over a working library.
      return switch (response.data) {
        final Map<String, dynamic> json => StudentHomeEntity.fromJson(json),
        _ => const StudentHomeEntity(),
      };
    });
  }

  @override
  Future<TeacherHomeEntity> fetchTeacherHome() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        teacherHomePath,
      );
      return switch (response.data) {
        final Map<String, dynamic> json => TeacherHomeEntity.fromJson(json),
        _ => const TeacherHomeEntity(),
      };
    });
  }
}

final Provider<HomeRepository> homeRepositoryProvider =
    Provider<HomeRepository>(
      (Ref ref) => DioHomeRepository(ref.watch(dioProvider)),
    );
