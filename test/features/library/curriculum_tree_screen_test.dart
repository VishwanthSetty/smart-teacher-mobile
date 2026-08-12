import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/school_suspension_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/core/widgets/not_found_view.dart';
import 'package:smart_teacher_mobile/src/core/widgets/school_suspended_view.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/content_detail_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/content_tree_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/curriculum_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/content_node_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/curriculum_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/content_item_stub_screen.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/curriculum_tree_screen.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/library_screen.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/widgets/content_node_tile.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/widgets/curriculum_card.dart';
import 'package:smart_teacher_mobile/src/features/profile/data/profile_repository.dart';
import 'package:smart_teacher_mobile/src/features/profile/domain/me_entity.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_content_detail_repository.dart';
import '../../support/fake_content_tree_repository.dart';
import '../../support/fake_curriculum_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('opening the tree (PRD §5.4.2)', () {
    testWidgets('a library card opens the tree for that curriculum', (
      WidgetTester tester,
    ) async {
      final FakeContentTreeRepository trees = FakeContentTreeRepository();
      await _openTree(tester, trees: trees, curriculumId: 'curriculum-42');

      expect(find.byType(CurriculumTreeScreen), findsOneWidget);
      // The card handed its subject name over, so the tree titles itself
      // without waiting for its own fetch.
      expect(find.widgetWithText(AppBar, 'Mathematics'), findsOneWidget);
      expect(trees.requestedIds, <String>['curriculum-42']);
    });

    testWidgets('renders the chapters, collapsed, with their deep counts', (
      WidgetTester tester,
    ) async {
      await _openTree(
        tester,
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                videoCountDeep: 8,
                documentCountDeep: 3,
              ),
              buildNode(
                id: 'node-2',
                title: 'Decimals',
                videoCountDeep: 1,
                documentCountDeep: 1,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Fractions'), findsOneWidget);
      expect(find.text('Decimals'), findsOneWidget);
      // A drill-down, not a wall of rows: nothing is expanded on arrival.
      expect(find.text('8 videos · 3 documents'), findsOneWidget);
      expect(find.text('1 video · 1 document'), findsOneWidget);
    });

    testWidgets('a chapter expands to its items and its sub-topics', (
      WidgetTester tester,
    ) async {
      await _openTree(
        tester,
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                videos: <ContentItemEntity>[
                  buildItem(title: 'What is a fraction?', durationSecs: 90),
                ],
                documents: <ContentItemEntity>[
                  buildItem(id: 'doc-1', title: 'Worksheet 1'),
                ],
                children: <ContentNodeEntity>[
                  buildNode(
                    id: 'node-1a',
                    title: 'Equivalent fractions',
                    videos: <ContentItemEntity>[
                      buildItem(id: 'video-2', title: 'Halves and quarters'),
                    ],
                  ),
                ],
                videoCountDeep: 2,
                documentCountDeep: 1,
              ),
            ],
          ),
        ),
      );

      expect(find.text('What is a fraction?'), findsNothing);

      await tester.tap(find.text('Fractions'));
      await tester.pumpAndSettle();

      // The chapter's own content, then its sub-topics — items attached to a
      // chapter belong to the chapter, not below its children.
      expect(find.text('What is a fraction?'), findsOneWidget);
      expect(find.text('1:30'), findsOneWidget);
      expect(find.text('Worksheet 1'), findsOneWidget);
      expect(find.text('Equivalent fractions'), findsOneWidget);

      // The sub-topic is itself collapsed until asked.
      expect(find.text('Halves and quarters'), findsNothing);
      await tester.tap(find.text('Equivalent fractions'));
      await tester.pumpAndSettle();
      expect(find.text('Halves and quarters'), findsOneWidget);
    });
  });

  group('empty branches (PRD §5.4.2)', () {
    testWidgets('a branch with zero deep counts is greyed out and inert', (
      WidgetTester tester,
    ) async {
      await _openTree(
        tester,
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Not authored yet',
                // Children exist, but nothing playable or readable anywhere
                // below — which is exactly what the deep counts report.
                children: <ContentNodeEntity>[
                  buildNode(id: 'node-1a', title: 'Also empty'),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Not authored yet'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsOneWidget);

      // Not expandable: the only thing behind it is more emptiness.
      expect(find.byType(ExpansionTile), findsNothing);
      await tester.tap(find.text('Not authored yet'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Also empty'), findsNothing);
    });

    testWidgets(
      'the deep counts decide, not the node\'s own items — a chapter whose '
      'content is all in its children still opens',
      (WidgetTester tester) async {
        // The reason the endpoint sends deep counts at all (§5.4.2): this node
        // has no videos or documents of its own, so anything deciding from
        // `videos`/`documents` alone would grey out a branch full of content.
        await _openTree(
          tester,
          trees: FakeContentTreeRepository(
            tree: ContentTreeEntity(
              nodes: <ContentNodeEntity>[
                buildNode(
                  title: 'Fractions',
                  children: <ContentNodeEntity>[
                    buildNode(
                      id: 'node-1a',
                      title: 'Equivalent fractions',
                      videos: <ContentItemEntity>[
                        buildItem(id: 'video-2', title: 'Halves and quarters'),
                      ],
                    ),
                  ],
                  videoCountDeep: 1,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Nothing here yet'), findsNothing);
        expect(find.text('1 video'), findsOneWidget);

        await tester.tap(find.text('Fractions'));
        await tester.pumpAndSettle();
        expect(find.text('Equivalent fractions'), findsOneWidget);
      },
    );
  });

  group('empty curriculum (PRD §6.4)', () {
    testWidgets('a tree with no chapters is a designed state, not an error', (
      WidgetTester tester,
    ) async {
      await _openTree(
        tester,
        trees: FakeContentTreeRepository(tree: const ContentTreeEntity()),
      );

      expect(find.text('Nothing in this curriculum yet'), findsOneWidget);
      // Not a failure, and not a "not found" — the actor is entitled to this
      // curriculum; there is simply nothing in it.
      expect(find.byType(NotFoundView), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);
    });
  });

  group('not found (PRD §4)', () {
    testWidgets('a 404 renders the generic not-found state', (
      WidgetTester tester,
    ) async {
      await _openTree(
        tester,
        trees: FakeContentTreeRepository(
          error: const NotFoundError(
            message: "We couldn't find what you were looking for.",
          ),
        ),
      );

      expect(find.byType(NotFoundView), findsOneWidget);
      expect(find.text('Not found'), findsOneWidget);
      expect(find.byType(ContentNodeTile), findsNothing);
    });

    testWidgets('a 404 never implies the curriculum exists but is off-limits', (
      WidgetTester tester,
    ) async {
      // The backend answers 404 for "no such curriculum" *and* for "exists,
      // but not yours". Any refusal wording here would tell an unentitled user
      // which of the two it was.
      await _openTree(
        tester,
        trees: FakeContentTreeRepository(
          error: const NotFoundError(
            message: "We couldn't find what you were looking for.",
          ),
        ),
      );

      for (final String forbidden in <String>[
        'access',
        'allowed',
        'permission',
        'entitle',
        'suspend',
      ]) {
        expect(
          find.textContaining(forbidden, findRichText: true),
          findsNothing,
          reason: 'a 404 must not be phrased as a refusal (§4)',
        );
      }
    });

    testWidgets('a 404 offers a way back, not a retry', (
      WidgetTester tester,
    ) async {
      final FakeContentTreeRepository trees = FakeContentTreeRepository(
        error: const NotFoundError(message: 'Not found.'),
      );
      await _openTree(tester, trees: trees);

      // A 404 is a settled answer — re-asking it would read as the app being
      // broken.
      expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Back to library'));
      await tester.pumpAndSettle();

      expect(find.byType(LibraryScreen), findsOneWidget);
      expect(trees.callCount, 1);
    });
  });

  group('failures', () {
    testWidgets('a failed load offers a retry, and recovers', (
      WidgetTester tester,
    ) async {
      final FakeContentTreeRepository trees = FakeContentTreeRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _openTree(tester, trees: trees);

      expect(find.text('Could not reach the server.'), findsOneWidget);
      expect(find.byType(NotFoundView), findsNothing);

      trees.error = null;
      trees.tree = ContentTreeEntity(
        nodes: <ContentNodeEntity>[
          buildNode(title: 'Fractions', videoCountDeep: 2),
        ],
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Fractions'), findsOneWidget);
    });

    testWidgets('does not retry a failed load in the background', (
      WidgetTester tester,
    ) async {
      final FakeContentTreeRepository trees = FakeContentTreeRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _openTree(tester, trees: trees);

      await tester.pump(const Duration(minutes: 1));

      expect(trees.callCount, 1);
    });
  });

  group('content handoff (PRD §5.4.2)', () {
    testWidgets('a video row fetches its id and shows metadata-only handoff', (
      WidgetTester tester,
    ) async {
      final FakeContentDetailRepository details = FakeContentDetailRepository(
        video: buildVideo(
          id: 'video-7',
          title: 'What is a fraction?',
          description: 'A short introduction.',
          durationSecs: 125,
          contentNodeTitle: 'Fractions',
        ),
      );
      await _openTree(
        tester,
        details: details,
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                videos: <ContentItemEntity>[
                  buildItem(id: 'video-7', title: 'What is a fraction?'),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Fractions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('What is a fraction?'));
      await tester.pumpAndSettle();

      expect(find.byType(ContentItemStubScreen), findsOneWidget);
      expect(details.requestedVideoIds, <String>['video-7']);
      expect(find.text('A short introduction.'), findsOneWidget);
      expect(find.text('Fractions'), findsOneWidget);
      expect(find.text('2:05'), findsOneWidget);
      expect(find.text('Playback coming soon'), findsOneWidget);
    });

    testWidgets('a document row fetches its id and stops at the reader stub', (
      WidgetTester tester,
    ) async {
      final FakeContentDetailRepository details = FakeContentDetailRepository(
        document: buildDocument(
          id: 'doc-7',
          title: 'Worksheet 1',
          description: 'Practice questions.',
          contentNodeTitle: 'Fractions',
        ),
      );
      await _openTree(
        tester,
        details: details,
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                documents: <ContentItemEntity>[
                  buildItem(id: 'doc-7', title: 'Worksheet 1'),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Fractions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Worksheet 1'));
      await tester.pumpAndSettle();

      expect(details.requestedDocumentIds, <String>['doc-7']);
      expect(find.text('Practice questions.'), findsOneWidget);
      expect(find.text('Reader coming soon'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('a missing item uses the generic 404 state without retry', (
      WidgetTester tester,
    ) async {
      await _openTree(
        tester,
        details: FakeContentDetailRepository(
          error: const NotFoundError(
            message: "We couldn't find what you were looking for.",
          ),
        ),
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                videos: <ContentItemEntity>[
                  buildItem(id: 'missing-video', title: 'Old lesson'),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Fractions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Old lesson'));
      await tester.pumpAndSettle();

      expect(find.byType(NotFoundView), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);
    });

    testWidgets('a transient detail failure retries explicitly and recovers', (
      WidgetTester tester,
    ) async {
      final FakeContentDetailRepository details = FakeContentDetailRepository(
        error: const NetworkError(message: 'Could not reach the server.'),
      );
      await _openTree(
        tester,
        details: details,
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                videos: <ContentItemEntity>[
                  buildItem(id: 'video-1', title: 'Lesson'),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Fractions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lesson'));
      await tester.pumpAndSettle();
      expect(find.text('Could not reach the server.'), findsOneWidget);

      details.error = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(details.videoCallCount, 2);
      expect(find.text('Playback coming soon'), findsOneWidget);
    });

    testWidgets('a suspension-flavoured item 403 shows suspension screen', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await _openTree(
        tester,
        details: FakeContentDetailRepository(
          error: const ForbiddenError(
            message: "Your school's access is suspended.",
            isSchoolSuspended: true,
          ),
        ),
        trees: FakeContentTreeRepository(
          tree: ContentTreeEntity(
            nodes: <ContentNodeEntity>[
              buildNode(
                title: 'Fractions',
                documents: <ContentItemEntity>[
                  buildItem(id: 'document-1', title: 'Worksheet'),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Fractions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Worksheet'));
      await tester.pumpAndSettle();

      expect(container.read(schoolSuspensionProvider), isTrue);
      expect(find.byType(SchoolSuspendedView), findsOneWidget);
    });
  });

  group('suspended school (PRD §5.2)', () {
    testWidgets('a suspension-flavoured 403 latches on the first answer', (
      WidgetTester tester,
    ) async {
      // Sharper than the library's version of this rule: an entitlement
      // refusal on this endpoint arrives as a 404, so a 403 here cannot be the
      // narrow refusal the interceptor's two-in-a-row threshold guards against.
      final ProviderContainer container = await _openTree(
        tester,
        trees: FakeContentTreeRepository(
          error: const ForbiddenError(
            message: "Your school's access is suspended.",
            isSchoolSuspended: true,
          ),
        ),
      );

      expect(container.read(schoolSuspensionProvider), isTrue);
      expect(find.byType(SchoolSuspendedView), findsOneWidget);
      expect(find.byType(ContentNodeTile), findsNothing);
    });
  });
}

/// Boots the real app on a restored session, lands on the student shell's
/// Library tab, and taps the one card there — so every test below goes through
/// the same route wiring production does.
Future<ProviderContainer> _openTree(
  WidgetTester tester, {
  required FakeContentTreeRepository trees,
  FakeContentDetailRepository? details,
  String curriculumId = 'curriculum-1',
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage(accessToken: 'access', refreshToken: 'refresh'),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      profileRepositoryProvider.overrideWithValue(
        FakeProfileRepository(user: buildMe(role: UserRole.student)),
      ),
      curriculumRepositoryProvider.overrideWithValue(
        FakeCurriculumRepository(
          curricula: <CurriculumEntity>[
            buildCurriculum(id: curriculumId, subjectName: 'Mathematics'),
          ],
        ),
      ),
      contentTreeRepositoryProvider.overrideWithValue(trees),
      contentDetailRepositoryProvider.overrideWithValue(
        details ?? FakeContentDetailRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const SmartTeacherApp(),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(CurriculumCard), findsOneWidget);
  await tester.tap(find.byType(CurriculumCard));
  await tester.pumpAndSettle();

  return container;
}
