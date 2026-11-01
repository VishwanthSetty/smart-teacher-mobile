import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../notifications_controller.dart';

/// The inbox entry point with its unread badge (mobile plan §5.10).
///
/// Two looks over one behaviour: [NotificationBell.appBar] is the plain icon
/// the shell's app bar carries, and the default is the 48 px white tile the
/// Home headers draw in the design (Focus and Teach registers).
///
/// The count comes from the loaded inbox rather than from a count endpoint,
/// because there isn't one — so it is capped at the first page and reads `9+`
/// past nine rather than claiming a total it cannot know.
///
/// Watching [notificationsControllerProvider] from here is part of what keeps
/// that controller alive for the session — which is why it is not
/// auto-disposing and is cleared by `sessionResetProvider` instead.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key}) : _tile = true;

  const NotificationBell.appBar({super.key}) : _tile = false;

  final bool _tile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int unread = unreadNotificationCount(
      ref.watch(notificationsControllerProvider),
    );
    final String label = unread > 9 ? '9+' : '$unread';

    if (!_tile) {
      return IconButton(
        tooltip: 'Notifications',
        onPressed: () => context.push(AppRoutes.notifications),
        icon: Badge(
          isLabelVisible: unread > 0,
          label: Text(label),
          child: const Icon(Icons.notifications_none_outlined),
        ),
      );
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Notifications',
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.brandNavy.withValues(alpha: 0.12),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(AppRoutes.notifications),
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: Badge(
                isLabelVisible: unread > 0,
                backgroundColor: AppColors.badge,
                label: Text(label),
                child: Icon(
                  Icons.notifications_none_rounded,
                  semanticLabel: unread > 0
                      ? 'Notifications, $label unread'
                      : 'Notifications',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
