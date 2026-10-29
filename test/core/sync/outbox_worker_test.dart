import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/sync/local_activity.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_entry.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_store.dart';
import 'package:smart_teacher_mobile/src/core/sync/outbox_worker.dart';
import 'package:smart_teacher_mobile/src/core/sync/watch_interval.dart';

void main() {
  group('coalescing (mobile plan §2.2)', () {
    test('two video beats for one resource merge into one request', () {
      // The headline case: four beats a minute per viewer only stays
      // affordable because a queue that cannot drain collapses rather than
      // grows.
      final OutboxEntry first = _videoEntry(
        intervals: const <WatchInterval>[WatchInterval(0, 15)],
        positionSecs: 15,
        at: DateTime(2026, 9, 11, 10, 0, 0),
      );
      final OutboxEntry second = _videoEntry(
        intervals: const <WatchInterval>[WatchInterval(15, 30)],
        positionSecs: 30,
        at: DateTime(2026, 9, 11, 10, 0, 15),
      );

      final OutboxEntry merged = first.mergeWith(second);

      expect(merged.intervals, const <WatchInterval>[WatchInterval(0, 30)]);
      expect(merged.positionSecs, 30);
      expect(merged.clientUpdatedAt, second.clientUpdatedAt);
    });

    test('an out-of-order beat keeps the newer position but still unions', () {
      // Position is last-write-wins on clientUpdatedAt; coverage is a union
      // and does not care about order.
      final OutboxEntry newer = _videoEntry(
        intervals: const <WatchInterval>[WatchInterval(60, 90)],
        positionSecs: 90,
        at: DateTime(2026, 9, 11, 10, 5),
      );
      final OutboxEntry older = _videoEntry(
        intervals: const <WatchInterval>[WatchInterval(0, 30)],
        positionSecs: 30,
        at: DateTime(2026, 9, 11, 10, 0),
      );

      final OutboxEntry merged = newer.mergeWith(older);

      expect(merged.positionSecs, 90);
      expect(merged.clientUpdatedAt, newer.clientUpdatedAt);
      expect(merged.intervals, const <WatchInterval>[
        WatchInterval(0, 30),
        WatchInterval(60, 90),
      ]);
    });

    test('document progress keeps the newest page only', () {
      final OutboxEntry first = _documentEntry(
        lastPage: 3,
        at: DateTime(2026, 9, 11, 10, 0),
      );
      final OutboxEntry second = _documentEntry(
        lastPage: 9,
        at: DateTime(2026, 9, 11, 10, 1),
      );

      expect(first.mergeWith(second).lastPage, 9);
    });

    test('mark-then-unmark cancels down to the later of the two', () {
      // Last one wins, and it may be the opposite kind — which is what turns
      // an accidental double tap into one request instead of two that race.
      final OutboxEntry marked = _completionEntry(
        kind: OutboxKind.documentComplete,
        at: DateTime(2026, 9, 11, 10, 0),
      );
      final OutboxEntry unmarked = _completionEntry(
        kind: OutboxKind.documentUncomplete,
        at: DateTime(2026, 9, 11, 10, 1),
      );

      expect(marked.mergeWith(unmarked).kind, OutboxKind.documentUncomplete);
    });

    test('the store coalesces on enqueue rather than queueing twice', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();

      await store.enqueue(
        _videoEntry(
          id: 'a',
          intervals: const <WatchInterval>[WatchInterval(0, 15)],
          positionSecs: 15,
          at: DateTime(2026, 9, 11, 10, 0),
        ),
      );
      await store.enqueue(
        _videoEntry(
          id: 'b',
          intervals: const <WatchInterval>[WatchInterval(15, 30)],
          positionSecs: 30,
          at: DateTime(2026, 9, 11, 10, 0, 15),
        ),
      );

      final List<OutboxEntry> pending = await store.pendingEntries();
      expect(pending, hasLength(1));
      expect(pending.single.intervals, const <WatchInterval>[
        WatchInterval(0, 30),
      ]);
    });

    test('different resources never coalesce', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      await store.enqueue(_videoEntry(id: 'a', resourceId: 'video-1'));
      await store.enqueue(_videoEntry(id: 'b', resourceId: 'video-2'));

      expect(await store.pendingEntries(), hasLength(2));
    });
  });

  group('flush', () {
    test('sends a due entry, removes it, and reconciles the cache', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      final _RecordingTransport transport = _RecordingTransport();
      final _RecordingSink sink = _RecordingSink();
      await store.enqueue(_videoEntry());

      final OutboxFlushReport report = await OutboxWorker(
        store: store,
        transport: transport,
        sink: sink,
      ).flush();

      expect(report.outcome, OutboxFlushOutcome.drained);
      expect(report.sent, 1);
      expect(transport.sent, hasLength(1));
      expect(await store.pendingEntries(), isEmpty);
      expect(sink.received, hasLength(1));
    });

    test('an empty queue is idle, not an error', () async {
      final OutboxFlushReport report = await OutboxWorker(
        store: InMemoryOutboxStore(),
        transport: _RecordingTransport(),
      ).flush();

      expect(report.outcome, OutboxFlushOutcome.idle);
    });

    test('an entry in backoff is not due yet', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      final _RecordingTransport transport = _RecordingTransport();
      await store.enqueue(
        _videoEntry(nextAttemptAt: DateTime(2026, 9, 11, 10, 5)),
      );

      final OutboxFlushReport report = await OutboxWorker(
        store: store,
        transport: transport,
        clock: () => DateTime(2026, 9, 11, 10),
      ).flush();

      expect(report.outcome, OutboxFlushOutcome.idle);
      expect(transport.sent, isEmpty);
      expect(await store.pendingEntries(), hasLength(1));
    });
  });

  group('discard vs retry (mobile plan §2.2)', () {
    test('a 404 is discarded — the resource left this user\'s scope', () async {
      await _expectDiscarded(
        const NotFoundError(message: "We couldn't find that."),
      );
    });

    test('a 400 is discarded — the server will never accept it', () async {
      await _expectDiscarded(
        const ValidationError(message: 'Bad payload', fieldErrors: <String>[]),
      );
    });

    test('a 403 is discarded', () async {
      await _expectDiscarded(const ForbiddenError(message: 'No.'));
    });

    test('a 5xx is retried with backoff', () async {
      await _expectDeferred(
        const UnknownError(message: 'Server error', statusCode: 503),
      );
    });

    test('a network failure is retried', () async {
      await _expectDeferred(const NetworkError(message: 'Offline'));
    });

    test('a 429 is retried and honours Retry-After', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      await store.enqueue(_videoEntry());

      await OutboxWorker(
        store: store,
        transport: _RecordingTransport(
          error: const RateLimitedError(
            message: 'Slow down',
            retryAfter: Duration(seconds: 42),
          ),
        ),
        clock: () => DateTime(2026, 9, 11, 10),
      ).flush();

      final OutboxEntry pending = (await store.pendingEntries()).single;
      expect(pending.nextAttemptAt, DateTime(2026, 9, 11, 10, 0, 42));
    });

    test('a 401 stops the drain and keeps the entry', () async {
      // The interceptor has already spent its one silent refresh by now, so
      // the session really is gone — and the sign-out path clears the queue
      // wholesale rather than this discarding one entry at a time.
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      await store.enqueue(_videoEntry(id: 'a', resourceId: 'video-1'));
      await store.enqueue(_videoEntry(id: 'b', resourceId: 'video-2'));

      final OutboxFlushReport report = await OutboxWorker(
        store: store,
        transport: _RecordingTransport(
          error: const UnauthorizedError(message: 'Session expired'),
        ),
      ).flush();

      expect(report.outcome, OutboxFlushOutcome.unauthenticated);
      expect(report.sent, 0);
      expect(await store.pendingEntries(), hasLength(2));
    });

    test('backoff doubles with each attempt, up to the cap', () async {
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      await store.enqueue(_videoEntry(attempts: 2));

      await OutboxWorker(
        store: store,
        transport: _RecordingTransport(
          error: const NetworkError(message: 'Offline'),
        ),
        clock: () => DateTime(2026, 9, 11, 10),
      ).flush();

      // 2s base, doubled twice.
      expect(
        (await store.pendingEntries()).single.nextAttemptAt,
        DateTime(2026, 9, 11, 10, 0, 8),
      );
    });

    test('a retryable entry is dropped once it exhausts its attempts', () async {
      // Otherwise one poisoned payload wedges the head of a FIFO queue for
      // good.
      final InMemoryOutboxStore store = InMemoryOutboxStore();
      await store.enqueue(_videoEntry(attempts: maximumOutboxAttempts - 1));

      final OutboxFlushReport report = await OutboxWorker(
        store: store,
        transport: _RecordingTransport(
          error: const NetworkError(message: 'Offline'),
        ),
      ).flush();

      expect(report.discarded, 1);
      expect(await store.pendingEntries(), isEmpty);
    });
  });

  group('request body', () {
    test('a video beat carries intervals and the action timestamp', () {
      final Map<String, dynamic>? body = _videoEntry(
        intervals: const <WatchInterval>[WatchInterval(0, 30)],
        positionSecs: 30,
        at: DateTime.utc(2026, 9, 11, 10),
      ).toRequestBody();

      expect(body, <String, dynamic>{
        'positionSecs': 30,
        'intervals': <List<int>>[
          <int>[0, 30],
        ],
        'clientUpdatedAt': '2026-09-11T10:00:00.000Z',
      });
    });

    test('a completion toggle sends no body at all', () {
      // A bare POST/DELETE — `{}` would invite a validation pipe to have an
      // opinion about it.
      expect(
        _completionEntry(kind: OutboxKind.documentComplete).toRequestBody(),
        isNull,
      );
    });
  });
}

