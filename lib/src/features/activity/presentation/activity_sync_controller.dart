import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/activity_cache_store.dart';
import '../../../core/sync/local_activity.dart';
import '../../../core/sync/outbox_entry.dart';
import '../../../core/sync/outbox_store.dart';
import '../../../core/sync/outbox_worker.dart';
import '../../../core/sync/watch_interval.dart';
import '../data/progress_outbox_transport.dart';

/// The **only** way the app writes progress (mobile plan §2.2).
///
/// Every method here does the same three things in the same order:
///
/// 1. write the local cache optimistically, so the UI never waits on a network
///    round trip;
/// 2. enqueue the write, where it coalesces with anything already pending for
///    the same resource;
/// 3. ask the worker to drain, without awaiting it.
///
/// Step 3 is deliberately fire-and-forget. A beat that cannot be delivered is
/// already durable in the outbox, so blocking playback on it would trade the
/// thing that matters (smooth video) for the thing that doesn't (this
/// particular beat arriving now rather than in thirty seconds).
class ActivitySyncController {
  ActivitySyncController({
    required OutboxStore outbox,
    required ActivityCacheStore cache,
    required OutboxWorker worker,
    DateTime Function() clock = DateTime.now,
  }) : _outbox = outbox,
       _cache = cache,
       _worker = worker,
       _clock = clock;

  final OutboxStore _outbox;
  final ActivityCacheStore _cache;
  final OutboxWorker _worker;
  final DateTime Function() _clock;

  final Random _random = Random();
  int _sequence = 0;

  /// Records a playback beat.
  ///
  /// [intervals] are the ranges played **since the last beat**, never the full
  /// history — the server merges, and resending everything both wastes
  /// bandwidth and risks the wall-clock clamp truncating an honest beat.
  ///
  /// An empty [intervals] with an unchanged position is dropped rather than
  /// queued: it would be a request that tells the server nothing it doesn't
  /// already know.
  Future<void> recordVideoBeat({
    required String videoId,
    required List<WatchInterval> intervals,
    required Duration position,
    String title = '',
    int? durationSecs,
  }) async {
    if (videoId.isEmpty) {
      return;
    }
    final DateTime now = _clock();

    await _writeOptimistic(
      resourceId: videoId,
      resourceType: 'VIDEO',
      title: title,
      now: now,
      positionSecs: position.inSeconds,
      durationSecs: durationSecs,
    );

    await _outbox.enqueue(
      OutboxEntry(
        id: _nextId(),
        target: OutboxTarget(
          kind: OutboxKind.videoProgress,
          resourceId: videoId,
        ),
        // Stamped now — at the user action — not when the queue drains.
        clientUpdatedAt: now,
        positionSecs: position.inSeconds,
        intervals: mergeWatchIntervals(intervals, durationSecs: durationSecs),
      ),
    );

    unawaited(flush());
  }

  /// Records the reader's settled page (mobile plan §4).
  ///
  /// Debouncing lives in the reader, not here: this is called on page settle,
  /// and every call is meant to reach the queue.
  Future<void> recordDocumentPage({
    required String documentId,
    required int lastPage,
    String title = '',
    int? pageCount,
  }) async {
    if (documentId.isEmpty || lastPage < 1) {
      return;
    }
    final DateTime now = _clock();

    await _writeOptimistic(
      resourceId: documentId,
      resourceType: 'DOCUMENT',
      title: title,
      now: now,
      lastPage: lastPage,
      pageCount: pageCount,
    );

    await _outbox.enqueue(
      OutboxEntry(
        id: _nextId(),
        target: OutboxTarget(
          kind: OutboxKind.documentProgress,
          resourceId: documentId,
        ),
        clientUpdatedAt: now,
        lastPage: lastPage,
        pageCount: pageCount,
      ),
    );

    unawaited(flush());
  }

