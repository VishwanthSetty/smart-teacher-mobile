import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/data/bookmark_repository.dart';
import 'package:smart_teacher_mobile/src/features/saved/domain/bookmark_entity.dart';

/// Builds one row of `GET /me/bookmarks`.
BookmarkEntity buildBookmark({
  String id = 'bookmark-1',
  String resourceId = 'video-1',
  ActivityResourceType resourceType = ActivityResourceType.video,
  String title = 'Photosynthesis',
  String? collectionId,
  int? durationSecs = 600,
  int? pageCount,
}) {
  final bool isVideo = resourceType == ActivityResourceType.video;
  return BookmarkEntity(
    id: id,
    resourceType: resourceType,
    videoId: isVideo ? resourceId : null,
    documentId: isVideo ? null : resourceId,
    collectionId: collectionId,
    createdAt: DateTime(2026, 9, 1),
    video: isVideo
        ? ActivityVideoEntity(
            id: resourceId,
            title: title,
            durationSecs: durationSecs,
          )
        : null,
    document: isVideo
        ? null
        : ActivityDocumentEntity(
            id: resourceId,
            title: title,
            pageCount: pageCount,
          ),
  );
}

/// **Records every write's arguments**, like the progress fake and for the same
/// reason: a bookmark toggle that quietly sent the wrong resource type — or a
/// remove that sent no id at all — returns a plausible response either way.
class FakeBookmarkRepository implements BookmarkRepository {
  FakeBookmarkRepository({List<BookmarkEntity>? bookmarks, this.error})
    : bookmarks = <BookmarkEntity>[...?bookmarks];

  List<BookmarkEntity> bookmarks;

  /// Thrown by every method when set.
  AppError? error;

  final List<
    ({String resourceId, ActivityResourceType type, String? collectionId})
  >
  added = <({String resourceId, ActivityResourceType type, String? collectionId})>[];

  final List<String> removed = <String>[];

  int fetchCount = 0;

  @override
  Future<List<BookmarkEntity>> fetchBookmarks() async {
    fetchCount++;
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
    return List<BookmarkEntity>.unmodifiable(bookmarks);
  }

  @override
  Future<BookmarkEntity> addBookmark({
    required String resourceId,
    required ActivityResourceType resourceType,
    String? collectionId,
  }) async {
    added.add((
      resourceId: resourceId,
      type: resourceType,
      collectionId: collectionId,
    ));
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
    final BookmarkEntity created = buildBookmark(
      id: 'bookmark-${bookmarks.length + 1}',
      resourceId: resourceId,
      resourceType: resourceType,
      collectionId: collectionId,
    );
    bookmarks = <BookmarkEntity>[created, ...bookmarks];
    return created;
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    removed.add(bookmarkId);
    final AppError? failure = error;
    if (failure != null) {
      throw failure;
    }
    bookmarks = bookmarks
        .where((BookmarkEntity row) => row.id != bookmarkId)
        .toList();
  }
}