Future<void> _expectDiscarded(AppError error) async {
  final InMemoryOutboxStore store = InMemoryOutboxStore();
  await store.enqueue(_videoEntry());

  final OutboxFlushReport report = await OutboxWorker(
    store: store,
    transport: _RecordingTransport(error: error),
  ).flush();

  expect(report.discarded, 1);
  expect(report.deferred, 0);
  expect(await store.pendingEntries(), isEmpty);
}

Future<void> _expectDeferred(AppError error) async {
  final InMemoryOutboxStore store = InMemoryOutboxStore();
  await store.enqueue(_videoEntry());

  final OutboxFlushReport report = await OutboxWorker(
    store: store,
    transport: _RecordingTransport(error: error),
  ).flush();

  expect(report.outcome, OutboxFlushOutcome.deferred);
  expect(report.deferred, 1);
  expect(await store.pendingEntries(), hasLength(1));
}

OutboxEntry _videoEntry({
  String id = 'entry-1',
  String resourceId = 'video-1',
  List<WatchInterval> intervals = const <WatchInterval>[WatchInterval(0, 15)],
  int positionSecs = 15,
  DateTime? at,
  int attempts = 0,
  DateTime? nextAttemptAt,
}) => OutboxEntry(
  id: id,
  target: OutboxTarget(
    kind: OutboxKind.videoProgress,
    resourceId: resourceId,
  ),
  clientUpdatedAt: at ?? DateTime(2026, 9, 11, 10),
  positionSecs: positionSecs,
  intervals: intervals,
  attempts: attempts,
  nextAttemptAt: nextAttemptAt,
);

