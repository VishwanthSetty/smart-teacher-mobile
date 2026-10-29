import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/search/data/library_search_repository.dart';
import 'package:smart_teacher_mobile/src/features/search/domain/search_query.dart';
import 'package:smart_teacher_mobile/src/features/search/domain/search_result_entity.dart';

SearchResultEntity buildSearchResult({
  String id = 'video-1',
  String title = 'Photosynthesis',
  ActivityResourceType resourceType = ActivityResourceType.video,
  String? nodeTitle = 'Chapter 1',
  int? durationSecs = 600,
  int? pageCount,
}) => SearchResultEntity(
  id: id,
  title: title,
  resourceType: resourceType,
  durationSecs: durationSecs,
  pageCount: pageCount,
  node: nodeTitle == null ? null : SearchResultNode(title: nodeTitle),
);

/// **Records every query it was called with.**
///
/// That is the whole point: a filter that quietly wasn't sent, or a request
/// fired on a keystroke the debounce was supposed to swallow, returns a
/// plausible-looking screenful either way — only the argument log catches it.
class FakeLibrarySearchRepository implements LibrarySearchRepository {
  FakeLibrarySearchRepository({List<SearchResultEntity>? results, this.error})
    : results = <SearchResultEntity>[...?results];

  List<SearchResultEntity> results;
  AppError? error;

  final List<({SearchQuery query, String? cursor})> calls =
      <({SearchQuery query, String? cursor})>[];

  int get callCount => calls.length;

  @override
  Future<List<SearchResultEntity>> search(
    SearchQuery query, {
    String? cursor,
  }) async {
    calls.add((query: query, cursor: cursor));
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
    if (cursor == null) {
      return List<SearchResultEntity>.unmodifiable(results);
    }
    // Slices after the cursor row, so an infinite-scroll test is real rather
    // than a second copy of page one.
    final int index = results.indexWhere(
      (SearchResultEntity row) => row.id == cursor,
    );
    if (index < 0) {
      return const <SearchResultEntity>[];
    }
    return List<SearchResultEntity>.unmodifiable(results.skip(index + 1));
  }
}
