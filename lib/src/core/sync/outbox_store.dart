import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import 'outbox_entry.dart';
import 'watch_interval.dart';

/// The queue cap (mobile plan §2.2).
///
/// Coalescing keeps a real session two orders of magnitude below this; the cap
/// exists for the pathological case — weeks offline, or a server rejecting
/// everything with a retryable status. Oldest entries are dropped first: a beat
/// from last Tuesday has already been superseded by every later one for the
/// same resource, so losing it costs almost nothing, whereas dropping the
/// newest would discard what the user just did.
const int outboxCapacity = 500;

/// Durable storage for pending writes.
///
/// An interface rather than the Drift class directly, so the worker's tests run
/// against an in-memory implementation instead of a native sqlite binary — and
/// so presentation keeps depending on an interface, per the repo's standing
/// rule about repositories.
abstract interface class OutboxStore {
  /// Adds [entry], coalescing it onto any pending entry with the same merge
  /// key. Returns the entry actually stored.
  Future<OutboxEntry> enqueue(OutboxEntry entry);

  /// Entries whose backoff has elapsed, oldest first.
  Future<List<OutboxEntry>> dueEntries(DateTime now);

  /// All pending entries, oldest first — including ones still in backoff.
  Future<List<OutboxEntry>> pendingEntries();

  Future<void> remove(String id);

  /// Records a failed attempt and re-arms the backoff gate.
  Future<void> reschedule(OutboxEntry entry, DateTime nextAttemptAt);

  Future<void> clear();
}

/// The production store.
class DriftOutboxStore implements OutboxStore {
  DriftOutboxStore(this._db);

  final AppDatabase _db;

  @override
  Future<OutboxEntry> enqueue(OutboxEntry entry) {
    // One transaction, because "is there something to merge with?" and the
    // write that answers it must not interleave with a concurrent beat — two
    // simultaneous enqueues that both read "nothing pending" would each insert,
    // and the queue would carry a duplicate the worker then sends twice.
    return _db.transaction(() async {
      final List<OutboxEntry> pending = await pendingEntries();
      final OutboxEntry? existing = pending
          .where(
            (OutboxEntry row) =>
                row.target.mergeKey == entry.target.mergeKey,
          )
          .firstOrNull;

      if (existing != null) {
        final OutboxEntry merged = existing.mergeWith(entry);
        await (_db.update(_db.outboxRows)
              ..where(($OutboxRowsTable row) => row.id.equals(existing.id)))
            .write(_companionFor(merged));
        return merged;
      }

      await _db.into(_db.outboxRows).insert(_insertableFor(entry));
      await _enforceCapacity();
      return entry;
    });
  }

  @override
  Future<List<OutboxEntry>> dueEntries(DateTime now) async {
    final List<OutboxEntry> pending = await pendingEntries();
    return pending.where((OutboxEntry entry) => entry.isReady(now)).toList();
  }

  @override
  Future<List<OutboxEntry>> pendingEntries() async {
    final List<OutboxEntry> rows =
        await (_db.select(_db.outboxRows)..orderBy(<
          OrderClauseGenerator<$OutboxRowsTable>
        >[
          ($OutboxRowsTable row) => OrderingTerm.asc(row.sequence),
        ])).map(_toEntry).get();
    return rows;
  }

  @override
  Future<void> remove(String id) async {
    await (_db.delete(_db.outboxRows)
          ..where(($OutboxRowsTable row) => row.id.equals(id)))
        .go();
  }

