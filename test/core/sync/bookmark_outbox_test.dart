import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_entry.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';

void main() {
  group('bookmark coalescing (mobile plan §2.2)', () {
    test('an add and a remove for one resource collapse to the remove', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(_add('video-1'));
      await store.enqueue(_remove('video-1', bookmarkId: 'bookmark-1'));

      final List<OutboxEntry> pending = await store.pendingEntries();
      // One request, not two that race — the whole point of the shared merge
      // key. A double tap on the save button costs one call.
      expect(pending, hasLength(1));
      expect(pending.single.kind, OutboxKind.bookmarkRemove);
      expect(pending.single.bookmarkId, 'bookmark-1');
    });

    test('a remove folded onto an unsent add carries no bookmark id', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(_add('video-1'));
      // No id, because the add it cancels never reached the server — so there
      // is nothing there to delete. The transport reads this as a no-op.
      await store.enqueue(_remove('video-1'));

      final List<OutboxEntry> pending = await store.pendingEntries();
      expect(pending, hasLength(1));
      expect(pending.single.kind, OutboxKind.bookmarkRemove);
      expect(pending.single.bookmarkId, isNull);
    });

    test('a re-save after a remove wins, and keeps its collection', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(_remove('doc-1', bookmarkId: 'bookmark-9'));
      await store.enqueue(
        _add(
          'doc-1',
          resourceKind: 'DOCUMENT',
          collectionId: 'collection-1',
        ),
      );

      final List<OutboxEntry> pending = await store.pendingEntries();
      expect(pending.single.kind, OutboxKind.bookmarkAdd);
      expect(pending.single.collectionId, 'collection-1');
      expect(pending.single.resourceKind, 'DOCUMENT');
    });

    test('bookmarks and progress for the same resource do not coalesce', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(_add('video-1'));
      await store.enqueue(
        OutboxEntry(
          id: 'progress',
          target: const OutboxTarget(
            kind: OutboxKind.videoProgress,
            resourceId: 'video-1',
          ),
          clientUpdatedAt: DateTime(2026, 9, 11, 10),
          positionSecs: 30,
        ),
      );

      // Saving something says nothing about how far through it you are, so
      // they key separately even though they name the same resource.
      expect(await store.pendingEntries(), hasLength(2));
    });
  });

  group('the bookmark request body', () {
    test('an add sends the resource type and id, and the collection', () {
      final Map<String, dynamic>? body = _add(
        'doc-1',
        resourceKind: 'DOCUMENT',
        collectionId: 'collection-2',
      ).toRequestBody();

      expect(body, <String, dynamic>{
        'resourceType': 'DOCUMENT',
        'resourceId': 'doc-1',
        'collectionId': 'collection-2',
      });
    });

    test('a remove carries no body at all', () {
      // A bare DELETE — sending `{}` would invite a validation pipe to have an
      // opinion about it.
      expect(_remove('video-1', bookmarkId: 'b1').toRequestBody(), isNull);
    });
  });
}

OutboxEntry _add(
  String resourceId, {
  String resourceKind = 'VIDEO',
  String? collectionId,
}) => OutboxEntry(
  id: 'add-$resourceId',
  target: OutboxTarget(
    kind: OutboxKind.bookmarkAdd,
    resourceId: resourceId,
  ),
  clientUpdatedAt: DateTime(2026, 9, 11, 10),
  resourceKind: resourceKind,
  collectionId: collectionId,
);

OutboxEntry _remove(String resourceId, {String? bookmarkId}) => OutboxEntry(
  id: 'remove-$resourceId',
  target: OutboxTarget(
    kind: OutboxKind.bookmarkRemove,
    resourceId: resourceId,
  ),
  clientUpdatedAt: DateTime(2026, 9, 11, 10, 1),
  bookmarkId: bookmarkId,
);
