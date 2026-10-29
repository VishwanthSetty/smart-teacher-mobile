import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progress_repository.dart';
import '../domain/progress_summary_entity.dart';

/// Backs both progress screens (mobile plan §5.3).
///
/// There is one controller, not two, because `GET /me/progress/summary` is
/// already actor-scoped — the teacher's "My Preparation Progress" and the
/// student's "Learning Progress" are the same call answered against a
/// different actor. Nothing here reads the role; the screens differ only in
/// their heading, and the teacher's says "My preparation" explicitly so it is
/// never confused with a class report.
///
/// Shaped like [LibraryController]: always fetches in [build] since nothing
/// earlier caches this, and an empty list is data rather than an error — an
/// unentitled school and a student with no enrollment both answer `200 []`.
class ProgressSummaryController
    extends AsyncNotifier<List<ProgressSummaryEntity>> {
  bool _refreshing = false;

  @override
  Future<List<ProgressSummaryEntity>> build() => _fetch();

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<ProgressSummaryEntity>> next =
          await AsyncValue.guard(_fetch);
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<List<ProgressSummaryEntity>> _fetch() =>
      ref.read(progressRepositoryProvider).fetchSummary();
}

/// Deliberately **not** auto-disposing and deliberately not suspension-latching.
///
/// Not auto-disposing, because both home screens link into this and a user
/// bouncing between them should not re-issue the rollup each time.
///
/// Not latching, because `SuspensionInterceptor` already observes this call: a
/// screen that also self-reported would turn one suspension-flavoured `403`
/// into the two-in-a-row the interceptor treats as corroboration. Only
/// `/curricula`, which cannot be refused by a narrower entitlement, confirms on
/// its own.
final AsyncNotifierProvider<
  ProgressSummaryController,
  List<ProgressSummaryEntity>
>
progressSummaryControllerProvider =
    AsyncNotifierProvider<
      ProgressSummaryController,
      List<ProgressSummaryEntity>
    >(
      ProgressSummaryController.new,
      retry: (int retryCount, Object error) => null,
    );
