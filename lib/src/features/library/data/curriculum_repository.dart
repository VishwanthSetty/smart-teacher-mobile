import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/curriculum_entity.dart';

/// `GET /curricula` (PRD §5.4.1) — the library list, for both roles.
///
/// The response is **already scoped by the server** to this actor's role and
/// their school's entitlements (§4): a student sees their enrolled grade's
/// curricula, a teacher sees their assigned grade/subject pairs (or the
/// school's full set when they have no assignments). Nothing in this feature
/// re-filters that, and nothing here looks at `MeEntity.role` — the app renders
/// exactly what comes back.
///
/// For the same reason the endpoint's optional `?audience=STUDENT|TEACHER`
/// query parameter is deliberately not plumbed through: the only thing the app
/// could sensibly derive it from is the caller's role, which would be both a
/// role branch outside `shellTabsFor` (§5.7) and a narrowing of a list the
/// server has already narrowed correctly.
///
/// Unpaginated (§6.5) — a flat array, no page/limit affordances.
abstract class CurriculumRepository {
  /// Throws an [AppError] — never a `DioException`.
  ///
  /// An empty list is a legitimate answer (§6.4), not an error: an unentitled
  /// school and a student with no active enrollment both land here.
  Future<List<CurriculumEntity>> fetchCurricula();
}

class DioCurriculumRepository implements CurriculumRepository {
  const DioCurriculumRepository(this._dio);

  final Dio _dio;

  static const String curriculaPath = '/curricula';

  @override
  Future<List<CurriculumEntity>> fetchCurricula() {
    return guardApiCall(() async {
      final Response<List<dynamic>> response =
          await _dio.get<List<dynamic>>(curriculaPath);

      return (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CurriculumEntity.fromJson)
          .toList(growable: false);
    });
  }
}

final Provider<CurriculumRepository> curriculumRepositoryProvider =
    Provider<CurriculumRepository>(
  (Ref ref) => DioCurriculumRepository(ref.watch(dioProvider)),
);
