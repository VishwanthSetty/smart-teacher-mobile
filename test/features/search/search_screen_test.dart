import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/search/domain/search_query.dart';
import 'package:smart_teacher_mobile/src/features/search/domain/search_result_entity.dart';
import 'package:smart_teacher_mobile/src/features/search/presentation/search_controller.dart';
import 'package:smart_teacher_mobile/src/features/search/presentation/search_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_search_repository.dart';

void main() {
  group('search (mobile plan §5.5)', () {
    testWidgets('an untouched field runs no request at all', (
      WidgetTester tester,
    ) async {
      final FakeLibrarySearchRepository search = FakeLibrarySearchRepository();
      await _pump(tester, search);

      // `/library/search` with no q and no filters returns the first twenty
      // rows of the whole library — the Library tab's answer, not this
      // screen's, and showing it would make an empty box look like results.
      expect(search.callCount, 0);
      expect(find.text('Search your library'), findsWidgets);
    });

    testWidgets('typing is debounced into one request', (
      WidgetTester tester,
    ) async {
      final FakeLibrarySearchRepository search = FakeLibrarySearchRepository(
        results: <SearchResultEntity>[buildSearchResult()],
      );
      await _pump(tester, search);

      await tester.enterText(find.byKey(const ValueKey<String>('search-field')), 'pho');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byKey(const ValueKey<String>('search-field')), 'photo');
      await tester.pump(const Duration(milliseconds: 100));
      // Still inside the 300ms window — nothing has been sent.
      expect(search.callCount, 0);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(search.callCount, 1);
      expect(search.calls.single.query.trimmedTerm, 'photo');
      expect(find.text('Photosynthesis'), findsOneWidget);
    });

    testWidgets('a trailing space costs no extra request', (
      WidgetTester tester,
    ) async {
      final FakeLibrarySearchRepository search = FakeLibrarySearchRepository();
      final ProviderContainer container = await _pump(tester, search);

      container.read(searchQueryProvider.notifier).setTerm('photo');
      await tester.pumpAndSettle();
      container.read(searchQueryProvider.notifier).setTerm('photo ');
      await tester.pumpAndSettle();

      // `SearchQuery` compares on the trimmed term, so the second call is
      // dropped by the notifier before it ever reaches the controller.
      expect(search.callCount, 1);
    });

    testWidgets('a filter alone is enough to run a search', (
      WidgetTester tester,
    ) async {
      final FakeLibrarySearchRepository search = FakeLibrarySearchRepository();
      final ProviderContainer container = await _pump(tester, search);

      container
          .read(searchQueryProvider.notifier)
          .apply(const SearchQuery(type: ActivityResourceType.document));
      await tester.pumpAndSettle();

      expect(search.callCount, 1);
      expect(search.calls.single.query.type, ActivityResourceType.document);
      // No `q` — the filter is the whole query.
      expect(search.calls.single.query.trimmedTerm, isEmpty);
    });

    testWidgets('no matches explains itself and offers a way out', (
      WidgetTester tester,
    ) async {
      final FakeLibrarySearchRepository search = FakeLibrarySearchRepository();
      final ProviderContainer container = await _pump(tester, search);

      container
          .read(searchQueryProvider.notifier)
          .apply(
            const SearchQuery(term: 'xyz', type: ActivityResourceType.video),
          );
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
      // The "clear filters" action only appears when something is narrowing —
      // pointing at a control that changes nothing would be worse than none.
      expect(find.widgetWithText(FilledButton, 'Clear filters'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Clear filters'));
      await tester.pumpAndSettle();

      // The term survives; only the filters are dropped.
      expect(container.read(searchQueryProvider).trimmedTerm, 'xyz');
      expect(container.read(searchQueryProvider).hasFilters, isFalse);
    });

    testWidgets('a failure is surfaced rather than falling back to a cache', (
      WidgetTester tester,
    ) async {
      // Search is online-only in v1: searching a partial local cache would
      // silently hide results.
      final FakeLibrarySearchRepository search = FakeLibrarySearchRepository(
        error: const NetworkError(message: 'No connection.'),
      );
      final ProviderContainer container = await _pump(tester, search);

      container.read(searchQueryProvider.notifier).setTerm('photo');
      await tester.pumpAndSettle();

      expect(find.text('No connection.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    });

    testWidgets('the filter sheet offers no audience control by default', (
      WidgetTester tester,
    ) async {
      await _pump(tester, FakeLibrarySearchRepository());

      await tester.tap(find.byKey(const ValueKey<String>('search-filters')));
      await tester.pumpAndSettle();

      // A student's search is pinned to their own entitlement scope
      // server-side, so the control would change nothing for them — and a
      // control that does nothing is worse than none.
      expect(find.text('Audience'), findsNothing);
      expect(find.text('Type'), findsOneWidget);
    });

    testWidgets('the audience control appears when the caller asks for it', (
      WidgetTester tester,
    ) async {
      // Passed in by whatever opened the screen, never read from the role.
      await _pump(tester, FakeLibrarySearchRepository(), withAudience: true);

      await tester.tap(find.byKey(const ValueKey<String>('search-filters')));
      await tester.pumpAndSettle();

      expect(find.text('Audience'), findsOneWidget);
    });
  });
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  FakeLibrarySearchRepository search, {
  bool withAudience = false,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: activityOverrides(search: search),
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: SearchScreen(withAudience: withAudience)),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