  @override
  Future<void> reschedule(OutboxEntry entry, DateTime nextAttemptAt) async {
    await (_db.update(_db.outboxRows)
          ..where(($OutboxRowsTable row) => row.id.equals(entry.id)))
        .write(
          OutboxRowsCompanion(
            attempts: Value<int>(entry.attempts + 1),
            nextAttemptAt: Value<DateTime?>(nextAttemptAt),
          ),
        );
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.outboxRows).go();
  }

  Future<void> _enforceCapacity() async {
    final List<OutboxEntry> pending = await pendingEntries();
    if (pending.length <= outboxCapacity) {
      return;
    }
    final Iterable<String> excess = pending
        .take(pending.length - outboxCapacity)
        .map((OutboxEntry entry) => entry.id);
    await (_db.delete(_db.outboxRows)
          ..where(($OutboxRowsTable row) => row.id.isIn(excess)))
        .go();
  }

  OutboxRowsCompanion _insertableFor(OutboxEntry entry) =>
      OutboxRowsCompanion.insert(
        id: entry.id,
        kind: entry.kind.wireValue,
        resourceId: entry.resourceId,
        clientUpdatedAt: entry.clientUpdatedAt,
        positionSecs: Value<int?>(entry.positionSecs),
        intervalsJson: Value<String>(_encodeIntervals(entry.intervals)),
        lastPage: Value<int?>(entry.lastPage),
        pageCount: Value<int?>(entry.pageCount),
        resourceKind: Value<String?>(entry.resourceKind),
        bookmarkId: Value<String?>(entry.bookmarkId),
        collectionId: Value<String?>(entry.collectionId),
        attempts: Value<int>(entry.attempts),
        nextAttemptAt: Value<DateTime?>(entry.nextAttemptAt),
      );

  OutboxRowsCompanion _companionFor(OutboxEntry entry) =>
      OutboxRowsCompanion(
        kind: Value<String>(entry.kind.wireValue),
        resourceId: Value<String>(entry.resourceId),
        clientUpdatedAt: Value<DateTime>(entry.clientUpdatedAt),
        positionSecs: Value<int?>(entry.positionSecs),
        intervalsJson: Value<String>(_encodeIntervals(entry.intervals)),
        lastPage: Value<int?>(entry.lastPage),
        pageCount: Value<int?>(entry.pageCount),
        resourceKind: Value<String?>(entry.resourceKind),
        bookmarkId: Value<String?>(entry.bookmarkId),
        collectionId: Value<String?>(entry.collectionId),
        attempts: const Value<int>(0),
        nextAttemptAt: const Value<DateTime?>(null),
      );

  OutboxEntry _toEntry(OutboxRow row) => OutboxEntry(
    id: row.id,
    target: OutboxTarget(
      // A row whose kind this build no longer knows is treated as video
      // progress rather than dropped silently; the worker's 4xx discard will
      // clear it if the server disagrees.
      kind: OutboxKind.fromWire(row.kind) ?? OutboxKind.videoProgress,
      resourceId: row.resourceId,
    ),
    clientUpdatedAt: row.clientUpdatedAt,
    positionSecs: row.positionSecs,
    intervals: parseWatchIntervals(_decodeIntervals(row.intervalsJson)),
    lastPage: row.lastPage,
    pageCount: row.pageCount,
    resourceKind: row.resourceKind,
    bookmarkId: row.bookmarkId,
    collectionId: row.collectionId,
    attempts: row.attempts,
    nextAttemptAt: row.nextAttemptAt,
  );
}

/// The store the worker's unit tests run against, and the fallback when the
/// on-device database cannot be opened.
class InMemoryOutboxStore implements OutboxStore {
  final List<OutboxEntry> _entries = <OutboxEntry>[];

  @override
  Future<OutboxEntry> enqueue(OutboxEntry entry) async {
    final int index = _entries.indexWhere(
      (OutboxEntry row) => row.target.mergeKey == entry.target.mergeKey,
    );
    if (index >= 0) {
      final OutboxEntry merged = _entries[index].mergeWith(entry);
      _entries[index] = merged;
      return merged;
    }
    _entries.add(entry);
    if (_entries.length > outboxCapacity) {
      _entries.removeRange(0, _entries.length - outboxCapacity);
    }
    return entry;
  }

  @override
  Future<List<OutboxEntry>> dueEntries(DateTime now) async =>
      _entries.where((OutboxEntry entry) => entry.isReady(now)).toList();

  @override
  Future<List<OutboxEntry>> pendingEntries() async =>
      List<OutboxEntry>.unmodifiable(_entries);

  @override
  Future<void> remove(String id) async {
    _entries.removeWhere((OutboxEntry entry) => entry.id == id);
  }

  @override
  Future<void> reschedule(OutboxEntry entry, DateTime nextAttemptAt) async {
    final int index = _entries.indexWhere(
      (OutboxEntry row) => row.id == entry.id,
    );
    if (index < 0) {
      return;
    }
    // Re-read the stored row rather than writing [entry] back: the worker
    // holds a snapshot taken before the send, and a beat that coalesced onto
    // this entry while that send was in flight lives only in the stored row.
    // Writing the snapshot back would silently discard it. The Drift
    // implementation gets this for free by updating only the two columns.
    final OutboxEntry current = _entries[index];
    _entries[index] = current.withAttempt(
      attempts: current.attempts + 1,
      nextAttemptAt: nextAttemptAt,
    );
  }

  @override
  Future<void> clear() async => _entries.clear();
}

String _encodeIntervals(List<WatchInterval> intervals) => jsonEncode(
  intervals.map((WatchInterval interval) => interval.toJson()).toList(),
);

dynamic _decodeIntervals(String raw) {
  try {
    return jsonDecode(raw);
  } on FormatException {
    return const <dynamic>[];
  }
}

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((
  Ref ref,
) {
  final AppDatabase database = AppDatabase.onDevice();
  ref.onDispose(database.close);
  return database;
});

final Provider<OutboxStore> outboxStoreProvider = Provider<OutboxStore>(
  (Ref ref) => DriftOutboxStore(ref.watch(appDatabaseProvider)),
);
