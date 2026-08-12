import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/section_entity.dart';

/// `GET /sections` (PRD §5.5.3) — the supporting lookup behind the roster's
/// "filter by section" picker.
///
/// It has no screen of its own and never will: `GET /students` takes
/// `sectionId` as an **opaque filter** and returns no joined section list, so
/// this endpoint exists only to turn ids the roster would otherwise have to
/// invent into names a teacher can pick from.
///
/// Scoping: the endpoint is role-gated (`SCHOOL_ADMIN`/`TEACHER`, §8.6) and
/// answers with the caller's school — it is *not* narrowed to the sections a
/// teacher personally teaches, and this repository takes no arguments to
/// pretend otherwise. §5.5.2 suggests the roster may want to *default* its
/// filter to a section the teacher actually teaches; the ids for that come from
/// `/teacher-assignments` (§5.5.1), client-side, and are a concern of whatever
/// consumes this list — not a filter to bake in here. Unlike
/// `/teacher-assignments`, an unqualified call is the correct call, not a
/// footgun.
///
/// Unpaginated (§6.5) — a flat array, no page/limit affordances.
abstract class SectionRepository {
  /// Throws an [AppError] — never a `DioException`.
  ///
  /// An empty list is a legitimate answer (§6.4), not an error: a school that
  /// has not set up sections yet has none, which the picker renders as "no
  /// sections to filter by" rather than a failure.
  Future<List<SectionEntity>> fetchSections();
}

class DioSectionRepository implements SectionRepository {
  const DioSectionRepository(this._dio);

  final Dio _dio;

  static const String sectionsPath = '/sections';

  @override
  Future<List<SectionEntity>> fetchSections() {
    return guardApiCall(() async {
      final Response<List<dynamic>> response =
          await _dio.get<List<dynamic>>(sectionsPath);

      // Server order is kept as-is, matching `/curricula`: the app renders what
      // comes back rather than imposing an ordering the API may already mean
      // something by.
      return (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(SectionEntity.fromJson)
          .toList(growable: false);
    });
  }
}

final Provider<SectionRepository> sectionRepositoryProvider =
    Provider<SectionRepository>(
  (Ref ref) => DioSectionRepository(ref.watch(dioProvider)),
);