  /// The explicit **"Mark as read"** control, and its undo.
  ///
  /// This is the only route by which a document reaches `COMPLETED` — reaching
  /// the last page does not, and the UI must never imply it does (mobile plan
  /// §4). The optimistic write flips [LocalActivity.status] here because,
  /// unlike a video's percent, this one is not the server's to compute: the
  /// learner asserted it.
  Future<void> setDocumentComplete({
    required String documentId,
    required bool isComplete,
    String title = '',
  }) async {
    if (documentId.isEmpty) {
      return;
    }
    final DateTime now = _clock();
    final LocalActivity? existing = await _cache.read(documentId);

    await _cache.write(
      LocalActivity(
        resourceId: documentId,
        resourceType: 'DOCUMENT',
        status: isComplete ? 'COMPLETED' : 'IN_PROGRESS',
        lastAccessedAt: now,
        title: title.isEmpty ? (existing?.title ?? '') : title,
        percent: existing?.percent ?? 0,
        positionSecs: existing?.positionSecs ?? 0,
        lastPage: existing?.lastPage,
        pageCount: existing?.pageCount,
        durationSecs: existing?.durationSecs,
        completedAt: isComplete ? (existing?.completedAt ?? now) : null,
        // Cleared: this row is a local assertion again until a flush confirms
        // it, which is what keeps the resume chooser from treating it as a
        // cross-device fact.
        serverUpdatedAt: null,
      ),
    );

    await _outbox.enqueue(
      OutboxEntry(
        id: _nextId(),
        target: OutboxTarget(
          kind: isComplete
              ? OutboxKind.documentComplete
              : OutboxKind.documentUncomplete,
          resourceId: documentId,
        ),
        clientUpdatedAt: now,
      ),
    );

    unawaited(flush());
  }

  /// Drains the queue. Safe to call from anywhere and at any frequency — the
  /// worker collapses re-entrant calls.
  Future<OutboxFlushReport> flush() => _worker.flush();

  /// What the player or reader should restore on open, if anything.
  Future<LocalActivity?> cachedActivity(String resourceId) =>
      _cache.read(resourceId);

  /// Drops every local trace of this user's activity.
  ///
  /// Called on sign-out: the cache and the queue are both this actor's own
  /// data, and carrying either into the next session would leak one user's
  /// history to the next (mobile plan §0).
  Future<void> clearForSignOut() async {
    await _outbox.clear();
    await _cache.clear();
  }

  /// Merges an optimistic update onto whatever the cache already holds.
  ///
  /// [LocalActivity.status] and [LocalActivity.percent] are carried across
  /// untouched, never recomputed. Video completion is unique coverage against
  /// a **server-configured** threshold (`VIDEO_COMPLETION_PERCENT`), so a
  /// client that guessed at either would eventually disagree with the badge
  /// the server renders — and the plan is explicit that the client must not
  /// hardcode 90%.
  Future<void> _writeOptimistic({
    required String resourceId,
    required String resourceType,
    required String title,
    required DateTime now,
    int? positionSecs,
    int? lastPage,
    int? pageCount,
    int? durationSecs,
  }) async {
    final LocalActivity? existing = await _cache.read(resourceId);

    await _cache.write(
      LocalActivity(
        resourceId: resourceId,
        resourceType: resourceType,
        status: existing?.status ?? 'IN_PROGRESS',
        lastAccessedAt: now,
        title: title.isEmpty ? (existing?.title ?? '') : title,
        percent: existing?.percent ?? 0,
        positionSecs: positionSecs ?? existing?.positionSecs ?? 0,
        lastPage: lastPage ?? existing?.lastPage,
        pageCount: pageCount ?? existing?.pageCount,
        durationSecs: durationSecs ?? existing?.durationSecs,
        completedAt: existing?.completedAt,
        // An optimistic row is unsynced by definition, even when the row it
        // replaces had been reconciled.
        serverUpdatedAt: null,
      ),
    );
  }

  /// Monotonic within a session, random across them.
  ///
  /// The queue outlives the process, so a bare counter would collide with ids
  /// written by the previous run and silently overwrite a pending entry.
  String _nextId() =>
      '${_clock().microsecondsSinceEpoch}-${_sequence++}-'
      '${_random.nextInt(0xFFFFFF).toRadixString(16)}';
}

final Provider<OutboxWorker> outboxWorkerProvider = Provider<OutboxWorker>((
  Ref ref,
) {
  return OutboxWorker(
    store: ref.watch(outboxStoreProvider),
    transport: ref.watch(outboxTransportProvider),
    sink: ActivityCacheSyncSink(ref.watch(activityCacheStoreProvider)),
  );
});

final Provider<ActivitySyncController> activitySyncControllerProvider =
    Provider<ActivitySyncController>(
      (Ref ref) => ActivitySyncController(
        outbox: ref.watch(outboxStoreProvider),
        cache: ref.watch(activityCacheStoreProvider),
        worker: ref.watch(outboxWorkerProvider),
      ),
    );
