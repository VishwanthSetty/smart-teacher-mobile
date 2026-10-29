import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/pagination/cursor_paged_state.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/history_controller.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/history_screen.dart';
import 'package:smart_teacher_mobile/src/features/activity/presentation/widgets/activity_row.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_history_repository.dart';
import '../../support/fake_progress_repository.dart';

void main() {
  group('history feed (mobile plan §5.2)', () {
    testWidgets('renders video rows on the Videos tab', (
      WidgetTester tester,
    ) async {
      await _pumpHistory(
        tester,
        history: FakeHistoryRepository(
          rows: <ResourceActivityEntity>[
            buildActivity(id: 'a', videoId: 'v1', title: 'Photosynthesis'),
            buildActivity(id: 'b', videoId: 'v2', title: 'Cell division'),
          ],
        ),
      );

      expect(find.text('Photosynthesis'), findsOneWidget);
      expect(find.text('Cell division'), findsOneWidget);
      expect(find.byType(ActivityRow), findsNWidgets(2));
    });

    testWidgets('the Documents tab asks for documents only', (
      WidgetTester tester,
    ) async {
      final FakeHistoryRepository history = FakeHistoryRepository(
        rows: <ResourceActivityEntity>[
          buildActivity(id: 'a', videoId: 'v1', title: 'Photosynthesis'),
          buildActivity(
            id: 'b',
            documentId: 'd1',
            title: 'Worksheet 3',
            lastPage: 7,
            pageCount: 24,
          ),
        ],
      );
      await _pumpHistory(tester, history: history);

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('Worksheet 3'), findsOneWidget);
      expect(find.text('page 7 of 24'), findsOneWidget);
      expect(find.text('Photosynthesis'), findsNothing);
      // The filter is a query parameter, not client-side slicing.
      expect(
        history.calls.map((HistoryCall call) => call.type),
        contains(ActivityResourceType.document),
      );
    });

    testWidgets('a status chip filter re-queries from the first page', (
      WidgetTester tester,
    ) async {
      final FakeHistoryRepository history = FakeHistoryRepository(
        rows: <ResourceActivityEntity>[
          buildActivity(id: 'a', videoId: 'v1', title: 'In flight'),
          buildActivity(
            id: 'b',
            videoId: 'v2',
            title: 'All done',
            status: ActivityProgressStatus.completed,
          ),
        ],
      );
      await _pumpHistory(tester, history: history);
      history.calls.clear();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
      await tester.pumpAndSettle();

      expect(find.text('All done'), findsOneWidget);
      expect(find.text('In flight'), findsNothing);

      final HistoryCall call = history.calls.last;
      expect(call.status, ActivityProgressStatus.completed);
      // Restarted, not appended: a filter change must not page from where the
      // previous query left off.
      expect(call.cursor, isNull);
    });

    testWidgets('the All chip sends no status at all', (
      WidgetTester tester,
    ) async {
      // An empty `?status=` is a value the server is free to read as a filter
      // matching nothing — that guess must never come from an unselected chip.
      final FakeHistoryRepository history = FakeHistoryRepository(
        rows: <ResourceActivityEntity>[buildActivity(id: 'a', videoId: 'v1')],
      );
      await _pumpHistory(tester, history: history);

      expect(history.calls.single.status, isNull);
    });

    testWidgets('pages on scroll with the last row id as the cursor', (
      WidgetTester tester,
    ) async {
      final FakeHistoryRepository history = FakeHistoryRepository(
        rows: <ResourceActivityEntity>[
          for (int index = 0; index < 45; index++)
            buildActivity(
              id: 'row-$index',
              videoId: 'v$index',
              title: 'Lesson $index',
            ),
        ],
      );
      final ProviderContainer container = await _pumpHistory(
        tester,
        history: history,
      );

      expect(_rows(container), 20);

      await tester.fling(find.byType(ListView), const Offset(0, -4000), 4000);
      await tester.pumpAndSettle();

      // A long fling can carry the list through more than one page, so the
      // assertion is that paging happened and asked for the right window —
      // not exactly how many windows one gesture covered.
      expect(_rows(container), greaterThan(20));
      expect(
        history.calls.map((HistoryCall call) => call.cursor),
        contains('row-19'),
      );
    });

    testWidgets('a failed page keeps the rows already on screen', (
      WidgetTester tester,
    ) async {
      // The classic infinite-scroll bug: a failed page 3 must not blank
      // pages 1 and 2.
      final FakeHistoryRepository history = FakeHistoryRepository(
        rows: <ResourceActivityEntity>[
          for (int index = 0; index < 45; index++)
            buildActivity(id: 'row-$index', videoId: 'v$index'),
        ],
      );
      final ProviderContainer container = await _pumpHistory(
        tester,
        history: history,
      );

      history.error = const NetworkError(message: 'Could not reach the server.');
      await container.read(historyControllerProvider(
        ActivityResourceType.video,
      ).notifier).loadMore();
      await tester.pumpAndSettle();

      expect(_rows(container), 20);
      expect(
        container
            .read(historyControllerProvider(ActivityResourceType.video))
            .value!
            .loadMoreError,
        isNotNull,
      );
    });
  });

  group('empty states (PRD §6.4)', () {
    testWidgets('nothing opened yet offers no clear-filter action', (
      WidgetTester tester,
    ) async {
      await _pumpHistory(tester, history: FakeHistoryRepository());

      expect(find.textContaining("haven't opened any videos"), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Clear filter'), findsNothing);
    });

    testWidgets('a filter that matches nothing offers a way back out', (
      WidgetTester tester,
    ) async {
      await _pumpHistory(
        tester,
        history: FakeHistoryRepository(
          rows: <ResourceActivityEntity>[
            buildActivity(id: 'a', videoId: 'v1'),
          ],
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches this filter'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Clear filter'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityRow), findsOneWidget);
    });
  });

  group('the other answers', () {
    testWidgets('a failed first page offers a retry', (
      WidgetTester tester,
    ) async {
      final FakeHistoryRepository history = FakeHistoryRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _pumpHistory(tester, history: history);

      expect(find.text('Could not reach the server.'), findsOneWidget);

      history.error = null;
      history.rows = <ResourceActivityEntity>[
        buildActivity(id: 'a', videoId: 'v1', title: 'Photosynthesis'),
      ];
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Photosynthesis'), findsOneWidget);
    });

    testWidgets('a confirmed suspension replaces the whole screen', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await _pumpHistory(
        tester,
        history: FakeHistoryRepository(
          rows: <ResourceActivityEntity>[
            buildActivity(id: 'a', videoId: 'v1'),
          ],
        ),
      );

      container.read(schoolSuspensionProvider.notifier).confirm();
      await tester.pumpAndSettle();

      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.byType(ActivityRow), findsNothing);
      // Including the tabs — there is nothing behind either of them.
      expect(find.byType(TabBar), findsNothing);
    });
  });
}

int _rows(ProviderContainer container) {
  final CursorPagedState<ResourceActivityEntity>? state = container
      .read(historyControllerProvider(ActivityResourceType.video))
      .value;
  return state?.items.length ?? 0;
}

Future<ProviderContainer> _pumpHistory(
  WidgetTester tester, {
  required FakeHistoryRepository history,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: activityOverrides(history: history),
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HistoryScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
