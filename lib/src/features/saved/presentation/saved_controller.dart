import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_scoped_cache.dart';
import '../../../core/sync/outbox_entry.dart';
import '../../../core/sync/outbox_store.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../../activity/presentation/activity_sync_controller.dart';
import '../data/bookmark_repository.dart';
import '../domain/bookmark_entity.dart';

/// The prefix on an optimistic row's id.
///
/// A save that hasn't reached the server yet has no server id, and the grid
/// still has to draw it. Marking the id rather than adding a flag keeps the row
/// a plain [BookmarkEntity], and gives every consumer one honest question to
/// ask: `isPending` means "this exists locally only".
const String pendingBookmarkIdPrefix = 'pending:';

/// The Saved list, and **the only place the app writes a bookmark**
/// (mobile plan §5.4).
///
/// Shaped like `LibraryController` — always fetches in [build], the same
/// `refresh()`, the same suppressed automatic retry — with one addition: it
/// owns the optimistic toggle. Every write does the same three things in the
/// same order as `ActivitySyncController`, for the same reasons:
///
/// 1. mutate this list optimistically, so the star flips under the finger;
/// 2. enqueue, where an add/remove pair for one resource coalesces to the last
///    one — which is what makes a double tap one request instead of two that
///    race;
/// 3. kick off a flush it deliberately does not await.
///
/// Not auto-disposing: the toggle lives in the player and reader app bars, so
/// this list is read from screens all over the app, and re-fetching it on every
/// dismissal would be a request per navigation for an answer that rarely
/// changes. Sign-out clears it along with the rest of the actor's local data.
class SavedController extends AsyncNotifier<List<BookmarkEntity>> {
  final Random _random = Random();
  int _sequence = 0;
  bool _refreshing = false;

