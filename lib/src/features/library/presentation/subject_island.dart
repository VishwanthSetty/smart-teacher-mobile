import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/sync/local_activity.dart';
import '../../activity/presentation/activity_sync_controller.dart';
import '../domain/content_node_entity.dart';
import 'curriculum_tree_controller.dart';

/// Where one island stop stands for this child.
enum IslandStopState {
  /// Every lesson in the chapter is completed.
  done,

  /// The first chapter that isn't done — the one the path leads to.
  next,

  /// Further along the path, not reached yet. Still tappable: the island is a
  /// guide, not a gate.
  ahead,
}

/// One stop on the subject island map (design: `KidsMap`) — a top-level
/// chapter of the curriculum tree, with the next thing to watch and to do.
@immutable
class IslandStop {
  const IslandStop({
    required this.node,
    required this.number,
    required this.state,
    required this.lessonCount,
    this.nextVideo,
    this.nextDocument,
  });

  final ContentNodeEntity node;

  /// 1-based position along the path.
  final int number;
  final IslandStopState state;

  /// Videos and documents anywhere in the chapter. From the server's deep
  /// counts, like every other count of a branch.
  final int lessonCount;

  /// The first video in the chapter not yet completed — or, once all are, the
  /// first one, so "Watch" still has something to replay. Null when the
  /// chapter has no videos at all.
  final ContentItemEntity? nextVideo;

  /// The same, for documents ("Do it").
  final ContentItemEntity? nextDocument;

  bool get isDone => state == IslandStopState.done;

  /// The chapter's title, or its place on the path when it has none — a stop
  /// with a blank label is one a child can't ask about.
  String get name {
    final String trimmed = node.title.trim();
    return trimmed.isEmpty ? 'Chapter $number' : trimmed;
  }
}

/// Turns a curriculum's chapters into island stops.
///
/// Empty chapters ([ContentNodeEntity.isEmptyDeep]) are left off the map:
/// a stop with nothing behind its Watch and Do-it buttons would be a dead end
/// for a five-year-old. [statuses] maps a resource id to its cached progress
/// status (`IN_PROGRESS`/`COMPLETED`); an absent id is not started.
///
/// Walking [ContentNodeEntity.children] here is for the *items* — which
/// specific video comes next — never to recount a branch.
List<IslandStop> buildIslandStops(
  List<ContentNodeEntity> nodes,
  Map<String, String> statuses,
) {
  final List<IslandStop> stops = <IslandStop>[];
  bool nextAssigned = false;

  for (final ContentNodeEntity node in nodes) {
    if (node.isEmptyDeep) {
      continue;
    }
    final List<ContentItemEntity> videos = <ContentItemEntity>[];
    final List<ContentItemEntity> documents = <ContentItemEntity>[];
    _collect(node, videos, documents);

    bool isComplete(ContentItemEntity item) => statuses[item.id] == _completed;

    final bool done =
        (videos.isNotEmpty || documents.isNotEmpty) &&
        videos.every(isComplete) &&
        documents.every(isComplete);

    final IslandStopState state;
    if (done) {
      state = IslandStopState.done;
    } else if (!nextAssigned) {
      state = IslandStopState.next;
      nextAssigned = true;
    } else {
      state = IslandStopState.ahead;
    }

    stops.add(
      IslandStop(
        node: node,
        number: stops.length + 1,
        state: state,
        lessonCount: node.itemCountDeep,
        nextVideo: _firstUnfinished(videos, isComplete),
        nextDocument: _firstUnfinished(documents, isComplete),
      ),
    );
  }
  return stops;
}

const String _completed = 'COMPLETED';

void _collect(
  ContentNodeEntity node,
  List<ContentItemEntity> videos,
  List<ContentItemEntity> documents,
) {
  videos.addAll(node.videos);
  documents.addAll(node.documents);
  for (final ContentNodeEntity child in node.children) {
    _collect(child, videos, documents);
  }
}

ContentItemEntity? _firstUnfinished(
  List<ContentItemEntity> items,
  bool Function(ContentItemEntity) isComplete,
) {
  if (items.isEmpty) {
    return null;
  }
  for (final ContentItemEntity item in items) {
    if (!isComplete(item)) {
      return item;
    }
  }
  return items.first;
}

/// Every video and document id in the tree.
Iterable<String> islandItemIds(List<ContentNodeEntity> nodes) sync* {
  for (final ContentNodeEntity node in nodes) {
    for (final ContentItemEntity item in node.videos) {
      yield item.id;
    }
    for (final ContentItemEntity item in node.documents) {
      yield item.id;
    }
    yield* islandItemIds(node.children);
  }
}

/// The child's progress on every item of one curriculum, read from the local
/// activity cache — the same mirror resume reads, which every successful sync
/// overwrites with the server's answer. Keyed by curriculum id; the island
/// invalidates it on returning from the player or reader.
final FutureProviderFamily<Map<String, String>, String> islandProgressProvider =
    FutureProvider.autoDispose.family<Map<String, String>, String>((
      Ref ref,
      String curriculumId,
    ) async {
      final ContentTreeEntity tree = await ref.watch(
        curriculumTreeControllerProvider(curriculumId).future,
      );
      final ActivitySyncController sync = ref.watch(
        activitySyncControllerProvider,
      );
      final Map<String, String> statuses = <String, String>{};
      for (final String id in islandItemIds(tree.nodes)) {
        final LocalActivity? activity = await sync.cachedActivity(id);
        if (activity != null) {
          statuses[id] = activity.status;
        }
      }
      return statuses;
    });
