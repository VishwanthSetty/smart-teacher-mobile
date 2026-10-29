import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_scoped_cache.dart';
import '../data/collection_repository.dart';
import '../domain/collection_entity.dart';
import 'saved_controller.dart';

/// The teacher's collections (mobile plan §5.4).
///
/// Shaped like `SectionsController` and held for the session for the same
/// reason: the list is short, near-static, and read every time the "file this
/// into…" sheet opens.
///
/// The mutations are **not** optimistic, unlike a bookmark toggle. Each one has
/// an answer the teacher has to see — a duplicate name is a `409`, a delete
/// un-files items — so each awaits the server and then re-reads, rather than
/// reporting done and reconciling later.
class CollectionsController extends AsyncNotifier<List<CollectionEntity>> {
  bool _refreshing = false;

  @override
  Future<List<CollectionEntity>> build() {
    invalidateOnSignOut(ref);
    return ref.read(collectionRepositoryProvider).fetchCollections();
  }

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<CollectionEntity>> next = await AsyncValue.guard(
        () => ref.read(collectionRepositoryProvider).fetchCollections(),
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  /// Throws an `AppError` on failure, so the sheet can show it in place rather
  /// than replacing the whole list with an error state.
  Future<void> create(String name) async {
    await ref.read(collectionRepositoryProvider).createCollection(name);
    await refresh();
  }

  Future<void> rename({required String id, required String name}) async {
    await ref
        .read(collectionRepositoryProvider)
        .renameCollection(id: id, name: name);
    await refresh();
  }

  /// Deleting a collection **un-files** its bookmarks — it never unsaves them
  /// (backend plan §1.2). The saved list is re-read for exactly that reason:
  /// its rows are still there, now with a null `collectionId`, and a stale list
  /// would show them filed into something that no longer exists.
  Future<void> delete(String id) async {
    await ref.read(collectionRepositoryProvider).deleteCollection(id);
    await refresh();
    await ref.read(savedControllerProvider.notifier).refresh();
  }

  /// Moves an existing bookmark in or out of [collectionId].
  ///
  /// The saved list is patched locally rather than re-fetched: the move has
  /// already been confirmed by the server, and one row changing its filing is
  /// not worth a round trip that would also drop any still-pending saves.
  Future<void> moveBookmark({
    required String collectionId,
    required String bookmarkId,
    required bool isAdding,
  }) async {
    await ref
        .read(collectionRepositoryProvider)
        .moveBookmark(
          collectionId: collectionId,
          bookmarkId: bookmarkId,
          isAdding: isAdding,
        );
    ref
        .read(savedControllerProvider.notifier)
        .applyCollectionMove(
          bookmarkId: bookmarkId,
          collectionId: isAdding ? collectionId : null,
        );
    await refresh();
  }
}

final AsyncNotifierProvider<CollectionsController, List<CollectionEntity>>
collectionsControllerProvider =
    AsyncNotifierProvider<CollectionsController, List<CollectionEntity>>(
      CollectionsController.new,
      retry: (int retryCount, Object error) => null,
    );
