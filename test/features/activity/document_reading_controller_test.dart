import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/activity_cache_store.dart';
import 'package:smart_teacher_mobile/src/core/sync/local_activity.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/activity_sync_controller.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/document_reading_controller.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_progress_repository.dart';

/// Lets the fire-and-forget flush behind every write actually run.
Future<void> settle() async {
  for (int turn = 0; turn < 8; turn++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late InMemoryActivityCacheStore cache;
  late FakeProgressRepository progress;

  ProviderContainer build() {
    cache = InMemoryActivityCacheStore();
    progress = FakeProgressRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: activityOverrides(cache: cache, progress: progress),
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Opens the controller and **keeps it alive** for the rest of the test.
  ///
  /// The provider is auto-disposing — a reader is opened and closed, and
  /// holding every document's state for the session buys nothing. Without a
  /// standing listener it would be torn down the instant an `await` yields,
  /// and the next read would see a fresh loading state rather than the one the
  /// test just acted on.
  Future<DocumentReadingState> read(
    ProviderContainer container,
    String documentId,
  ) {
    final ProviderSubscription<AsyncValue<DocumentReadingState>> subscription =
        container.listen(
          documentReadingControllerProvider(documentId),
          (
            AsyncValue<DocumentReadingState>? previous,
            AsyncValue<DocumentReadingState> next,
          ) {},
        );
    addTearDown(subscription.close);
    return container.read(documentReadingControllerProvider(documentId).future);
  }

  group('reopening (mobile plan §4)', () {
    test('restores lastPage directly, with no chooser', () async {
      // A page is one swipe to correct; a video position is not. That
      // asymmetry is why documents get the simple treatment.
      final ProviderContainer container = build();
      await cache.write(
        LocalActivity(
          resourceId: 'doc-1',
          resourceType: 'DOCUMENT',
          status: 'IN_PROGRESS',
          lastAccessedAt: DateTime(2026, 9, 11),
          lastPage: 7,
          pageCount: 24,
        ),
      );

      final DocumentReadingState state = await read(container, 'doc-1');

      expect(state.lastPage, 7);
      expect(state.pageCount, 24);
      expect(state.isComplete, isFalse);
    });

    test('a document never opened has nothing to restore', () async {
      final ProviderContainer container = build();
      final DocumentReadingState state = await read(container, 'doc-1');

      expect(state.lastPage, isNull);
      expect(state.isComplete, isFalse);
    });

    test('reflects a completion the cache already holds', () async {
      final ProviderContainer container = build();
      await cache.write(
        LocalActivity(
          resourceId: 'doc-1',
          resourceType: 'DOCUMENT',
          status: 'COMPLETED',
          lastAccessedAt: DateTime(2026, 9, 11),
        ),
      );

      expect((await read(container, 'doc-1')).isComplete, isTrue);
    });
  });

  group('page reporting', () {
    test('the page label updates at once, the write is debounced', () async {
      // A reader whose page number lagged 1.5s behind the swipe would feel
      // broken — only the network write waits.
      final ProviderContainer container = build();
      await read(container, 'doc-1');

      container
          .read(documentReadingControllerProvider('doc-1').notifier)
          .onPageChanged(9, pageCount: 24);

      expect(
        container.read(documentReadingControllerProvider('doc-1')).value!.lastPage,
        9,
      );
      expect(progress.calls, isEmpty);
    });

    test('only the settled page is written', () async {
      final ProviderContainer container = build();
      await read(container, 'doc-1');
      final DocumentReadingController controller = container.read(
        documentReadingControllerProvider('doc-1').notifier,
      );

      // A flick through several pages.
      controller.onPageChanged(2, pageCount: 24);
      controller.onPageChanged(5, pageCount: 24);
      controller.onPageChanged(9, pageCount: 24);

      await Future<void>.delayed(
        documentPageSettleDelay + const Duration(milliseconds: 100),
      );
      await settle();

      expect(progress.calls, hasLength(1));
      expect(progress.calls.single.lastPage, 9);
      expect(progress.calls.single.kind, 'docProgress');
    });
  });

  group('mark as read', () {
    test('flips optimistically and hits the completion endpoint', () async {
      final ProviderContainer container = build();
      await read(container, 'doc-1');

      await container
          .read(documentReadingControllerProvider('doc-1').notifier)
          .setComplete(isComplete: true);
      await settle();

      expect(
        container
            .read(documentReadingControllerProvider('doc-1'))
            .value!
            .isComplete,
        isTrue,
      );
      expect(progress.calls.single.kind, 'docComplete');
    });

    test('un-marking uses the delete route', () async {
      // Students change their minds, and the teacher's report has to reflect
      // reality.
      final ProviderContainer container = build();
      await read(container, 'doc-1');
      final DocumentReadingController controller = container.read(
        documentReadingControllerProvider('doc-1').notifier,
      );

      await controller.setComplete(isComplete: true);
      await settle();
      progress.calls.clear();

      await controller.setComplete(isComplete: false);
      await settle();

      expect(
        container
            .read(documentReadingControllerProvider('doc-1'))
            .value!
            .isComplete,
        isFalse,
      );
      expect(
        progress.calls.map((ProgressCall call) => call.kind),
        contains('docUncomplete'),
      );
    });

    test('reaching the last page does not complete the document', () async {
      // The rule the reader must never imply otherwise: opening a PDF, or
      // scrolling to its end, is not reading it.
      final ProviderContainer container = build();
      await read(container, 'doc-1');

      container
          .read(documentReadingControllerProvider('doc-1').notifier)
          .onPageChanged(24, pageCount: 24);
      await Future<void>.delayed(
        documentPageSettleDelay + const Duration(milliseconds: 100),
      );
      await settle();

      expect(
        container
            .read(documentReadingControllerProvider('doc-1'))
            .value!
            .isComplete,
        isFalse,
      );
      expect(
        progress.calls.map((ProgressCall call) => call.kind),
        isNot(contains('docComplete')),
      );
      expect((await cache.read('doc-1'))!.status, 'IN_PROGRESS');
    });
  });

  group('the sync controller is the only write path', () {
    test('nothing reaches Dio without going through the outbox', () async {
      final ProviderContainer container = build();
      // Reading the controller must not itself issue a write.
      await read(container, 'doc-1');
      expect(progress.calls, isEmpty);

      await container
          .read(activitySyncControllerProvider)
          .recordDocumentPage(documentId: 'doc-1', lastPage: 3);
      await settle();

      expect(progress.calls.single.resourceId, 'doc-1');
    });
  });
}
