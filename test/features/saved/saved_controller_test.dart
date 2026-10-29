import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_entry.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/domain/bookmark_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/presentation/saved_controller.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_bookmark_repository.dart';

void main() {
  group('SavedController (mobile plan §5.4)', () {
    test('a toggle is optimistic and reaches the outbox, not Dio', () async {
      final FakeBookmarkRepository bookmarks = FakeBookmarkRepository();
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      final ProviderContainer container = _container(
        bookmarks: bookmarks,
        outbox: outbox,
      );

      await container.read(savedControllerProvider.future);
      await container
          .read(savedControllerProvider.notifier)
          .toggle(
            resourceId: 'video-1',
            resourceType: ActivityResourceType.video,
            title: 'Photosynthesis',
          );

      // The row is on screen immediately, before anything has been sent.
      expect(container.read(savedControllerProvider).value, hasLength(1));
      expect(
        container.read(savedControllerProvider.notifier).isSaved('video-1'),
        isTrue,
      );

      final List<OutboxEntry> pending = await outbox.pendingEntries();
      expect(pending.single.kind, OutboxKind.bookmarkAdd);
      expect(pending.single.resourceKind, 'VIDEO');
    });

    test('a second toggle removes it, and the pair coalesces to one entry', () async {
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      final ProviderContainer container = _container(outbox: outbox);

      await container.read(savedControllerProvider.future);
      final SavedController controller = container.read(
        savedControllerProvider.notifier,
      );
      await controller.toggle(
        resourceId: 'video-1',
        resourceType: ActivityResourceType.video,
      );
      await controller.toggle(
        resourceId: 'video-1',
        resourceType: ActivityResourceType.video,
      );

      expect(container.read(savedControllerProvider).value, isEmpty);
      final List<OutboxEntry> pending = await outbox.pendingEntries();
      expect(pending, hasLength(1));
      expect(pending.single.kind, OutboxKind.bookmarkRemove);
    });

    test('removing a synced row carries its server id', () async {
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      final ProviderContainer container = _container(
        bookmarks: FakeBookmarkRepository(
          bookmarks: <BookmarkEntity>[
            buildBookmark(id: 'bookmark-7', resourceId: 'video-1'),
          ],
        ),
        outbox: outbox,
      );

      await container.read(savedControllerProvider.future);
      await container.read(savedControllerProvider.notifier).remove('video-1');

      final List<OutboxEntry> pending = await outbox.pendingEntries();
      // `DELETE /me/bookmarks/:id` takes the bookmark's own id, not the
      // resource's — sending the wrong one would 404 forever.
      expect(pending.single.bookmarkId, 'bookmark-7');
    });

    test('a toggle before the list has loaded is a no-op', () async {
      // "Not saved" and "we haven't asked yet" are different answers, and
      // inverting the second one would sometimes unsave what the user meant to
      // save.
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      final ProviderContainer container = _container(outbox: outbox);

      await container
          .read(savedControllerProvider.notifier)
          .toggle(
            resourceId: 'video-1',
            resourceType: ActivityResourceType.video,
          );

      expect(await outbox.pendingEntries(), isEmpty);
    });

    test('an unrecognised resource type is refused rather than guessed', () async {
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      final ProviderContainer container = _container(outbox: outbox);

      await container.read(savedControllerProvider.future);
      await container
          .read(savedControllerProvider.notifier)
          .add(
            resourceId: 'thing-1',
            resourceType: ActivityResourceType.unknown,
          );

      // The server takes `resourceType` as an enum; a queued entry that can
      // only 400 is one the worker would discard anyway.
      expect(await outbox.pendingEntries(), isEmpty);
    });

    test('isSaved answers null until the list has loaded', () async {
      final ProviderContainer container = _container();

      expect(
        container.read(savedControllerProvider.notifier).isSaved('video-1'),
        isNull,
      );

      await container.read(savedControllerProvider.future);
      expect(
        container.read(savedControllerProvider.notifier).isSaved('video-1'),
        isFalse,
      );
    });
  });
}

ProviderContainer _container({
  FakeBookmarkRepository? bookmarks,
  InMemoryOutboxStore? outbox,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: activityOverrides(
      outbox: outbox,
      bookmarks: bookmarks ?? FakeBookmarkRepository(),
    ),
  );
  addTearDown(container.dispose);
  // A standing listener: the controller is torn down the instant an `await`
  // yields with nothing watching it.
  container.listen(savedControllerProvider, (_, _) {});
  return container;
}