OutboxEntry _documentEntry({
  String id = 'entry-1',
  String resourceId = 'doc-1',
  required int lastPage,
  DateTime? at,
}) => OutboxEntry(
  id: id,
  target: OutboxTarget(
    kind: OutboxKind.documentProgress,
    resourceId: resourceId,
  ),
  clientUpdatedAt: at ?? DateTime(2026, 9, 11, 10),
  lastPage: lastPage,
);

OutboxEntry _completionEntry({
  required OutboxKind kind,
  String id = 'entry-1',
  String resourceId = 'doc-1',
  DateTime? at,
}) => OutboxEntry(
  id: id,
  target: OutboxTarget(kind: kind, resourceId: resourceId),
  clientUpdatedAt: at ?? DateTime(2026, 9, 11, 10),
);

class _RecordingTransport implements OutboxTransport {
  _RecordingTransport({this.error});

  final AppError? error;
  final List<OutboxEntry> sent = <OutboxEntry>[];

  @override
  Future<LocalActivity?> send(OutboxEntry entry) async {
    if (error case final AppError failure) {
      throw failure;
    }
    sent.add(entry);
    return LocalActivity(
      resourceId: entry.resourceId,
      resourceType: 'VIDEO',
      status: 'IN_PROGRESS',
      lastAccessedAt: DateTime(2026, 9, 11, 10),
      serverUpdatedAt: DateTime(2026, 9, 11, 10),
    );
  }
}

class _RecordingSink implements OutboxSyncSink {
  final List<LocalActivity> received = <LocalActivity>[];

  @override
  Future<void> onSynced(LocalActivity activity) async =>
      received.add(activity);
}
