import 'package:flutter/material.dart';
// For `AsyncValue` and its `when`. This widget watches nothing itself — the
// state is handed in by whatever screen owns the controller.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../errors/app_error.dart';
import '../pagination/paged_list_state.dart';
import 'error_retry_view.dart';

/// **The** paginated list of PRD §6.5 — one widget, for the one paginated
/// endpoint in the API.
///
/// `GET /students` (§5.5.2) is the only call that pages today, and the PRD is
/// explicit that no other list endpoint gets pagination affordances: `/`
/// `curricula`, `/videos`, `/documents`, `/teacher-assignments` and `/sections`
/// all return flat arrays and are rendered with a plain `ListView`. This widget
/// is nonetheless generic and feature-agnostic — it lives in `core/` and knows
/// nothing about students — so the second paginated endpoint is a call site,
/// not a second implementation.
///
/// It renders the four states a paged list actually has, and keeps the last two
/// away from the first two:
///
/// | state | rendering |
/// |---|---|
/// | first page loading | a centred spinner in place of the list |
/// | first page failed | [ErrorRetryView] |
/// | loaded, no rows | [emptyBuilder] — the caller's designed empty state (§6.4) |
/// | loaded | the rows, plus a footer while a later page loads or fails |
///
/// A later page never disturbs the rows already on screen. See [PagedListState]
/// for why that split lives in the state rather than in this widget.
///
/// Loading more is automatic on scroll and manual after a failure. The
/// automatic trigger deliberately does **not** re-arm while
/// [PagedListState.loadMoreError] is set: sitting at the bottom of a list
/// against a server that is refusing would otherwise re-issue the same request
/// on every frame. The user's tap is what clears it.
///
/// The caller supplies the surrounding chrome. Anything that filters the list —
/// the roster's search field and section picker, say — belongs *above* this
/// widget rather than inside it, so it stays visible while the first page of a
/// new query loads and while an empty result is explained.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    required this.state,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onRetry,
    this.padding = const EdgeInsets.all(AppConstants.spacingMd),
    this.itemSpacing = AppConstants.spacingSm,
    this.endOfListLabel,
    this.loadMoreExtent = 400,
    super.key,
  });

  /// The first page as an `AsyncValue`; every page after it inside the data.
  final AsyncValue<PagedListState<T>> state;

  final Widget Function(BuildContext context, T item) itemBuilder;

  /// The call answered with no rows. A *designed* state, not an error (§6.4) —
  /// and it must return something scrollable, since [onRefresh] needs a gesture
  /// target and an empty list is exactly where a user will pull.
  final WidgetBuilder emptyBuilder;

  /// Fetch the next page. Called at most once per scroll past
  /// [loadMoreExtent], and again only on an explicit tap after a failure.
  final VoidCallback onLoadMore;

  /// Pull-to-refresh: re-read from page one.
  final Future<void> Function() onRefresh;

  /// Retry after the *first* page failed.
  final VoidCallback onRetry;

  final EdgeInsets padding;
  final double itemSpacing;

  /// Optional footer for a fully-loaded list — `'All 34 students'`. Omitted
  /// entirely when null, because a short list doesn't need to be told it ended.
  final String? endOfListLabel;

  /// How close to the bottom, in pixels, triggers the next page.
  final double loadMoreExtent;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }
    if (_controller.position.extentAfter > widget.loadMoreExtent) {
      return;
    }
    _requestMore();
  }

  /// The one gate every automatic load-more passes through: there must be a
  /// loaded page, another page behind it, nothing already in flight, and no
  /// unacknowledged failure.
  void _requestMore() {
    final PagedListState<T>? state = widget.state.value;
    if (state == null ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.loadMoreError != null) {
      return;
    }

    widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorRetryView(
          error: AppError.from(error),
          onRetry: widget.onRetry,
        ),
        data: (PagedListState<T> state) =>
            state.isEmpty ? widget.emptyBuilder(context) : _list(state),
      ),
    );
  }

  Widget _list(PagedListState<T> state) {
    final bool hasFooter = state.hasFooter || _endLabel(state) != null;
    final int itemCount = state.items.length + (hasFooter ? 1 : 0);

    // A post-frame check, for the case a page arrives without filling the
    // viewport: the scroll listener can't fire when there is nothing to scroll,
    // and the list would sit there with more rows available and no way to ask.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      if (_controller.position.extentAfter <= widget.loadMoreExtent) {
        _requestMore();
      }
    });

    return ListView.separated(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      itemCount: itemCount,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: widget.itemSpacing),
      itemBuilder: (BuildContext context, int index) {
        if (index < state.items.length) {
          return widget.itemBuilder(context, state.items[index]);
        }
        return _Footer(
          state: state,
          endOfListLabel: _endLabel(state),
          onRetry: widget.onLoadMore,
        );
      },
    );
  }

  /// The end-of-list line only earns its place once the list is genuinely
  /// finished and nothing else is happening in the footer.
  String? _endLabel(PagedListState<T> state) {
    if (state.hasMore || state.hasFooter) {
      return null;
    }
    return widget.endOfListLabel;
  }
}

/// The single trailing row: a spinner for a page in flight, a compact retry for
/// one that failed, or the end-of-list line.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.state,
    required this.endOfListLabel,
    required this.onRetry,
  });

  final PagedListState<dynamic> state;
  final String? endOfListLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppError? error = state.loadMoreError;

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
        child: Column(
          children: <Widget>[
            Icon(
              ErrorRetryView.iconFor(error),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              error.displayMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            TextButton(onPressed: onRetry, child: const Text('Load more')),
          ],
        ),
      );
    }

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spacingLg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final String? label = endOfListLabel;
    if (label == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
