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
import '../domain/resource_activity_entity.dart';
import 'history_controller.dart';
import 'widgets/activity_row.dart';

/// History — **Videos** and **Documents** (mobile plan §5.2).
///
/// Reached from the home rails and from the profile menu, so it is a pushed
/// route with its own `Scaffold` rather than a shell tab.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({this.initialType, super.key});

  /// Which tab to open on. Tapping the **Recently Viewed** header on Home
  /// opens history with the matching tab already selected.
  final ActivityResourceType? initialType;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  static const List<ActivityResourceType> _tabs = <ActivityResourceType>[
    ActivityResourceType.video,
    ActivityResourceType.document,
  ];

  late final TabController _tabController = TabController(
    length: _tabs.length,
    vsync: this,
    initialIndex: switch (widget.initialType) {
      ActivityResourceType.document => 1,
      _ => 0,
    },
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool suspended = ref.watch(schoolSuspensionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: suspended
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(text: 'Videos'),
                  Tab(text: 'Documents'),
                ],
              ),
      ),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : TabBarView(
                controller: _tabController,
                children: <Widget>[
                  for (final ActivityResourceType type in _tabs)
                    _HistoryTab(type: type),
                ],
              ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.type});

  final ActivityResourceType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CursorPagedState<ResourceActivityEntity>> feed = ref.watch(
      historyControllerProvider(type),
    );

    return Column(
      children: <Widget>[
        _StatusFilterChips(type: type),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(historyControllerProvider(type).notifier).refresh(),
            child: feed.when(
              data: (CursorPagedState<ResourceActivityEntity> state) =>
                  _HistoryList(type: type, state: state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace _) => ErrorRetryView(
                error: AppError.from(error),
                onRetry: () => unawaited(
                  ref.read(historyControllerProvider(type).notifier).refresh(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusFilterChips extends ConsumerWidget {
  const _StatusFilterChips({required this.type});

  final ActivityResourceType type;

  /// `null` is *All* — and is what sends no `?status=` at all.
  static const List<(String, ActivityProgressStatus?)> _options =
      <(String, ActivityProgressStatus?)>[
        ('All', null),
        ('In progress', ActivityProgressStatus.inProgress),
        ('Completed', ActivityProgressStatus.completed),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActivityProgressStatus? selected = ref.watch(
      historyStatusFilterProvider(type),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          for (final (String label, ActivityProgressStatus? status)
              in _options) ...<Widget>[
            ChoiceChip(
              label: Text(label),
              selected: selected == status,
              // Re-tapping the selected chip is a no-op, not a toggle back to
              // All: the filter notifier drops an unchanged value, so it costs
              // no request either.
              onSelected: (bool _) => ref
                  .read(historyStatusFilterProvider(type).notifier)
                  .select(status),
            ),
            const SizedBox(width: AppConstants.spacingSm),
          ],
        ],
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.type, required this.state});

  final ActivityResourceType type;
  final CursorPagedState<ResourceActivityEntity> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isEmpty) {
      return _HistoryEmptyState(
        type: type,
        isFiltered: ref.watch(historyStatusFilterProvider(type)) != null,
        onClearFilter: () =>
            ref.read(historyStatusFilterProvider(type).notifier).select(null),
      );
    }

    return NotificationListener<ScrollNotification>(
      // Auto-loads on approach, but **does not re-arm after a failure**: the
      // footer's own tap is what retries, so a list parked at the bottom
      // against a failing server doesn't re-issue once a frame.
      onNotification: (ScrollNotification notification) {
        if (state.hasMore &&
            !state.hasFooter &&
            notification.metrics.extentAfter < 400) {
          unawaited(
            ref.read(historyControllerProvider(type).notifier).loadMore(),
          );
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length + (state.hasFooter ? 1 : 0),
        separatorBuilder: (BuildContext context, int _) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          if (index >= state.items.length) {
            return _LoadMoreFooter(type: type, state: state);
          }
          final ResourceActivityEntity activity = state.items[index];
          return ActivityRow(
            activity: activity,
            onTap: () => _open(context, activity),
          );
        },
      ),
    );
  }

  void _open(BuildContext context, ResourceActivityEntity activity) {
    final String id = activity.resourceId;
    if (id.isEmpty) {
      return;
    }
    // The title rides along as `extra` so the player or reader can caption
    // itself before its own fetch answers — a nicety, not a dependency; both
    // screens fall back to a title they derive themselves.
    context.push(
      activity.isVideo ? AppRoutes.videoPath(id) : AppRoutes.documentPath(id),
      extra: activity.title,
    );
  }
}

class _LoadMoreFooter extends ConsumerWidget {
  const _LoadMoreFooter({required this.type, required this.state});

  final ActivityResourceType type;
  final CursorPagedState<ResourceActivityEntity> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppError? error = state.loadMoreError;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  Icon(
                    ErrorRetryView.iconFor(error),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    error.displayMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  TextButton(
                    onPressed: () => unawaited(
                      ref
                          .read(historyControllerProvider(type).notifier)
                          .loadMore(),
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The designed empty state (PRD §6.4).
///
/// Splits in two for the same reason the roster's does: "nothing matches this
/// filter" needs a way back out, and "you haven't opened anything yet" needs
/// none — offering a *Clear filter* action when no filter is set would point
/// at a control that changes nothing.
class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
    required this.type,
    required this.isFiltered,
    required this.onClearFilter,
  });

  final ActivityResourceType type;
  final bool isFiltered;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isVideo = type == ActivityResourceType.video;
    final String noun = isVideo ? 'videos' : 'documents';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          isVideo ? Icons.video_library_outlined : Icons.folder_open_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          isFiltered ? 'Nothing matches this filter' : "You haven't opened any $noun yet",
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          isFiltered
              ? 'Try a different status, or clear the filter to see everything.'
              : 'Open something from your library and it will show up here.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (isFiltered) ...<Widget>[
          const SizedBox(height: AppConstants.spacingLg),
          Center(
            child: FilledButton.tonal(
              onPressed: onClearFilter,
              child: const Text('Clear filter'),
            ),
          ),
        ],
      ],
    );
  }
}
