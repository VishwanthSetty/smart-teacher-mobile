import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/collection_entity.dart';

/// `/me/collections` (backend plan §5.2) — teacher-only.
///
/// Deliberately **not** routed through the outbox, unlike bookmark toggles.
/// Creating, renaming and deleting a collection are considered actions with a
/// real answer the teacher waits for: a duplicate name is a `409` they have to
/// see and resolve, and a delete un-files items, which is not something to
/// report as done before the server has agreed. The outbox exists for writes
/// the user should never wait on — a beat, a save toggle — and these are not
/// those.
abstract class CollectionRepository {
  Future<List<CollectionEntity>> fetchCollections();

  /// `POST /me/collections`. A duplicate name answers `409`, which surfaces as
  /// an [UnknownError] with the server's own message.
  Future<CollectionEntity> createCollection(String name);

  /// `PATCH /me/collections/:id` — rename only; `sortOrder` is not exposed
  /// because no screen reorders collections yet.
  Future<CollectionEntity> renameCollection({
    required String id,
    required String name,
  });

  /// `DELETE /me/collections/:id`. **Un-files its bookmarks, never unsaves
  /// them** (backend plan §1.2: `SetNull`, not `Cascade`) — the confirm dialog
  /// says so, because the two are easy to confuse and only one is recoverable.
  Future<void> deleteCollection(String id);

  /// `POST` / `DELETE /me/collections/:id/items` — moves an **existing**
  /// bookmark in or out. It never creates one: filing something unsaved is not
  /// a thing the endpoint does.
  Future<void> moveBookmark({
    required String collectionId,
    required String bookmarkId,
    required bool isAdding,
  });
}

class DioCollectionRepository implements CollectionRepository {
  const DioCollectionRepository(this._dio);

  final Dio _dio;

  static const String collectionsPath = '/me/collections';

  @override
  Future<List<CollectionEntity>> fetchCollections() {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        collectionsPath,
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        return const <CollectionEntity>[];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(CollectionEntity.fromJson)
          .toList(growable: false);
    });
  }

  @override
  Future<CollectionEntity> createCollection(String name) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        collectionsPath,
        data: <String, dynamic>{'name': name.trim()},
      );
      return _parseOne(response.data, fallbackName: name);
    });
  }

  @override
  Future<CollectionEntity> renameCollection({
    required String id,
    required String name,
  }) {
    return guardApiCall(() async {
      final Response<dynamic> response = await _dio.patch<dynamic>(
        '$collectionsPath/$id',
        data: <String, dynamic>{'name': name.trim()},
      );
      return _parseOne(response.data, fallbackId: id, fallbackName: name);
    });
  }

  @override
  Future<void> deleteCollection(String id) {
    return guardApiCall(() async {
      await _dio.delete<dynamic>('$collectionsPath/$id');
    });
  }

  @override
  Future<void> moveBookmark({
    required String collectionId,
    required String bookmarkId,
    required bool isAdding,
  }) {
    return guardApiCall(() async {
      final String path = '$collectionsPath/$collectionId/items';
      final Map<String, dynamic> body = <String, dynamic>{
        'bookmarkId': bookmarkId,
      };
      if (isAdding) {
        await _dio.post<dynamic>(path, data: body);
      } else {
        // A `DELETE` with a body, because that is the shape the controller
        // takes — `CollectionItemDto` on both halves of the pair.
        await _dio.delete<dynamic>(path, data: body);
      }
    });
  }

  CollectionEntity _parseOne(
    dynamic data, {
    String? fallbackId,
    String fallbackName = '',
  }) => switch (data) {
    final Map<String, dynamic> row => CollectionEntity.fromJson(row),
    _ => CollectionEntity(id: fallbackId ?? '', name: fallbackName.trim()),
  };
}

final Provider<CollectionRepository> collectionRepositoryProvider =
    Provider<CollectionRepository>(
      (Ref ref) => DioCollectionRepository(ref.watch(dioProvider)),
    );
