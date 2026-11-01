import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/widgets/brand/clay.dart';
import 'package:smart_teacher_mobile/src/core/widgets/not_found_view.dart';
import 'package:smart_teacher_mobile/src/features/library/data/content_tree_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/content_node_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/subject_island.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/subject_island_screen.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_content_tree_repository.dart';

void main() {
  group('buildIslandStops', () {
    test('marks finished chapters done and the first unfinished one next', () {
      final List<IslandStop> stops = buildIslandStops(
        <ContentNodeEntity>[
          buildNode(
            id: 'a',
            videos: <ContentItemEntity>[buildItem(id: 'v1')],
          ),
          buildNode(
            id: 'b',
            videos: <ContentItemEntity>[buildItem(id: 'v2')],
          ),
          buildNode(
            id: 'c',
            videos: <ContentItemEntity>[buildItem(id: 'v3')],
          ),
        ],
        <String, String>{'v1': 'COMPLETED', 'v2': 'IN_PROGRESS'},
      );

      expect(stops.map((IslandStop s) => s.state), <IslandStopState>[
        IslandStopState.done,
        IslandStopState.next,
        IslandStopState.ahead,
      ]);
      expect(stops.map((IslandStop s) => s.number), <int>[1, 2, 3]);
    });

    test('leaves empty chapters off the map and numbers the rest in order', () {
      final List<IslandStop> stops = buildIslandStops(<ContentNodeEntity>[
        buildNode(id: 'empty'),
        buildNode(
          id: 'full',
          documents: <ContentItemEntity>[buildItem(id: 'd1')],
        ),
      ], const <String, String>{});

      expect(stops, hasLength(1));
      expect(stops.single.node.id, 'full');
      expect(stops.single.number, 1);
    });

    test('Watch and Do it point at the first unfinished item, '
        'and replay the first once all are done', () {
      final ContentNodeEntity node = buildNode(
        videos: <ContentItemEntity>[
          buildItem(id: 'v1'),
          buildItem(id: 'v2'),
        ],
        documents: <ContentItemEntity>[buildItem(id: 'd1')],
      );

      final IslandStop partway = buildIslandStops(
        <ContentNodeEntity>[node],
        <String, String>{'v1': 'COMPLETED'},
      ).single;
      expect(partway.nextVideo?.id, 'v2');
      expect(partway.nextDocument?.id, 'd1');

      final IslandStop finished = buildIslandStops(
        <ContentNodeEntity>[node],
        <String, String>{
          'v1': 'COMPLETED',
          'v2': 'COMPLETED',
          'd1': 'COMPLETED',
        },
      ).single;
      expect(finished.isDone, isTrue);
      expect(finished.nextVideo?.id, 'v1');
    });

    test('items in sub-topics count towards their chapter', () {
      final IslandStop stop = buildIslandStops(<ContentNodeEntity>[
        buildNode(
          videoCountDeep: 1,
          children: <ContentNodeEntity>[
            buildNode(
              id: 'child',
              videos: <ContentItemEntity>[buildItem(id: 'deep')],
            ),
          ],
        ),
      ], const <String, String>{}).single;

      expect(stop.nextVideo?.id, 'deep');
      expect(stop.nextDocument, isNull);
    });

    test('an untitled chapter is named by its place on the path', () {
      final IslandStop stop = buildIslandStops(<ContentNodeEntity>[
        buildNode(title: '  ', videos: <ContentItemEntity>[buildItem()]),
      ], const <String, String>{}).single;

      expect(stop.name, 'Chapter 1');
    });
  });

  group('SubjectIslandScreen', () {
    testWidgets('draws a stop per chapter with Watch and Do it for the next', (
      WidgetTester tester,
    ) async {
      await _pumpIsland(
        tester,
        FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                id: 'shapes',
                title: 'Shapes',
                videos: <ContentItemEntity>[buildItem(id: 'v1')],
                documents: <ContentItemEntity>[buildItem(id: 'd1')],
              ),
              buildNode(
                id: 'count',
                title: 'Counting',
                videos: <ContentItemEntity>[buildItem(id: 'v2')],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Maths'), findsOneWidget);
      expect(find.text('0/2'), findsOneWidget);
      // The chapter name shows on its stop and as the sheet's heading.
      expect(find.text('Shapes'), findsNWidgets(2));
      expect(find.text('Counting'), findsOneWidget);
      expect(find.text('Watch'), findsOneWidget);
      expect(find.text('Do it'), findsOneWidget);
    });

    testWidgets('picking a chapter without documents offers only Watch', (
      WidgetTester tester,
    ) async {
      await _pumpIsland(
        tester,
        FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                id: 'shapes',
                title: 'Shapes',
                documents: <ContentItemEntity>[buildItem(id: 'd1')],
              ),
              buildNode(
                id: 'count',
                title: 'Counting',
                videos: <ContentItemEntity>[buildItem(id: 'v2')],
              ),
            ],
          ),
        ),
      );

      await tester.tap(
        find.byWidgetPredicate(
          (Widget w) => w is Clay && w.semanticLabel == 'Counting, new',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watch'), findsOneWidget);
      expect(find.text('Do it'), findsNothing);
    });

    testWidgets('a 404 is the generic not-found state, never a refusal', (
      WidgetTester tester,
    ) async {
      await _pumpIsland(
        tester,
        FakeContentTreeRepository(
          error: const NotFoundError(message: 'Not found'),
        ),
      );

      expect(find.byType(NotFoundView), findsOneWidget);
    });
  });
}

Future<void> _pumpIsland(
  WidgetTester tester,
  FakeContentTreeRepository trees,
) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const SubjectIslandScreen(curriculumId: 'maths', title: 'Maths'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        ...activityOverrides(),
        contentTreeRepositoryProvider.overrideWithValue(trees),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}
