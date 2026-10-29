import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../domain/bookmark_entity.dart';

/// `/me/bookmarks` (backend plan §5.2).
///
/// The list is **already scoped server-side** to the actor's reachable
/// curricula — a save whose entitlement lapses simply stops coming back — so
/// this repository adds no filtering of its own, exactly like the library and
/// history reads.
///
/// The two writes are reached through the **outbox**, never called from
/// presentation directly (mobile plan §5.4: "Bookmark toggles are optimistic
/// and go through the outbox"). They are `public` here only because
/// `BookmarkOutboxTransport` is what calls them.
abstract class BookmarkRepository {
  /// `GET /me/bookmarks` — a flat array, newest first.
  Future<List<BookmarkEntity>> fetchBookmarks();

  /// `POST /me/bookmarks`. Idempotent server-side: the `@@unique(userId,
  /// resourceId)` pair makes a re-save an upsert, which is what makes an
  /// offline replay safe (backend plan §7).
  Future<BookmarkEntity> addBookmark({
    required String resourceId,
    required ActivityResourceType resourceType,
    String? collectionId,
  });

  /// `DELETE /me/bookmarks/:id` — the **bookmark's** id, not the resource's.
  Future<void> removeBookmark(String bookmarkId);
}

class DioBookmarkRepository implements BookmarkRepository {
  const DioBookmarkRepository(this._dio);

  final Dio _dio;

  static const String bookmarksPath = '/me/bookmarks';

  @override
  Future<List<BookmarkEntity>> fetchBookmarks() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(bookmarksPath);
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <BookmarkEntity>[];
      }
      // One malformed row must not fail the grid, for the same reason it must
      // not fail a page of history.
      return data
          .whereType<Map<String, dynamic>>()
          .map(BookmarkEntity.fromJson)
          .toList(growable: false);
    });
  }

  @override
  Future<BookmarkEntity> addBookmark({
    required String resourceId,
    required ActivityResourceType resourceType,
    String? collectionId,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        bookmarksPath,
        data: <String, dynamic>{
          // Never [ActivityResourceType.unknown]'s null: a save whose type this
          // build didn't recognise is a request the server would reject, and
          // the caller has already refused to enqueue one.
          'resourceType': resourceType.wireValue ?? 'VIDEO',
          'resourceId': resourceId,
          if (collectionId != null && collectionId.trim().isNotEmpty)
            'collectionId': collectionId,
        },
      );
      return switch (response.data) {
        final Map<String, dynamic> row => BookmarkEntity.fromJson(row),
        _ => BookmarkEntity(id: '', videoId: resourceId),
      };
    });
  }

  @override
  Future<void> removeBookmark(String bookmarkId) {
    return guardApiCall(() async {
      await _dio.delete<dynamic>('$bookmarksPath/$bookmarkId');
    });
  }
}

final Provider<BookmarkRepository> bookmarkRepositoryProvider =
    Provider<BookmarkRepository>(
      (Ref ref) => DioBookmarkRepository(ref.watch(dioProvider)),
    );
