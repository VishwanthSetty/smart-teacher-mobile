import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/pagination/cursor_paged_state.dart';
import '../data/history_repository.dart';
import '../domain/resource_activity_entity.dart';

/// The `All / In progress / Completed` chips (mobile plan §5.2).
///
/// `null` is *All*, and is what gets no `?status=` on the wire at all — not an
/// empty one, which the server would read as a filter.
class HistoryStatusFilter extends Notifier<ActivityProgressStatus?> {
  HistoryStatusFilter(this.type);

  /// Which tab this filter belongs to. Videos and Documents each keep their
  /// own selection, so switching tabs does not silently re-filter the other.
  final ActivityResourceType type;

  @override
  ActivityProgressStatus? build() => null;

  void select(ActivityProgressStatus? status) {
    if (state != status) {
      state = status;
    }
  }
}

/// One tab of the history feed (mobile plan §5.2).
///
/// Keyed by resource type because **Videos** and **Documents** are separate
/// tabs, each with its own scroll position, its own cursor and its own filter.
/// Sharing one controller between them would make switching tabs re-page from
/// the top.
///
/// The controller *watches* its filter, so changing a chip restarts from the
/// first page **by construction** rather than by remembering to reset a cursor
/// — the same reason the roster's query lives in its own notifier.
///
/// Auto-disposing: history is a screen a user visits and leaves, and holding
/// every page of it for the session buys nothing.
class HistoryController
    extends AsyncNotifier<CursorPagedState<ResourceActivityEntity>> {
  HistoryController(this.type);

  final ActivityResourceType type;

  /// Rises on every query change. A page still in flight when the filter
  /// changes is dropped rather than appended to a list that has since been
  /// re-queried — the same generation guard the roster uses.
  int _generation = 0;
  bool _loadingMore = false;

  @override
  Future<CursorPagedState<ResourceActivityEntity>> build() async {
    ref.watch(historyStatusFilterProvider(type));
    _generation++;
    return _firstPage();
  }

  /// Pull-to-refresh, and the error state's "Try again".
  Future<void> refresh() async {
    final int generation = ++_generation;
    final AsyncValue<CursorPagedState<ResourceActivityEntity>> next =
        await AsyncValue.guard(_firstPage);
    if (ref.mounted && generation == _generation) {
      state = next;
    }
  }

  /// Appends the next page. Never replaces the rows already on screen — a
  /// failure lands in [CursorPagedState.loadMoreError] instead.
  Future<void> loadMore() async {
    final CursorPagedState<ResourceActivityEntity>? current = state.value;
    if (current == null ||
        _loadingMore ||
        !current.hasMore ||
        current.cursor == null) {
      return;
    }
    _loadingMore = true;
    final int generation = _generation;
    state = AsyncData<CursorPagedState<ResourceActivityEntity>>(
      current.loadingMore(),
    );

    try {
      final List<ResourceActivityEntity> page = await ref
          .read(historyRepositoryProvider)
          .fetchHistory(
            type: type,
            status: ref.read(historyStatusFilterProvider(type)),
            cursor: current.cursor,
            limit: activityPageLimit,
          );
      if (!ref.mounted || generation != _generation) {
        return;
      }
      state = AsyncData<CursorPagedState<ResourceActivityEntity>>(
        current.appendPage(
          page,
          limit: activityPageLimit,
          identity: (ResourceActivityEntity row) => row.id,
          cursorOf: (ResourceActivityEntity row) => row.id,
        ),
      );
    } on AppError catch (error) {
      if (ref.mounted && generation == _generation) {
        state = AsyncData<CursorPagedState<ResourceActivityEntity>>(
          current.failedToLoadMore(error),
        );
      }
    } finally {
      _loadingMore = false;
    }
  }

  Future<CursorPagedState<ResourceActivityEntity>> _firstPage() async {
    final List<ResourceActivityEntity> page = await ref
        .read(historyRepositoryProvider)
        .fetchHistory(
          type: type,
          status: ref.read(historyStatusFilterProvider(type)),
          limit: activityPageLimit,
        );
    return CursorPagedState<ResourceActivityEntity>.firstPage(
      page,
      limit: activityPageLimit,
      cursorOf: (ResourceActivityEntity row) => row.id,
    );
  }
}

final NotifierProviderFamily<
  HistoryStatusFilter,
  ActivityProgressStatus?,
  ActivityResourceType
>
historyStatusFilterProvider =
    NotifierProvider.family<
      HistoryStatusFilter,
      ActivityProgressStatus?,
      ActivityResourceType
    >(HistoryStatusFilter.new);

final AsyncNotifierProviderFamily<
  HistoryController,
  CursorPagedState<ResourceActivityEntity>,
  ActivityResourceType
>
historyControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      HistoryController,
      CursorPagedState<ResourceActivityEntity>,
      ActivityResourceType
    >(
      HistoryController.new,
      // Matches every other controller in the app: a failed load gets an
      // explicit "Try again" rather than a background retry loop, which
      // against a suspended school would 403 forever.
      retry: (int retryCount, Object error) => null,
    );
