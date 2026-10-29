import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/local_activity.dart';
import '../../../core/sync/outbox_entry.dart';
import '../../../core/sync/outbox_worker.dart';
import '../../activity/domain/resource_activity_entity.dart';
import 'bookmark_repository.dart';

/// Turns a queued bookmark toggle into the call it stands for.
///
/// The mirror of `ProgressOutboxTransport`, and the same seam: the worker owns
/// retry, backoff and the `4xx` discard rule; this owns which endpoint a kind
/// maps to.
///
/// It always answers `null` — a bookmark is not a [LocalActivity], so there is
/// nothing for the worker's cache sink to reconcile. Saving something does not
/// change how far through it you are.
class BookmarkOutboxTransport implements OutboxTransport {
  const BookmarkOutboxTransport(this._bookmarks);

  final BookmarkRepository _bookmarks;

  @override
  Future<LocalActivity?> send(OutboxEntry entry) async {
    switch (entry.kind) {
      case OutboxKind.bookmarkAdd:
        await _bookmarks.addBookmark(
          resourceId: entry.resourceId,
          resourceType: _typeFrom(entry.resourceKind),
          collectionId: entry.collectionId,
        );
      case OutboxKind.bookmarkRemove:
        final String? id = entry.bookmarkId;
        // No id means this remove cancelled an add that never reached the
        // server, so there is nothing there to delete. Answering success drops
        // the entry rather than retrying a call that could only 404.
        if (id != null && id.isNotEmpty) {
          await _bookmarks.removeBookmark(id);
        }
      case OutboxKind.videoProgress:
      case OutboxKind.documentProgress:
      case OutboxKind.documentComplete:
      case OutboxKind.documentUncomplete:
      case OutboxKind.notificationRead:
        throw StateError('$runtimeType cannot send ${entry.kind}');
    }
    return null;
  }
}

/// A queued row carries the type as the raw wire string, since `core/` does not
/// own the enum. `VIDEO` is the fallback for an unreadable one; the worker's
/// `4xx` discard clears the entry if the server disagrees.
ActivityResourceType _typeFrom(String? raw) => switch (raw) {
  'DOCUMENT' => ActivityResourceType.document,
  _ => ActivityResourceType.video,
};

final Provider<OutboxTransport> bookmarkOutboxTransportProvider =
    Provider<OutboxTransport>(
      (Ref ref) => BookmarkOutboxTransport(ref.watch(bookmarkRepositoryProvider)),
    );
