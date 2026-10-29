import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import 'local_activity.dart';
import 'outbox_store.dart';
import 'outbox_worker.dart';

/// The local mirror of the server's `ResourceActivity` (mobile plan §2.1).
///
/// An interface for the same reason as [OutboxStore]: the in-memory
/// implementation is what tests run against, so no test needs a native sqlite
/// binary to exercise resume or history-offline behaviour.
abstract interface class ActivityCacheStore {
  Future<LocalActivity?> read(String resourceId);

  /// Optimistic write — called the instant the player or reader moves.
  Future<void> write(LocalActivity activity);

  /// Every cached row, most recently accessed first.
  Future<List<LocalActivity>> recent({int limit});

  Future<void> clear();
}

class DriftActivityCacheStore implements ActivityCacheStore {
  DriftActivityCacheStore(this._db);

  final AppDatabase _db;

  @override
  Future<LocalActivity?> read(String resourceId) async {
    final CachedActivity? row =
        await (_db.select(_db.cachedActivities)..where(
              ($CachedActivitiesTable table) =>
                  table.resourceId.equals(resourceId),
            ))
            .getSingleOrNull();
    return row == null ? null : _toActivity(row);
  }

  @override
  Future<void> write(LocalActivity activity) async {
    // insertOnConflictUpdate, not insert: the same resource is written on
    // every beat, and the cache holds exactly one row per resource.
    await _db
        .into(_db.cachedActivities)
        .insertOnConflictUpdate(
          CachedActivitiesCompanion.insert(
            resourceId: activity.resourceId,
            resourceType: activity.resourceType,
            title: Value<String>(activity.title),
            status: activity.status,
            positionSecs: Value<int>(activity.positionSecs),
            percent: Value<int>(activity.percent),
            lastPage: Value<int?>(activity.lastPage),
            pageCount: Value<int?>(activity.pageCount),
            durationSecs: Value<int?>(activity.durationSecs),
            completedAt: Value<DateTime?>(activity.completedAt),
            lastAccessedAt: activity.lastAccessedAt,
            serverUpdatedAt: Value<DateTime?>(activity.serverUpdatedAt),
          ),
        );
  }

  @override
  Future<List<LocalActivity>> recent({int limit = 20}) async {
    return (_db.select(_db.cachedActivities)
          ..orderBy(<OrderClauseGenerator<$CachedActivitiesTable>>[
            ($CachedActivitiesTable table) =>
                OrderingTerm.desc(table.lastAccessedAt),
          ])
          ..limit(limit))
        .map(_toActivity)
        .get();
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.cachedActivities).go();
  }

  LocalActivity _toActivity(CachedActivity row) => LocalActivity(
    resourceId: row.resourceId,
    resourceType: row.resourceType,
    status: row.status,
    lastAccessedAt: row.lastAccessedAt,
    title: row.title,
    percent: row.percent,
    positionSecs: row.positionSecs,
    lastPage: row.lastPage,
    pageCount: row.pageCount,
    durationSecs: row.durationSecs,
    completedAt: row.completedAt,
    serverUpdatedAt: row.serverUpdatedAt,
  );
}

class InMemoryActivityCacheStore implements ActivityCacheStore {
  final Map<String, LocalActivity> _rows = <String, LocalActivity>{};

  @override
  Future<LocalActivity?> read(String resourceId) async => _rows[resourceId];

  @override
  Future<void> write(LocalActivity activity) async {
    _rows[activity.resourceId] = activity;
  }

  @override
  Future<List<LocalActivity>> recent({int limit = 20}) async {
    final List<LocalActivity> sorted = _rows.values.toList()
      ..sort(
        (LocalActivity a, LocalActivity b) =>
            b.lastAccessedAt.compareTo(a.lastAccessedAt),
      );
    return sorted.take(limit).toList();
  }

  @override
  Future<void> clear() async => _rows.clear();
}

/// Writes the server's answer back over the optimistic row.
///
/// This is the whole of the client's obligation in the conflict rules: the
/// server owns `status`, `percent` and `completedAt`, so whatever a flush
/// returns replaces what was guessed locally (mobile plan §2.3).
class ActivityCacheSyncSink implements OutboxSyncSink {
  const ActivityCacheSyncSink(this._cache);

  final ActivityCacheStore _cache;

  @override
  Future<void> onSynced(LocalActivity activity) => _cache.write(activity);
}

final Provider<ActivityCacheStore> activityCacheStoreProvider =
    Provider<ActivityCacheStore>(
      (Ref ref) => DriftActivityCacheStore(ref.watch(appDatabaseProvider)),
    );
