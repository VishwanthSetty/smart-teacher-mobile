import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/pagination/cursor_paged_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/notification_entity.dart';
import 'notification_deep_link.dart';
import 'notifications_controller.dart';

/// The notification inbox (mobile plan §5.10).
///
/// Pull to refresh, infinite scroll, **tap marks read (via the outbox) and
/// deep-links** to the task it is about. Marking read is optimistic, so the row
/// loses its unread dot under the finger and the navigation happens
/// immediately — which is the ordinary case, and precisely why the write has to
/// outlive this screen.
///
/// A notification that links nowhere — `TEACHER_DAILY_SUMMARY` is a digest, and
/// so is anything whose `data` this build cannot read — is still tappable and
/// still marks itself read. It just doesn't navigate, rather than navigating to
/// a route that would 404.
class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<CursorPagedState<NotificationEntity>> inbox = ref.watch(
      notificationsControllerProvider,
    );
    final int unread = unreadNotificationCount(inbox);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (!suspended && unread > 0)
            TextButton(
              onPressed: () => unawaited(_markAllRead(context, ref)),
              child: const Text('Mark all read'),
            ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Notification settings',
            onPressed: () => context.push(AppRoutes.notificationPreferences),
          ),
        ],
      ),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(notificationsControllerProvider.notifier).refresh(),
                child: inbox.when(
                  data: (CursorPagedState<NotificationEntity> data) =>
                      data.isEmpty
                      ? const _EmptyInbox()
                      : _InboxList(state: data),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace _) => ErrorRetryView(
                    error: AppError.from(error),
                    onRetry: () => unawaited(
                      ref
                          .read(notificationsControllerProvider.notifier)
                          .refresh(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      // Awaited and reported, unlike the per-row read: this is a bulk write
      // whose count the user is shown, and one that silently did nothing would
      // be indistinguishable from one that worked.
      final int updated = await ref
          .read(notificationsControllerProvider.notifier)
          .markAllRead();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            updated == 1 ? '1 notification marked read.' : '$updated notifications marked read.',
          ),
        ),
      );
    } on AppError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.displayMessage)));
    }
  }
}

class _InboxList extends ConsumerWidget {
  const _InboxList({required this.state});

  final CursorPagedState<NotificationEntity> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        // Auto-loads on approach, but **does not re-arm after a failure** — the
        // footer's tap is what retries, or a list parked at the bottom against a
        // failing server would re-issue once a frame. Same rule as
        // `PaginatedListView`.
        if (state.hasMore &&
            !state.isLoadingMore &&
            state.loadMoreError == null &&
            scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 320) {
          unawaited(
            ref.read(notificationsControllerProvider.notifier).loadMore(),
          );
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length + (state.hasFooter ? 1 : 0),
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          if (index >= state.items.length) {
            return _LoadMoreFooter(state: state);
          }
          return _NotificationRow(notification: state.items[index]);
        },
      ),
    );
  }
}

class _LoadMoreFooter extends ConsumerWidget {
  const _LoadMoreFooter({required this.state});

  final CursorPagedState<NotificationEntity> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppError? error = state.loadMoreError;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : TextButton.icon(
                onPressed: () => unawaited(
                  ref.read(notificationsControllerProvider.notifier).loadMore(),
                ),
                icon: Icon(ErrorRetryView.iconFor(error)),
                label: const Text('Try again'),
              ),
      ),
    );
  }
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool unread = notification.isUnread;

    return ListTile(
      tileColor: unread ? colors.primaryContainer.withValues(alpha: 0.18) : null,
      leading: CircleAvatar(
        backgroundColor: unread
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        child: Icon(
          _iconFor(notification.type),
          color: unread ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        notification.displayTitle,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (notification.body.trim().isNotEmpty) Text(notification.body),
          if (notification.createdAt case final DateTime created)
            Text(
              _relative(created),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
      isThreeLine: notification.body.trim().isNotEmpty,
      trailing: unread
          ? Icon(Icons.circle, size: 10, color: colors.primary)
          : null,
      onTap: () => unawaited(_open(context, ref)),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    // Read first, then navigate. The read is durable the moment it is queued,
    // so this does not race the route change — which is the whole reason it
    // goes through the outbox rather than living in this widget's future.
    await ref
        .read(notificationsControllerProvider.notifier)
        .markRead(notification.id);

    final String? taskId = notification.taskId;
    if (taskId == null || !context.mounted) {
      return;
    }
    // The **teacher's** task route. A student's own assignment lives at a
    // different path and a different endpoint, so which one a notification
    // opens cannot be read off the notification — it is a property of who is
    // holding the phone. Routing both through the student path would 403 a
    // teacher and vice versa, so this asks the shell's own rule rather than
    // guessing: see [notificationTaskPathProvider].
    final String path = ref.read(notificationTaskPathProvider)(taskId);
    unawaited(context.push(path, extra: notification.displayTitle));
  }
}

IconData _iconFor(NotificationKind kind) => switch (kind) {
  NotificationKind.taskAssigned => Icons.assignment_outlined,
  NotificationKind.taskReminder => Icons.notifications_active_outlined,
  NotificationKind.taskDueSoon => Icons.schedule_outlined,
  NotificationKind.teacherDailySummary => Icons.summarize_outlined,
  NotificationKind.unknown => Icons.notifications_none_outlined,
};

/// `'2h ago'`. Coarse on purpose — an inbox is scanned, not audited, and the
/// exact minute of a reminder is never the question being asked.
String _relative(DateTime created) {
  final Duration age = DateTime.now().difference(created.toLocal());
  if (age.inMinutes < 1) {
    return 'Just now';
  }
  if (age.inHours < 1) {
    return '${age.inMinutes}m ago';
  }
  if (age.inDays < 1) {
    return '${age.inHours}h ago';
  }
  if (age.inDays < 7) {
    return '${age.inDays}d ago';
  }
  final DateTime local = created.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}

/// The empty inbox — a legitimate state, not an error (§6.4).
class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.notifications_none_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'Nothing here yet',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Task assignments, reminders and due-date alerts will appear here.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
