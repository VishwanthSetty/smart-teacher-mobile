import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/composite_outbox_transport.dart';
import '../../../core/sync/local_activity.dart';
import '../../../core/sync/outbox_entry.dart';
import '../../../core/sync/outbox_worker.dart';
import '../../notifications/data/notification_outbox_transport.dart';
import '../../saved/data/bookmark_outbox_transport.dart';
import '../domain/resource_activity_entity.dart';
import 'progress_repository.dart';

/// Turns a queued [OutboxEntry] into the call it stands for.
///
/// This is the seam that keeps `core/sync` free of feature imports: the worker
/// knows about retry, backoff and discard; this knows which endpoint each kind
/// maps to. Neither knows the other's business.
class ProgressOutboxTransport implements OutboxTransport {
  const ProgressOutboxTransport(this._progress);

  final ProgressRepository _progress;

  @override
  Future<LocalActivity?> send(OutboxEntry entry) async {
    // Exhaustive over OutboxKind, with no `default`: a kind added for a later
    // phase (notification reads) is an analyzer error here until it has been
    // routed somewhere, rather than a queued write that silently never sends.
    // The bookmark kinds are routed to `BookmarkOutboxTransport` by the
    // composite below, so reaching them here is a wiring bug, not a payload.
    final Future<LocalActivity> result = switch (entry.kind) {
      OutboxKind.videoProgress => _sendVideoProgress(entry),
      OutboxKind.documentProgress => _sendDocumentProgress(entry),
      OutboxKind.documentComplete => _progress
          .markDocumentComplete(entry.resourceId)
          .then((ResourceActivityEntity activity) => activity.toLocalActivity()),
      OutboxKind.documentUncomplete => _progress
          .unmarkDocumentComplete(entry.resourceId)
          .then((ResourceActivityEntity activity) => activity.toLocalActivity()),
      OutboxKind.bookmarkAdd ||
      OutboxKind.bookmarkRemove ||
      OutboxKind.notificationRead =>
        throw StateError('$runtimeType cannot send ${entry.kind}'),
    };
    return result;
  }

  Future<LocalActivity> _sendVideoProgress(OutboxEntry entry) async {
    final ResourceActivityEntity activity = await _progress.updateVideoProgress(
      videoId: entry.resourceId,
      positionSecs: entry.positionSecs ?? 0,
      intervals: entry.intervals,
      clientUpdatedAt: entry.clientUpdatedAt,
    );
    return activity.toLocalActivity();
  }

  Future<LocalActivity> _sendDocumentProgress(OutboxEntry entry) async {
    final ResourceActivityEntity activity = await _progress.updateDocumentProgress(
      documentId: entry.resourceId,
      lastPage: entry.lastPage ?? 1,
      pageCount: entry.pageCount,
      clientUpdatedAt: entry.clientUpdatedAt,
    );
    return activity.toLocalActivity();
  }
}

/// The one transport the worker talks to, dispatching per kind.
///
/// Assembled here rather than in `core/` because the routing table is the only
/// place that has to know both halves, and `core/sync` may not import a
/// feature. Every [OutboxKind] must appear: an unrouted kind throws inside
/// [CompositeOutboxTransport] rather than queueing forever unsent.
final Provider<OutboxTransport> outboxTransportProvider =
    Provider<OutboxTransport>((Ref ref) {
      final OutboxTransport progress = ProgressOutboxTransport(
        ref.watch(progressRepositoryProvider),
      );
      final OutboxTransport bookmarks = ref.watch(
        bookmarkOutboxTransportProvider,
      );
      final OutboxTransport notifications = ref.watch(
        notificationOutboxTransportProvider,
      );

      return CompositeOutboxTransport(<OutboxKind, OutboxTransport>{
        OutboxKind.videoProgress: progress,
        OutboxKind.documentProgress: progress,
        OutboxKind.documentComplete: progress,
        OutboxKind.documentUncomplete: progress,
        OutboxKind.bookmarkAdd: bookmarks,
        OutboxKind.bookmarkRemove: bookmarks,
        OutboxKind.notificationRead: notifications,
      });
    });