  @override
  Future<List<BookmarkEntity>> build() {
    invalidateOnSignOut(ref);
    return ref.read(bookmarkRepositoryProvider).fetchBookmarks();
  }

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      // The current list is left alone until the call answers, so a populated
      // grid stays on screen instead of blanking mid-gesture.
      final AsyncValue<List<BookmarkEntity>> next = await AsyncValue.guard(
        () => ref.read(bookmarkRepositoryProvider).fetchBookmarks(),
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  /// Whether [resourceId] is saved, as far as this device knows.
  ///
  /// `null` — not `false` — while the list has not loaded: "not saved" and "we
  /// haven't asked yet" are different answers, and a star drawn hollow on the
  /// second one would flip a moment later.
  bool? isSaved(String resourceId) {
    final List<BookmarkEntity>? rows = state.value;
    if (rows == null || resourceId.isEmpty) {
      return null;
    }
    return rows.any((BookmarkEntity row) => row.resourceId == resourceId);
  }

  BookmarkEntity? bookmarkFor(String resourceId) => state.value
      ?.where((BookmarkEntity row) => row.resourceId == resourceId)
      .firstOrNull;

  /// Saves or unsaves [resourceId], whichever the current state isn't.
  ///
  /// A no-op while the list is still loading: without it there is no honest
  /// "current state" to invert, and guessing would mean a tap that sometimes
  /// unsaved something the user meant to save.
  Future<void> toggle({
    required String resourceId,
    required ActivityResourceType resourceType,
    String title = '',
  }) async {
    final bool? saved = isSaved(resourceId);
    if (saved == null || resourceId.isEmpty) {
      return;
    }
    if (saved) {
      await remove(resourceId);
    } else {
      await add(
        resourceId: resourceId,
        resourceType: resourceType,
        title: title,
      );
    }
  }

  Future<void> add({
    required String resourceId,
    required ActivityResourceType resourceType,
    String title = '',
    String? collectionId,
  }) async {
    final List<BookmarkEntity>? rows = state.value;
    // A type this build doesn't recognise is refused rather than guessed: the
    // server takes `resourceType` as an enum and would reject it, and a queued
    // entry that can only 400 is one the worker would discard anyway.
    if (rows == null ||
        resourceId.isEmpty ||
        resourceType == ActivityResourceType.unknown) {
      return;
    }

    final BookmarkEntity optimistic = BookmarkEntity(
      id: '$pendingBookmarkIdPrefix${_nextId()}',
      resourceType: resourceType,
      videoId: resourceType == ActivityResourceType.video ? resourceId : null,
      documentId: resourceType == ActivityResourceType.document
          ? resourceId
          : null,
      collectionId: collectionId,
      createdAt: DateTime.now(),
      video: resourceType == ActivityResourceType.video
          ? ActivityVideoEntity(id: resourceId, title: title)
          : null,
      document: resourceType == ActivityResourceType.document
          ? ActivityDocumentEntity(id: resourceId, title: title)
          : null,
    );
    // Newest first, matching the order the endpoint returns.
    state = AsyncData<List<BookmarkEntity>>(<BookmarkEntity>[
      optimistic,
      ...rows.where((BookmarkEntity row) => row.resourceId != resourceId),
    ]);

    await _enqueue(
      OutboxEntry(
        id: _nextId(),
        target: OutboxTarget(
          kind: OutboxKind.bookmarkAdd,
          resourceId: resourceId,
        ),
        clientUpdatedAt: DateTime.now(),
        resourceKind: resourceType.wireValue,
        collectionId: collectionId,
      ),
    );
  }

  Future<void> remove(String resourceId) async {
    final List<BookmarkEntity>? rows = state.value;
    if (rows == null || resourceId.isEmpty) {
      return;
    }
    final BookmarkEntity? existing = bookmarkFor(resourceId);

    state = AsyncData<List<BookmarkEntity>>(
      rows
          .where((BookmarkEntity row) => row.resourceId != resourceId)
          .toList(growable: false),
    );

    await _enqueue(
      OutboxEntry(
        id: _nextId(),
        target: OutboxTarget(
          kind: OutboxKind.bookmarkRemove,
          resourceId: resourceId,
        ),
        clientUpdatedAt: DateTime.now(),
        resourceKind: existing?.kind.wireValue,
        // Null for a row that never synced. The queued add it coalesces onto
        // carries the same nullity, and the pair then cancels out without a
        // request — see [OutboxEntry.bookmarkId].
        bookmarkId: existing != null && !isPendingBookmark(existing)
            ? existing.id
            : null,
      ),
    );
  }

  /// Replaces the local row for [resourceId] with one filed into
  /// [collectionId], after the collection endpoint has agreed.
  ///
  /// Unlike the toggle this is *not* optimistic — the move goes through
  /// `CollectionRepository`, whose failures the teacher has to see — so this
  /// only records what already happened.
  void applyCollectionMove({
    required String bookmarkId,
    required String? collectionId,
  }) {
    final List<BookmarkEntity>? rows = state.value;
    if (rows == null) {
      return;
    }
    state = AsyncData<List<BookmarkEntity>>(
      rows
          .map(
            (BookmarkEntity row) => row.id == bookmarkId
                ? row.copyWith(collectionId: collectionId, collection: null)
                : row,
          )
          .toList(growable: false),
    );
  }

  Future<void> _enqueue(OutboxEntry entry) async {
    await ref.read(outboxStoreProvider).enqueue(entry);
    // Deliberately not awaited, exactly like a progress beat: the toggle is
    // durable the moment it is queued, and blocking the button on the round
    // trip would trade the thing that matters for the thing that doesn't.
    unawaited(ref.read(activitySyncControllerProvider).flush());
  }

  /// Monotonic within a session, random across them — the queue outlives the
  /// process, so a bare counter would collide with a previous run's ids.
  String _nextId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}-'
      '${_random.nextInt(0xFFFFFF).toRadixString(16)}';
}

/// True while a row exists only on this device.
bool isPendingBookmark(BookmarkEntity bookmark) =>
    bookmark.id.startsWith(pendingBookmarkIdPrefix);

/// A suspension-flavoured `403` is **not** confirmed on the latch from here:
/// `SuspensionInterceptor` already observes this call, and `/me/bookmarks` is
/// actor-scoped rather than entitlement-scoped, so self-reporting would turn
/// one `403` into the two-in-a-row the interceptor reads as corroboration.
final AsyncNotifierProvider<SavedController, List<BookmarkEntity>>
savedControllerProvider =
    AsyncNotifierProvider<SavedController, List<BookmarkEntity>>(
      SavedController.new,
      retry: (int retryCount, Object error) => null,
    );
