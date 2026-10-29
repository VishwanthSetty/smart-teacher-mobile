import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/pagination/cursor_paged_state.dart';
import '../../../core/sync/outbox_entry.dart';
import '../../../core/sync/outbox_store.dart';
import '../../activity/presentation/activity_sync_controller.dart';
import '../data/notification_repository.dart';
import '../domain/notification_entity.dart';

/// The notification inbox (mobile plan §5.10).
///
/// Cursor-paginated over [CursorPagedState], like History and Search — the
/// endpoint returns a bare array and a row id is the cursor.
///
/// **Not auto-disposing**, unlike History: the unread badge in the shell's app
/// bar reads this list, so it is watched from every screen in the app and
/// re-fetching it on each navigation would be a request per tap for an answer
/// that changes rarely.
///
/// One actor's alerts must never outlive their session (mobile plan §0), and
/// this is cleared by `sessionResetProvider` rather than by
/// [invalidateOnSignOut] — for the reason that file spells out. The shell
/// *watches* this through the badge, so invalidating at sign-out would rebuild
/// it while the shell is still mounted, against a session that has just ended:
/// a round of doomed requests, an error flash before the redirect lands, and —
/// because the badge is the first thing in the app bar to watch it — a
/// `setState() during build` when the rebuild lands mid-frame. Resetting on
/// sign-*in* has neither problem: nothing is watching it at that moment, and
/// the first screen to ask rebuilds it lazily.
///
/// Marking read is **optimistic and goes through the outbox**, shaped exactly
/// like `SavedController.toggle`: flip the row, enqueue, kick off a flush that
/// is deliberately not awaited. The tap is almost always followed immediately
/// by a navigation to the task it links to, so a write that lived only in the
/// screen's future would be lost precisely when it is most likely to be made.
class NotificationsController
    extends AsyncNotifier<CursorPagedState<NotificationEntity>> {
  final Random _random = Random();
  int _sequence = 0;
  bool _loadingMore = false;
  bool _refreshing = false;

  @override
  Future<CursorPagedState<NotificationEntity>> build() => _firstPage();

  /// Pull-to-refresh, and the error state's "Try again".
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      // The rows already on screen are left alone until the call answers, so a
      // populated inbox does not blank mid-gesture.
      final AsyncValue<CursorPagedState<NotificationEntity>> next =
          await AsyncValue.guard(_firstPage);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  /// Appends the next page. A failure lands in the footer rather than
  /// replacing the rows already held.
  Future<void> loadMore() async {
    final CursorPagedState<NotificationEntity>? current = state.value;
    if (current == null ||
        _loadingMore ||
        !current.hasMore ||
        current.cursor == null) {
      return;
    }
    _loadingMore = true;
    state = AsyncData<CursorPagedState<NotificationEntity>>(
      current.loadingMore(),
    );

    try {
      final List<NotificationEntity> page = await ref
          .read(notificationRepositoryProvider)
          .fetchNotifications(cursor: current.cursor);
      if (!ref.mounted) {
        return;
      }
      state = AsyncData<CursorPagedState<NotificationEntity>>(
        current.appendPage(
          page,
          limit: notificationPageSize,
          identity: (NotificationEntity row) => row.id,
          cursorOf: (NotificationEntity row) => row.id,
        ),
      );
    } on AppError catch (error) {
      if (ref.mounted) {
        state = AsyncData<CursorPagedState<NotificationEntity>>(
          current.failedToLoadMore(error),
        );
      }
    } finally {
      _loadingMore = false;
    }
  }

  /// Marks one row read, optimistically.
  ///
  /// A no-op on a row that is already read: the endpoint is idempotent, but a
  /// queued entry that changes nothing is still a request, and the badge would
  /// not move either way.
  Future<void> markRead(String id) async {
    final CursorPagedState<NotificationEntity>? current = state.value;
    if (current == null || id.isEmpty) {
      return;
    }
    final NotificationEntity? row = current.items
        .where((NotificationEntity item) => item.id == id)
        .firstOrNull;
    if (row == null || !row.isUnread) {
      return;
    }

    final DateTime now = DateTime.now();
    state = AsyncData<CursorPagedState<NotificationEntity>>(
      _withItems(
        current,
        current.items
            .map(
              (NotificationEntity item) =>
                  item.id == id ? item.copyWith(readAt: now) : item,
            )
            .toList(growable: false),
      ),
    );

    await ref
        .read(outboxStoreProvider)
        .enqueue(
          OutboxEntry(
            id: _nextId(),
            target: OutboxTarget(
              kind: OutboxKind.notificationRead,
              // The notification's id. `resourceId` is named for the kind that
              // dominates the queue, not for the only thing it can carry.
              resourceId: id,
            ),
            // Stamped at the tap, like every other queued write. Nothing
            // server-side resolves a notification read by this field, but the
            // rule is the outbox's rather than any one endpoint's.
            clientUpdatedAt: now,
          ),
        );
    unawaited(ref.read(activitySyncControllerProvider).flush());
  }

  /// `POST /me/notifications/read-all`.
  ///
  /// **Not** outboxed, unlike the per-row read: it is a bulk write whose count
  /// the user is shown, and one queue entry standing for an unknown number of
  /// rows could not be coalesced honestly. It awaits the server and reports a
  /// failure in place, the same trade `CollectionsController` makes.
  Future<int> markAllRead() async {
    final int updated = await ref
        .read(notificationRepositoryProvider)
        .markAllRead();

    final CursorPagedState<NotificationEntity>? current = state.value;
    if (current != null && ref.mounted) {
      final DateTime now = DateTime.now();
      state = AsyncData<CursorPagedState<NotificationEntity>>(
        _withItems(
          current,
          current.items
              .map(
                (NotificationEntity item) =>
                    item.isUnread ? item.copyWith(readAt: now) : item,
              )
              .toList(growable: false),
        ),
      );
    }
    return updated;
  }

  Future<CursorPagedState<NotificationEntity>> _firstPage() async {
    final List<NotificationEntity> page = await ref
        .read(notificationRepositoryProvider)
        .fetchNotifications();
    return CursorPagedState<NotificationEntity>.firstPage(
      page,
      limit: notificationPageSize,
      cursorOf: (NotificationEntity row) => row.id,
    );
  }

  /// Replaces the rows while preserving the paging fields.
  ///
  /// `CursorPagedState` has no `copyWith` — every other mutation it supports is
  /// a paging transition — and rebuilding it through `firstPage` would reset
  /// the cursor to the first page's last row, silently re-paging the inbox.
  CursorPagedState<NotificationEntity> _withItems(
    CursorPagedState<NotificationEntity> current,
    List<NotificationEntity> items,
  ) => CursorPagedState<NotificationEntity>(
    items: items,
    cursor: current.cursor,
    hasMore: current.hasMore,
  );

  /// Monotonic within a session, random across them — the queue outlives the
  /// process, so a bare counter would collide with a previous run's ids.
  String _nextId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}-'
      '${_random.nextInt(0xFFFFFF).toRadixString(16)}';
}

