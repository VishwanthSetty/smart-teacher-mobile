import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/content_node_entity.dart';

void main() {
  group('ContentTreeEntity.fromJson (PRD §5.4.2)', () {
    test('parses the tree recursively, items and all', () {
      final ContentTreeEntity tree =
          ContentTreeEntity.fromJson(<String, dynamic>{
        'curriculumId': 'curriculum-1',
        'subjectName': 'Mathematics',
        'gradeLevelName': 'Grade 5',
        'nodes': <dynamic>[
          <String, dynamic>{
            'id': 'node-1',
            'title': 'Fractions',
            'videoCountDeep': 3,
            'documentCountDeep': 1,
            'videos': <dynamic>[
              <String, dynamic>{
                'id': 'video-1',
                'title': 'What is a fraction?',
                'durationSecs': 90,
              },
            ],
            'documents': <dynamic>[
              <String, dynamic>{
                'id': 'doc-1',
                'title': 'Worksheet 1',
                'fileName': 'worksheet-1.pdf',
              },
            ],
            'children': <dynamic>[
              <String, dynamic>{
                'id': 'node-1a',
                'title': 'Equivalent fractions',
                'videoCountDeep': 2,
                'videos': <dynamic>[
                  <String, dynamic>{'id': 'video-2', 'title': 'Halves'},
                ],
              },
            ],
          },
        ],
      });

      expect(tree.curriculumId, 'curriculum-1');
      expect(tree.subjectName, 'Mathematics');
      expect(tree.isEmpty, isFalse);

      final ContentNodeEntity chapter = tree.nodes.single;
      expect(chapter.title, 'Fractions');
      expect(chapter.videos.single.durationSecs, 90);
      expect(chapter.documents.single.fileName, 'worksheet-1.pdf');

      final ContentNodeEntity subTopic = chapter.children.single;
      expect(subTopic.title, 'Equivalent fractions');
      expect(subTopic.videos.single.id, 'video-2');
      // Depth is unbounded in the payload and unbounded here: chapters and
      // sub-topics are the same shape all the way down.
      expect(subTopic.children, isEmpty);
    });

    test('a node with no counts and no lists reads as empty', () {
      // An omitted zero must not fail the tree, and "missing" degrades to
      // "empty" — the same way the branch will render.
      final ContentNodeEntity node = ContentNodeEntity.fromJson(
        <String, dynamic>{'id': 'node-1', 'title': 'Chapter 1'},
      );

      expect(node.videos, isEmpty);
      expect(node.documents, isEmpty);
      expect(node.children, isEmpty);
      expect(node.videoCountDeep, 0);
      expect(node.documentCountDeep, 0);
      expect(node.isEmptyDeep, isTrue);
    });

    test('the deep counts are taken as given, not recomputed', () {
      // The whole reason the endpoint sends them (§5.4.2): a node can hold no
      // items of its own and still be full of content further down. Anything
      // that recomputed from `videos`/`documents` would grey this branch out.
      final ContentNodeEntity node = ContentNodeEntity.fromJson(
        <String, dynamic>{
          'id': 'node-1',
          'title': 'Fractions',
          'videoCountDeep': 12,
          'documentCountDeep': 4,
          'children': <dynamic>[
            <String, dynamic>{'id': 'node-1a', 'title': 'Deeper'},
          ],
        },
      );

      expect(node.videos, isEmpty);
      expect(node.documents, isEmpty);
      expect(node.itemCountDeep, 16);
      expect(node.isEmptyDeep, isFalse);
    });

    test('sub-nodes are read from either key the payload might use', () {
      // The PRD names the payload without pinning the key; guessing wrong once
      // would silently flatten every tree to its root level.
      final ContentNodeEntity node = ContentNodeEntity.fromJson(
        <String, dynamic>{
          'id': 'node-1',
          'title': 'Fractions',
          'videoCountDeep': 1,
          'nodes': <dynamic>[
            <String, dynamic>{'id': 'node-1a', 'title': 'Sub-topic'},
          ],
        },
      );

      expect(node.children.single.title, 'Sub-topic');
    });

    test('a tree with no nodes is empty, not malformed', () {
      final ContentTreeEntity tree = ContentTreeEntity.fromJson(
        <String, dynamic>{'curriculumId': 'curriculum-1'},
      );

      expect(tree.nodes, isEmpty);
      expect(tree.isEmpty, isTrue);
    });
  });

  group('display fallbacks', () {
    test('a title-less node still reads as a row', () {
      expect(
        const ContentNodeEntity(id: 'node-1').displayTitle,
        'Untitled section',
      );
      expect(
        const ContentNodeEntity(id: 'node-1', title: '  Fractions  ')
            .displayTitle,
        'Fractions',
      );
    });

    test('an untitled item falls back to its file name, then to its kind', () {
      const ContentItemEntity named = ContentItemEntity(
        id: 'doc-1',
        fileName: 'worksheet-1.pdf',
      );
      expect(named.displayTitle(ContentItemKind.document), 'worksheet-1.pdf');

      const ContentItemEntity bare = ContentItemEntity(id: 'video-1');
      expect(bare.displayTitle(ContentItemKind.video), 'Untitled video');
      expect(bare.displayTitle(ContentItemKind.document), 'Untitled document');
    });
  });
}
