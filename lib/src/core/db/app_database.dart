import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Pending writes, durably (mobile plan §2.1).
///
/// A key-value store cannot back this: the worker selects by
/// `nextAttemptAt <= now` ordered by capture time, and deletes a flushed entry
/// in the same transaction that records its result. Both are indexed queries,
/// which is the stated reason the plan names Drift rather than preferences.
/// Named `OutboxRow` rather than `OutboxEntry` so the generated data class does
/// not collide with the domain type of the same name in `outbox_entry.dart`.
/// The row is the storage shape; [OutboxEntry] is what the worker reasons about.
@DataClassName('OutboxRow')
class OutboxRows extends Table {
  TextColumn get id => text()();

  /// [OutboxKind.wireValue]. Stored as its wire string rather than an index so
  /// reordering the enum cannot silently reinterpret a queued row after an app
  /// update — the queue outlives the build that wrote it.
  TextColumn get kind => text()();
  TextColumn get resourceId => text()();

  /// Stamped at the user action, not at send time. See [OutboxEntry].
  DateTimeColumn get clientUpdatedAt => dateTime()();

  IntColumn get positionSecs => integer().nullable()();

  /// Merged `[[start, end], …]` seconds, as JSON.
  TextColumn get intervalsJson => text().withDefault(const Constant('[]'))();

  IntColumn get lastPage => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();

  /// Bookmark kinds only. `resourceKind` is `VIDEO`/`DOCUMENT` as the bookmark
  /// endpoint spells it; `bookmarkId` is the row's own id, which only a *synced*
  /// save has (see [OutboxEntry.bookmarkId]).
  TextColumn get resourceKind => text().nullable()();
  TextColumn get bookmarkId => text().nullable()();
  TextColumn get collectionId => text().nullable()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  /// Insertion order, so the queue drains oldest-first and the cap below drops
  /// the oldest rather than the newest — a stale beat is the one worth losing.
  IntColumn get sequence => integer().autoIncrement()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{id},
  ];
}

/// Mirror of the server's `ResourceActivity` for resources this user touched.
///
/// Written **optimistically** the moment the player or reader moves, so the UI
/// never waits on the network, then overwritten wholesale by the server's
/// response on a successful flush. The server is authoritative for `status`,
/// `percent` and `completedAt`; this table is only ever authoritative for "what
/// just happened on this device" (mobile plan §2.3).
class CachedActivities extends Table {
  TextColumn get resourceId => text()();

  /// `VIDEO` or `DOCUMENT`, as the API spells it.
  TextColumn get resourceType => text()();
  TextColumn get title => text().withDefault(const Constant(''))();

  TextColumn get status => text()();
  IntColumn get positionSecs => integer().withDefault(const Constant(0))();
  IntColumn get percent => integer().withDefault(const Constant(0))();
  IntColumn get lastPage => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get durationSecs => integer().nullable()();

  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  /// The server's `updatedAt` as of the last successful sync, or null while the
  /// row is still only a local optimistic write. This is what the resume
  /// chooser compares against to tell "you watched this elsewhere" from "you
  /// watched this here a moment ago" (mobile plan §3).
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{resourceId};
}

@DriftDatabase(tables: <Type>[OutboxRows, CachedActivities])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The on-device database. Kept off the default constructor so tests can
  /// hand in an in-memory executor without touching path_provider, which has
  /// no implementation under `flutter test`.
  factory AppDatabase.onDevice() =>
      AppDatabase(LazyDatabase(() async => _openOnDevice()));

  @override
  int get schemaVersion => 2;

  /// v2 adds the three bookmark columns to [OutboxRows] (mobile plan §2.2).
  ///
  /// The queue is migrated rather than dropped: entries already in it are the
  /// user's own unsent writes, and the new columns are nullable, so a beat
  /// queued by a v1 build sends unchanged after the upgrade.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(outboxRows, outboxRows.resourceKind);
        await m.addColumn(outboxRows, outboxRows.bookmarkId);
        await m.addColumn(outboxRows, outboxRows.collectionId);
      }
    },
  );

  /// Everything here is a cache or a queue of the signed-in user's own writes,
  /// so it must not survive a sign-out into the next session (mobile plan §0:
  /// never cache a resource list past logout).
  Future<void> clearForSignOut() async {
    await batch((Batch batch) {
      batch.deleteAll(outboxRows);
      batch.deleteAll(cachedActivities);
    });
  }
}

Future<QueryExecutor> _openOnDevice() async {
  final Directory directory = await getApplicationSupportDirectory();
  return NativeDatabase.createInBackground(
    File(p.join(directory.path, 'smart_teacher_activity.sqlite')),
  );
}
