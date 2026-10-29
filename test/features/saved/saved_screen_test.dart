import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/domain/bookmark_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/domain/collection_entity.dart';
import 'package:smart_teacher_mobile/src/features/saved/presentation/saved_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_bookmark_repository.dart';
import '../../support/fake_collection_repository.dart';

void main() {
  group('the student\'s Saved list (mobile plan §5.4)', () {
    testWidgets('renders saved items and filters by type', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        bookmarks: FakeBookmarkRepository(
          bookmarks: <BookmarkEntity>[
            buildBookmark(id: 'b1', resourceId: 'video-1', title: 'A video'),
            buildBookmark(
              id: 'b2',
              resourceId: 'doc-1',
              resourceType: ActivityResourceType.document,
              title: 'A document',
            ),
          ],
        ),
      );

      expect(find.text('A video'), findsOneWidget);
      expect(find.text('A document'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Documents'));
      await tester.pumpAndSettle();

      // A view over rows already held — `/me/bookmarks` takes no parameters, so
      // the chip costs no request.
      expect(find.text('A video'), findsNothing);
      expect(find.text('A document'), findsOneWidget);
    });

    testWidgets('an empty list is an answer, not an error', (
      WidgetTester tester,
    ) async {
      await _pump(tester);

      expect(find.text('Nothing saved yet'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Clear filter'), findsNothing);
    });

    testWidgets('a filter matching nothing offers a way out', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        bookmarks: FakeBookmarkRepository(
          bookmarks: <BookmarkEntity>[buildBookmark()],
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Documents'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches this filter'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Clear filter'), findsOneWidget);
    });

    testWidgets('no collections anywhere in the student variant', (
      WidgetTester tester,
    ) async {
      // Students never create a collection; their Saved list is simply the
      // bookmarks with none (backend plan §1.2).
      final FakeCollectionRepository collections = FakeCollectionRepository();
      await _pump(
        tester,
        bookmarks: FakeBookmarkRepository(
          bookmarks: <BookmarkEntity>[buildBookmark()],
        ),
        collections: collections,
      );

      expect(find.text('Collections'), findsNothing);
      expect(find.text('Unfiled'), findsNothing);
      expect(collections.collections, isEmpty);
    });
  });

  group('the teacher\'s Collections (mobile plan §5.4)', () {
    testWidgets('shows both tabs and lists the collections', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        withCollections: true,
        collections: FakeCollectionRepository(
          collections: <CollectionEntity>[
            buildCollection(name: 'Plants — Monday Lesson'),
          ],
        ),
      );

      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('Unfiled'), findsOneWidget);
      expect(find.text('Plants — Monday Lesson'), findsOneWidget);
    });

    testWidgets('the delete dialog says items stay saved', (
      WidgetTester tester,
    ) async {
      // Deleting un-files, never unsaves (backend plan §1.2) — and the two are
      // easy to confuse, so the dialog has to say which one this is.
      await _pump(
        tester,
        withCollections: true,
        collections: FakeCollectionRepository(
          collections: <CollectionEntity>[buildCollection(name: 'Monday')],
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(
        find.text('The items in it stay saved — they just move back to Unfiled.'),
        findsOneWidget,
      );
    });

    testWidgets('the Unfiled tab holds only bookmarks with no collection', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        withCollections: true,
        bookmarks: FakeBookmarkRepository(
          bookmarks: <BookmarkEntity>[
            buildBookmark(id: 'b1', resourceId: 'v1', title: 'Loose one'),
            buildBookmark(
              id: 'b2',
              resourceId: 'v2',
              title: 'Filed one',
              collectionId: 'collection-1',
            ),
          ],
        ),
        collections: FakeCollectionRepository(
          collections: <CollectionEntity>[buildCollection()],
        ),
      );

      await tester.tap(find.text('Unfiled'));
      await tester.pumpAndSettle();

      expect(find.text('Loose one'), findsOneWidget);
      expect(find.text('Filed one'), findsNothing);
    });
  });
}

Future<void> _pump(
  WidgetTester tester, {
  FakeBookmarkRepository? bookmarks,
  FakeCollectionRepository? collections,
  bool withCollections = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: activityOverrides(
        bookmarks: bookmarks,
        collections: collections,
      ),
      child: MaterialApp(
        home: Scaffold(body: SavedView(withCollections: withCollections)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
