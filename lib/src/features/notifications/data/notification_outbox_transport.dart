import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/local_activity.dart';
import '../../../core/sync/outbox_entry.dart';
import '../../../core/sync/outbox_worker.dart';
import 'notification_repository.dart';

/// Turns a queued notification read into the call it stands for.
///
/// The third of the feature transports, and the same seam as the other two: the
/// worker owns retry, backoff and the `4xx` discard rule; this owns which
/// endpoint a kind maps to.
///
/// It always answers `null` — a notification is not a [LocalActivity], so there
/// is nothing for the worker's cache sink to reconcile. Reading an alert about
/// a video does not change how far through it you are.
///
/// The `4xx` discard rule matters here more than anywhere: a notification whose
/// row was deleted, or which belonged to a session that has since ended, answers
/// `404`, and replaying that forever would wedge the queue behind an entry that
/// can only fail.
class NotificationOutboxTransport implements OutboxTransport {
  const NotificationOutboxTransport(this._notifications);

  final NotificationRepository _notifications;

  @override
  Future<LocalActivity?> send(OutboxEntry entry) async {
    switch (entry.kind) {
      case OutboxKind.notificationRead:
        // `resourceId` carries the notification id. The field is named for the
        // kind that dominates the queue, not for the only thing it can hold.
        if (entry.resourceId.isNotEmpty) {
          await _notifications.markRead(entry.resourceId);
        }
      case OutboxKind.videoProgress:
      case OutboxKind.documentProgress:
      case OutboxKind.documentComplete:
      case OutboxKind.documentUncomplete:
      case OutboxKind.bookmarkAdd:
      case OutboxKind.bookmarkRemove:
        throw StateError('$runtimeType cannot send ${entry.kind}');
    }
    return null;
  }
}

final Provider<OutboxTransport> notificationOutboxTransportProvider =
    Provider<OutboxTransport>(
      (Ref ref) =>
          NotificationOutboxTransport(ref.watch(notificationRepositoryProvider)),
    );