/// How many unread rows the inbox is currently holding.
///
/// Deliberately derived from the loaded list rather than from a count endpoint,
/// because there isn't one — and it is **capped at the first page**, which is
/// why the badge caps its own label rather than claiming an exact total it
/// cannot know. Answers `0` while the list is loading or failed: a badge is an
/// invitation, and one drawn from a guess would flicker.
///
/// A plain function rather than a derived `Provider`, deliberately. A
/// `Provider` watching this controller self-invalidates the moment the
/// controller rebuilds — and the badge reads it from inside the shell's app
/// bar, so a rebuild triggered by a session change lands *during* a widget
/// build and asserts with `setState() called during build`. The widget watches
/// the controller directly and calls this on the result, which has no such
/// intermediate to invalidate.
int unreadNotificationCount(
  AsyncValue<CursorPagedState<NotificationEntity>> inbox,
) {
  final CursorPagedState<NotificationEntity>? state = inbox.value;
  if (state == null) {
    return 0;
  }
  return state.items.where((NotificationEntity row) => row.isUnread).length;
}

final AsyncNotifierProvider<
  NotificationsController,
  CursorPagedState<NotificationEntity>
>
notificationsControllerProvider =
    AsyncNotifierProvider<
      NotificationsController,
      CursorPagedState<NotificationEntity>
    >(
      NotificationsController.new,
      // Matches every other controller in the app: an explicit "Try again"
      // rather than a background retry loop, which against a suspended school
      // would 403 forever.
      retry: (int retryCount, Object error) => null,
    );
