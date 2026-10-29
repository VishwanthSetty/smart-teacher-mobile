import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../library/domain/curriculum_entity.dart';
import '../domain/search_query.dart';
import '../domain/search_result_entity.dart';

/// The server's page size for `/library/search`. It is not a parameter — the
/// service hard-codes `take: 20` per type and slices the merged list to 20 —
/// so this is a fact to match, not a number to send.
const int searchPageLimit = 20;

/// `GET /library/search` (backend plan §5.3).
///
/// Results are scoped to the actor's resolved curricula **before** the text
/// query is applied, so an unreachable title never appears even as a name
/// (§4.1). This repository adds no filtering and no re-ranking of its own.
///
/// Search is **online-only in v1** (mobile plan §5.5). There is deliberately no
/// cache fallback here: searching a partial local cache would silently hide
/// results, and a user who cannot tell "no matches" from "we only looked at
/// what's on this phone" is worse off than one shown an offline state.
abstract class LibrarySearchRepository {
  /// Every blank filter is **omitted rather than sent empty**, matching the
  /// roster and history reads: `?subjectId=` is a value the server is free to
  /// read as a filter matching nothing.
  Future<List<SearchResultEntity>> search(SearchQuery query, {String? cursor});
}

class DioLibrarySearchRepository implements LibrarySearchRepository {
  const DioLibrarySearchRepository(this._dio);

  final Dio _dio;

  static const String searchPath = '/library/search';

  @override
  Future<List<SearchResultEntity>> search(
    SearchQuery query, {
    String? cursor,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        searchPath,
        queryParameters: <String, dynamic>{
          if (query.trimmedTerm.isNotEmpty) 'q': query.trimmedTerm,
          if (query.subjectId case final String id) 'subjectId': id,
          if (query.gradeLevelId case final String id) 'gradeLevelId': id,
          if (query.contentNodeId case final String id) 'contentNodeId': id,
          if (query.type?.wireValue case final String value) 'type': value,
          if (query.audience case final CurriculumAudience audience)
            if (audienceWireValue(audience) case final String value)
              'audience': value,
          if (query.progress?.wireValue case final String value)
            'progress': value,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );

      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <SearchResultEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(SearchResultEntity.fromJson)
          .toList(growable: false);
    });
  }
}

final Provider<LibrarySearchRepository> librarySearchRepositoryProvider =
    Provider<LibrarySearchRepository>(
      (Ref ref) => DioLibrarySearchRepository(ref.watch(dioProvider)),
    );
