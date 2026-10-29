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
import '../../saved/presentation/widgets/bookmark_button.dart';
import '../domain/search_query.dart';
import '../domain/search_result_entity.dart';
import 'search_controller.dart';
import 'widgets/search_filter_sheet.dart';

/// Library **search** (mobile plan §5.5).
///
/// A pushed route rather than a tab: it is entered from the Library tab's
/// search field, and the tab bar has nothing to offer while you are inside a
/// result set.
///
/// [withAudience] is handed in by whatever opened this, not read from the role
/// — see [SearchFilterSheet]. It arrives through `extra`, which does not
/// survive a deep link or a process restart, so the fallback is the narrower
/// sheet: a filter that isn't there is better than one that can't work.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.withAudience = false, super.key});

  final bool withAudience;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _field = TextEditingController();

  /// The debounce timer (mobile plan §5.5: 300ms).
  ///
  /// It lives here rather than in the notifier because *this* is the only thing
  /// that produces changes faster than a request; every state change the
  /// notifier sees is meant to reach the network.
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _field.text = ref.read(searchQueryProvider).term;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      searchDebounce,
      () => ref.read(searchQueryProvider.notifier).setTerm(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final SearchQuery query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const ValueKey<String>('search-field'),
          controller: _field,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search the library',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          // Enter applies immediately rather than waiting out the debounce —
          // the user has already told us they're done typing.
          onSubmitted: (String value) {
            _debounce?.cancel();
            ref.read(searchQueryProvider.notifier).setTerm(value);
          },
        ),
        actions: <Widget>[
          if (!suspended)
            IconButton(
              key: const ValueKey<String>('search-filters'),
              tooltip: 'Filters',
              icon: Badge(
                isLabelVisible: query.hasFilters,
                label: Text('${query.filterCount}'),
                child: const Icon(Icons.tune),
              ),
              onPressed: () => unawaited(
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) =>
                      SearchFilterSheet(withAudience: widget.withAudience),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : const _SearchBody(),
      ),
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchQuery query = ref.watch(searchQueryProvider);
    final AsyncValue<CursorPagedState<SearchResultEntity>> results = ref.watch(
      librarySearchControllerProvider,
    );

    // Nothing asked for yet. Not an empty result — saying "no matches" before
    // the user has typed anything would be a claim about a search that never
    // ran.
    if (!query.isRunnable) {
      return const _SearchPrompt();
    }

    return results.when(
      data: (CursorPagedState<SearchResultEntity> state) => state.isEmpty
          ? _NoMatches(
              hasFilters: query.hasFilters,
              onClearFilters: () =>
                  ref.read(searchQueryProvider.notifier).clearFilters(),
            )
          : _ResultList(state: state),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => ErrorRetryView(
        // Search is online-only in v1 (mobile plan §5.5): a network failure
        // surfaces plainly rather than falling back to a partial local cache,
        // which would silently hide results.
        error: AppError.from(error),
        onRetry: () => unawaited(
          ref.read(librarySearchControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _ResultList extends ConsumerWidget {
  const _ResultList({required this.state});

  final CursorPagedState<SearchResultEntity> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      // Auto-loads on approach but does not re-arm after a failure — the
      // footer's own tap is what retries.
      onNotification: (ScrollNotification notification) {
        if (state.hasMore &&
            !state.hasFooter &&
            notification.metrics.extentAfter < 400) {
          unawaited(
            ref.read(librarySearchControllerProvider.notifier).loadMore(),
          );
        }
        return false;
      },
      child: ListView.separated(
        itemCount: state.items.length + (state.hasFooter ? 1 : 0),
        separatorBuilder: (BuildContext context, int _) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          if (index >= state.items.length) {
            return _LoadMoreFooter(state: state);
          }
          return _ResultRow(result: state.items[index]);
        },
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final SearchResultEntity result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.surfaceContainerHighest,
        child: Icon(
          result.isVideo
              ? Icons.play_circle_outline
              : Icons.picture_as_pdf_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        result.displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: result.nodeLabel == null
          ? null
          : Text(
              result.nodeLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
      // The save toggle is available from every list row, per §5.4 — one
      // widget, the same behaviour as in the player and reader app bars.
      trailing: BookmarkButton(
        resourceId: result.id,
        resourceType: result.kind,
        title: result.displayTitle,
        isCompact: true,
      ),
      onTap: () => context.push(
        result.isVideo
            ? AppRoutes.videoPath(result.id)
            : AppRoutes.documentPath(result.id),
        extra: result.displayTitle,
      ),
    );
  }
}

class _LoadMoreFooter extends ConsumerWidget {
  const _LoadMoreFooter({required this.state});

  final CursorPagedState<SearchResultEntity> state;

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
                  TextButton(
                    onPressed: () => unawaited(
                      ref
                          .read(librarySearchControllerProvider.notifier)
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

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.search,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Search your library',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Type a title or a topic, or narrow by subject and type from '
              'the filters.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// The search ran and matched nothing (PRD §6.4) — an answer, not a failure.
class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.hasFilters, required this.onClearFilters});

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        const SizedBox(height: AppConstants.spacingXl),
        Icon(
          Icons.search_off_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'No matches',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          hasFilters
              ? 'Nothing in your library matches this search with these '
                    'filters applied.'
              : 'Nothing in your library matches that. Try a shorter or '
                    'different word.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (hasFilters) ...<Widget>[
          const SizedBox(height: AppConstants.spacingLg),
          Center(
            child: FilledButton.tonal(
              onPressed: onClearFilters,
              child: const Text('Clear filters'),
            ),
          ),
        ],
      ],
    );
  }
}
