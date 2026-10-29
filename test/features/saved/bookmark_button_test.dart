import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/domain/bookmark_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/presentation/widgets/bookmark_button.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_bookmark_repository.dart';

void main() {
  group('BookmarkButton (mobile plan §5.4)', () {
    testWidgets('renders nothing until the saved list has loaded', (
      WidgetTester tester,
    ) async {
      // "Not saved" and "we haven't asked yet" are different answers, and a
      // hollow icon that filled itself a frame later would read as the app
      // changing its mind. A fetch that never answers is how that first state
      // is held still long enough to assert on.
      await _pump(tester, bookmarks: _NeverAnswers(), settle: false);

      expect(find.byKey(const ValueKey<String>('bookmark-toggle')), findsNothing);
    });

    testWidgets('flips under the finger and the write reaches the endpoint', (
      WidgetTester tester,
    ) async {
      final FakeBookmarkRepository bookmarks = FakeBookmarkRepository();
      final InMemoryOutboxStore outbox = InMemoryOutboxStore();
      await _pump(tester, bookmarks: bookmarks, outbox: outbox);

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('bookmark-toggle')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      // The queue is empty *because* the flush the toggle kicked off drained
      // it — so the endpoint's argument log is what proves the write, and it
      // proves the right resource type went with it.
      expect(await outbox.pendingEntries(), isEmpty);
      expect(bookmarks.added.single.resourceId, 'video-1');
      expect(bookmarks.added.single.type, ActivityResourceType.video);
    });

    testWidgets('starts filled for something already saved', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        bookmarks: FakeBookmarkRepository(
          bookmarks: <BookmarkEntity>[buildBookmark(resourceId: 'video-1')],
        ),
      );

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('an unrenderable resource type draws no control at all', (
      WidgetTester tester,
    ) async {
      await _pump(tester, resourceType: ActivityResourceType.unknown);

      expect(find.byKey(const ValueKey<String>('bookmark-toggle')), findsNothing);
    });
  });
}

/// Holds the list in its loading state for as long as the test needs.
class _NeverAnswers extends FakeBookmarkRepository {
  @override
  Future<List<BookmarkEntity>> fetchBookmarks() => Completer<
    List<BookmarkEntity>
  >().future;
}

Future<void> _pump(
  WidgetTester tester, {
  FakeBookmarkRepository? bookmarks,
  InMemoryOutboxStore? outbox,
  ActivityResourceType resourceType = ActivityResourceType.video,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(bookmarks: bookmarks, outbox: outbox),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              BookmarkButton(
                resourceId: 'video-1',
                resourceType: resourceType,
                title: 'Photosynthesis',
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
