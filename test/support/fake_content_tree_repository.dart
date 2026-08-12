import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/library/data/content_tree_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/content_node_entity.dart';

/// Scripted [ContentTreeRepository] for tests.
class FakeContentTreeRepository implements ContentTreeRepository {
  FakeContentTreeRepository({
    ContentTreeEntity? tree,
    this.error,
  }) : tree = tree ?? ContentTreeEntity(nodes: <ContentNodeEntity>[buildNode()]);

  /// Mutable so a test can change what the *next* call answers — the tree's
  /// pull-to-refresh and its "Try again" are only interesting when the second
  /// fetch differs from the first.
  ContentTreeEntity tree;

  /// When set, [fetchTree] throws this instead of returning [tree].
  AppError? error;

  int callCount = 0;

  /// Every id asked for, in order — the curriculum tree is a family provider,
  /// so "did the right curriculum get fetched?" is a real question.
  final List<String> requestedIds = <String>[];

  @override
  Future<ContentTreeEntity> fetchTree(String curriculumId) async {
    callCount++;
    requestedIds.add(curriculumId);
    if (error != null) {
      throw error!;
    }
    return tree;
  }
}

/// One node of a tree, with the deep counts defaulted to match its own content
/// so a test only has to state the interesting part.
///
/// [videoCountDeep]/[documentCountDeep] are deliberately settable
/// independently: the whole point of them is that they describe the subtree,
/// so a chapter with no items of its own can still be non-empty, and a test
/// that wants a *greyed* branch says so by passing zeroes.
ContentNodeEntity buildNode({
  String id = 'node-1',
  String title = 'Chapter 1',
  String? description,
  List<ContentNodeEntity> children = const <ContentNodeEntity>[],
  List<ContentItemEntity> videos = const <ContentItemEntity>[],
  List<ContentItemEntity> documents = const <ContentItemEntity>[],
  int? videoCountDeep,
  int? documentCountDeep,
}) {
  return ContentNodeEntity(
    id: id,
    title: title,
    description: description,
    children: children,
    videos: videos,
    documents: documents,
    videoCountDeep: videoCountDeep ?? videos.length,
    documentCountDeep: documentCountDeep ?? documents.length,
  );
}

ContentItemEntity buildItem({
  String id = 'item-1',
  String title = 'Item',
  String? description,
  int? durationSecs,
  String? fileName,
}) {
  return ContentItemEntity(
    id: id,
    title: title,
    description: description,
    durationSecs: durationSecs,
    fileName: fileName,
  );
}
