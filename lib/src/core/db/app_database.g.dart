// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OutboxRowsTable extends OutboxRows
    with TableInfo<$OutboxRowsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientUpdatedAt =
      GeneratedColumn<DateTime>(
        'client_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _positionSecsMeta = const VerificationMeta(
    'positionSecs',
  );
  @override
  late final GeneratedColumn<int> positionSecs = GeneratedColumn<int>(
    'position_secs',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalsJsonMeta = const VerificationMeta(
    'intervalsJson',
  );
  @override
  late final GeneratedColumn<String> intervalsJson = GeneratedColumn<String>(
    'intervals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceKindMeta = const VerificationMeta(
    'resourceKind',
  );
  @override
  late final GeneratedColumn<String> resourceKind = GeneratedColumn<String>(
    'resource_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookmarkIdMeta = const VerificationMeta(
    'bookmarkId',
  );
  @override
  late final GeneratedColumn<String> bookmarkId = GeneratedColumn<String>(
    'bookmark_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    resourceId,
    clientUpdatedAt,
    positionSecs,
    intervalsJson,
    lastPage,
    pageCount,
    resourceKind,
    bookmarkId,
    collectionId,
    attempts,
    nextAttemptAt,
    sequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientUpdatedAtMeta);
    }
    if (data.containsKey('position_secs')) {
      context.handle(
        _positionSecsMeta,
        positionSecs.isAcceptableOrUnknown(
          data['position_secs']!,
          _positionSecsMeta,
        ),
      );
    }
    if (data.containsKey('intervals_json')) {
      context.handle(
        _intervalsJsonMeta,
        intervalsJson.isAcceptableOrUnknown(
          data['intervals_json']!,
          _intervalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('resource_kind')) {
      context.handle(
        _resourceKindMeta,
        resourceKind.isAcceptableOrUnknown(
          data['resource_kind']!,
          _resourceKindMeta,
        ),
      );
    }
    if (data.containsKey('bookmark_id')) {
      context.handle(
        _bookmarkIdMeta,
        bookmarkId.isAcceptableOrUnknown(data['bookmark_id']!, _bookmarkIdMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequence};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id},
  ];
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_updated_at'],
      )!,
      positionSecs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_secs'],
      ),
      intervalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intervals_json'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      resourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_kind'],
      ),
      bookmarkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bookmark_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $OutboxRowsTable createAlias(String alias) {
    return $OutboxRowsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String id;

  /// [OutboxKind.wireValue]. Stored as its wire string rather than an index so
  /// reordering the enum cannot silently reinterpret a queued row after an app
  /// update — the queue outlives the build that wrote it.
  final String kind;
  final String resourceId;

  /// Stamped at the user action, not at send time. See [OutboxEntry].
  final DateTime clientUpdatedAt;
  final int? positionSecs;

  /// Merged `[[start, end], …]` seconds, as JSON.
  final String intervalsJson;
  final int? lastPage;
  final int? pageCount;

  /// Bookmark kinds only. `resourceKind` is `VIDEO`/`DOCUMENT` as the bookmark
  /// endpoint spells it; `bookmarkId` is the row's own id, which only a *synced*
  /// save has (see [OutboxEntry.bookmarkId]).
  final String? resourceKind;
  final String? bookmarkId;
  final String? collectionId;
  final int attempts;
  final DateTime? nextAttemptAt;

  /// Insertion order, so the queue drains oldest-first and the cap below drops
  /// the oldest rather than the newest — a stale beat is the one worth losing.
  final int sequence;
  const OutboxRow({
    required this.id,
    required this.kind,
    required this.resourceId,
    required this.clientUpdatedAt,
    this.positionSecs,
    required this.intervalsJson,
    this.lastPage,
    this.pageCount,
    this.resourceKind,
    this.bookmarkId,
    this.collectionId,
    required this.attempts,
    this.nextAttemptAt,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['resource_id'] = Variable<String>(resourceId);
    map['client_updated_at'] = Variable<DateTime>(clientUpdatedAt);
    if (!nullToAbsent || positionSecs != null) {
      map['position_secs'] = Variable<int>(positionSecs);
    }
    map['intervals_json'] = Variable<String>(intervalsJson);
    if (!nullToAbsent || lastPage != null) {
      map['last_page'] = Variable<int>(lastPage);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || resourceKind != null) {
      map['resource_kind'] = Variable<String>(resourceKind);
    }
    if (!nullToAbsent || bookmarkId != null) {
      map['bookmark_id'] = Variable<String>(bookmarkId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  OutboxRowsCompanion toCompanion(bool nullToAbsent) {
    return OutboxRowsCompanion(
      id: Value(id),
      kind: Value(kind),
      resourceId: Value(resourceId),
      clientUpdatedAt: Value(clientUpdatedAt),
      positionSecs: positionSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(positionSecs),
      intervalsJson: Value(intervalsJson),
      lastPage: lastPage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPage),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      resourceKind: resourceKind == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceKind),
      bookmarkId: bookmarkId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      sequence: Value(sequence),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      clientUpdatedAt: serializer.fromJson<DateTime>(json['clientUpdatedAt']),
      positionSecs: serializer.fromJson<int?>(json['positionSecs']),
      intervalsJson: serializer.fromJson<String>(json['intervalsJson']),
      lastPage: serializer.fromJson<int?>(json['lastPage']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      resourceKind: serializer.fromJson<String?>(json['resourceKind']),
      bookmarkId: serializer.fromJson<String?>(json['bookmarkId']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'resourceId': serializer.toJson<String>(resourceId),
      'clientUpdatedAt': serializer.toJson<DateTime>(clientUpdatedAt),
      'positionSecs': serializer.toJson<int?>(positionSecs),
      'intervalsJson': serializer.toJson<String>(intervalsJson),
      'lastPage': serializer.toJson<int?>(lastPage),
      'pageCount': serializer.toJson<int?>(pageCount),
      'resourceKind': serializer.toJson<String?>(resourceKind),
      'bookmarkId': serializer.toJson<String?>(bookmarkId),
      'collectionId': serializer.toJson<String?>(collectionId),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  OutboxRow copyWith({
    String? id,
    String? kind,
    String? resourceId,
    DateTime? clientUpdatedAt,
    Value<int?> positionSecs = const Value.absent(),
    String? intervalsJson,
    Value<int?> lastPage = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> resourceKind = const Value.absent(),
    Value<String?> bookmarkId = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    int? sequence,
  }) => OutboxRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    resourceId: resourceId ?? this.resourceId,
    clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
    positionSecs: positionSecs.present ? positionSecs.value : this.positionSecs,
    intervalsJson: intervalsJson ?? this.intervalsJson,
    lastPage: lastPage.present ? lastPage.value : this.lastPage,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    resourceKind: resourceKind.present ? resourceKind.value : this.resourceKind,
    bookmarkId: bookmarkId.present ? bookmarkId.value : this.bookmarkId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    sequence: sequence ?? this.sequence,
  );
  OutboxRow copyWithCompanion(OutboxRowsCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      positionSecs: data.positionSecs.present
          ? data.positionSecs.value
          : this.positionSecs,
      intervalsJson: data.intervalsJson.present
          ? data.intervalsJson.value
          : this.intervalsJson,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      resourceKind: data.resourceKind.present
          ? data.resourceKind.value
          : this.resourceKind,
      bookmarkId: data.bookmarkId.present
          ? data.bookmarkId.value
          : this.bookmarkId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('resourceId: $resourceId, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('positionSecs: $positionSecs, ')
          ..write('intervalsJson: $intervalsJson, ')
          ..write('lastPage: $lastPage, ')
          ..write('pageCount: $pageCount, ')
          ..write('resourceKind: $resourceKind, ')
          ..write('bookmarkId: $bookmarkId, ')
          ..write('collectionId: $collectionId, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    resourceId,
    clientUpdatedAt,
    positionSecs,
    intervalsJson,
    lastPage,
    pageCount,
    resourceKind,
    bookmarkId,
    collectionId,
    attempts,
    nextAttemptAt,
    sequence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.resourceId == this.resourceId &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.positionSecs == this.positionSecs &&
          other.intervalsJson == this.intervalsJson &&
          other.lastPage == this.lastPage &&
          other.pageCount == this.pageCount &&
          other.resourceKind == this.resourceKind &&
          other.bookmarkId == this.bookmarkId &&
          other.collectionId == this.collectionId &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.sequence == this.sequence);
}

class OutboxRowsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> resourceId;
  final Value<DateTime> clientUpdatedAt;
  final Value<int?> positionSecs;
  final Value<String> intervalsJson;
  final Value<int?> lastPage;
  final Value<int?> pageCount;
  final Value<String?> resourceKind;
  final Value<String?> bookmarkId;
  final Value<String?> collectionId;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<int> sequence;
  const OutboxRowsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.positionSecs = const Value.absent(),
    this.intervalsJson = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.resourceKind = const Value.absent(),
    this.bookmarkId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.sequence = const Value.absent(),
  });
  OutboxRowsCompanion.insert({
    required String id,
    required String kind,
    required String resourceId,
    required DateTime clientUpdatedAt,
    this.positionSecs = const Value.absent(),
    this.intervalsJson = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.resourceKind = const Value.absent(),
    this.bookmarkId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.sequence = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       resourceId = Value(resourceId),
       clientUpdatedAt = Value(clientUpdatedAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? resourceId,
    Expression<DateTime>? clientUpdatedAt,
    Expression<int>? positionSecs,
    Expression<String>? intervalsJson,
    Expression<int>? lastPage,
    Expression<int>? pageCount,
    Expression<String>? resourceKind,
    Expression<String>? bookmarkId,
    Expression<String>? collectionId,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? sequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (resourceId != null) 'resource_id': resourceId,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (positionSecs != null) 'position_secs': positionSecs,
      if (intervalsJson != null) 'intervals_json': intervalsJson,
      if (lastPage != null) 'last_page': lastPage,
      if (pageCount != null) 'page_count': pageCount,
      if (resourceKind != null) 'resource_kind': resourceKind,
      if (bookmarkId != null) 'bookmark_id': bookmarkId,
      if (collectionId != null) 'collection_id': collectionId,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (sequence != null) 'sequence': sequence,
    });
  }

  OutboxRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? resourceId,
    Value<DateTime>? clientUpdatedAt,
    Value<int?>? positionSecs,
    Value<String>? intervalsJson,
    Value<int?>? lastPage,
    Value<int?>? pageCount,
    Value<String?>? resourceKind,
    Value<String?>? bookmarkId,
    Value<String?>? collectionId,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<int>? sequence,
  }) {
    return OutboxRowsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      resourceId: resourceId ?? this.resourceId,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      positionSecs: positionSecs ?? this.positionSecs,
      intervalsJson: intervalsJson ?? this.intervalsJson,
      lastPage: lastPage ?? this.lastPage,
      pageCount: pageCount ?? this.pageCount,
      resourceKind: resourceKind ?? this.resourceKind,
      bookmarkId: bookmarkId ?? this.bookmarkId,
      collectionId: collectionId ?? this.collectionId,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<DateTime>(clientUpdatedAt.value);
    }
    if (positionSecs.present) {
      map['position_secs'] = Variable<int>(positionSecs.value);
    }
    if (intervalsJson.present) {
      map['intervals_json'] = Variable<String>(intervalsJson.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (resourceKind.present) {
      map['resource_kind'] = Variable<String>(resourceKind.value);
    }
    if (bookmarkId.present) {
      map['bookmark_id'] = Variable<String>(bookmarkId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRowsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('resourceId: $resourceId, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('positionSecs: $positionSecs, ')
          ..write('intervalsJson: $intervalsJson, ')
          ..write('lastPage: $lastPage, ')
          ..write('pageCount: $pageCount, ')
          ..write('resourceKind: $resourceKind, ')
          ..write('bookmarkId: $bookmarkId, ')
          ..write('collectionId: $collectionId, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }
}

class $CachedActivitiesTable extends CachedActivities
    with TableInfo<$CachedActivitiesTable, CachedActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceTypeMeta = const VerificationMeta(
    'resourceType',
  );
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
    'resource_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionSecsMeta = const VerificationMeta(
    'positionSecs',
  );
  @override
  late final GeneratedColumn<int> positionSecs = GeneratedColumn<int>(
    'position_secs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<int> percent = GeneratedColumn<int>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecsMeta = const VerificationMeta(
    'durationSecs',
  );
  @override
  late final GeneratedColumn<int> durationSecs = GeneratedColumn<int>(
    'duration_secs',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    resourceId,
    resourceType,
    title,
    status,
    positionSecs,
    percent,
    lastPage,
    pageCount,
    durationSecs,
    completedAt,
    lastAccessedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('resource_type')) {
      context.handle(
        _resourceTypeMeta,
        resourceType.isAcceptableOrUnknown(
          data['resource_type']!,
          _resourceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('position_secs')) {
      context.handle(
        _positionSecsMeta,
        positionSecs.isAcceptableOrUnknown(
          data['position_secs']!,
          _positionSecsMeta,
        ),
      );
    }
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('duration_secs')) {
      context.handle(
        _durationSecsMeta,
        durationSecs.isAcceptableOrUnknown(
          data['duration_secs']!,
          _durationSecsMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceId};
  @override
  CachedActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedActivity(
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      resourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      positionSecs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_secs'],
      )!,
      percent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percent'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      durationSecs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_secs'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $CachedActivitiesTable createAlias(String alias) {
    return $CachedActivitiesTable(attachedDatabase, alias);
  }
}

class CachedActivity extends DataClass implements Insertable<CachedActivity> {
  final String resourceId;

  /// `VIDEO` or `DOCUMENT`, as the API spells it.
  final String resourceType;
  final String title;
  final String status;
  final int positionSecs;
  final int percent;
  final int? lastPage;
  final int? pageCount;
  final int? durationSecs;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;

  /// The server's `updatedAt` as of the last successful sync, or null while the
  /// row is still only a local optimistic write. This is what the resume
  /// chooser compares against to tell "you watched this elsewhere" from "you
  /// watched this here a moment ago" (mobile plan §3).
  final DateTime? serverUpdatedAt;
  const CachedActivity({
    required this.resourceId,
    required this.resourceType,
    required this.title,
    required this.status,
    required this.positionSecs,
    required this.percent,
    this.lastPage,
    this.pageCount,
    this.durationSecs,
    this.completedAt,
    required this.lastAccessedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_id'] = Variable<String>(resourceId);
    map['resource_type'] = Variable<String>(resourceType);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['position_secs'] = Variable<int>(positionSecs);
    map['percent'] = Variable<int>(percent);
    if (!nullToAbsent || lastPage != null) {
      map['last_page'] = Variable<int>(lastPage);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || durationSecs != null) {
      map['duration_secs'] = Variable<int>(durationSecs);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    return map;
  }

  CachedActivitiesCompanion toCompanion(bool nullToAbsent) {
    return CachedActivitiesCompanion(
      resourceId: Value(resourceId),
      resourceType: Value(resourceType),
      title: Value(title),
      status: Value(status),
      positionSecs: Value(positionSecs),
      percent: Value(percent),
      lastPage: lastPage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPage),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      durationSecs: durationSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSecs),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      lastAccessedAt: Value(lastAccessedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory CachedActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedActivity(
      resourceId: serializer.fromJson<String>(json['resourceId']),
      resourceType: serializer.fromJson<String>(json['resourceType']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      positionSecs: serializer.fromJson<int>(json['positionSecs']),
      percent: serializer.fromJson<int>(json['percent']),
      lastPage: serializer.fromJson<int?>(json['lastPage']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      durationSecs: serializer.fromJson<int?>(json['durationSecs']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceId': serializer.toJson<String>(resourceId),
      'resourceType': serializer.toJson<String>(resourceType),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'positionSecs': serializer.toJson<int>(positionSecs),
      'percent': serializer.toJson<int>(percent),
      'lastPage': serializer.toJson<int?>(lastPage),
      'pageCount': serializer.toJson<int?>(pageCount),
      'durationSecs': serializer.toJson<int?>(durationSecs),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
    };
  }

  CachedActivity copyWith({
    String? resourceId,
    String? resourceType,
    String? title,
    String? status,
    int? positionSecs,
    int? percent,
    Value<int?> lastPage = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<int?> durationSecs = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? lastAccessedAt,
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
  }) => CachedActivity(
    resourceId: resourceId ?? this.resourceId,
    resourceType: resourceType ?? this.resourceType,
    title: title ?? this.title,
    status: status ?? this.status,
    positionSecs: positionSecs ?? this.positionSecs,
    percent: percent ?? this.percent,
    lastPage: lastPage.present ? lastPage.value : this.lastPage,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    durationSecs: durationSecs.present ? durationSecs.value : this.durationSecs,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  CachedActivity copyWithCompanion(CachedActivitiesCompanion data) {
    return CachedActivity(
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      positionSecs: data.positionSecs.present
          ? data.positionSecs.value
          : this.positionSecs,
      percent: data.percent.present ? data.percent.value : this.percent,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      durationSecs: data.durationSecs.present
          ? data.durationSecs.value
          : this.durationSecs,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedActivity(')
          ..write('resourceId: $resourceId, ')
          ..write('resourceType: $resourceType, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('positionSecs: $positionSecs, ')
          ..write('percent: $percent, ')
          ..write('lastPage: $lastPage, ')
          ..write('pageCount: $pageCount, ')
          ..write('durationSecs: $durationSecs, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resourceId,
    resourceType,
    title,
    status,
    positionSecs,
    percent,
    lastPage,
    pageCount,
    durationSecs,
    completedAt,
    lastAccessedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedActivity &&
          other.resourceId == this.resourceId &&
          other.resourceType == this.resourceType &&
          other.title == this.title &&
          other.status == this.status &&
          other.positionSecs == this.positionSecs &&
          other.percent == this.percent &&
          other.lastPage == this.lastPage &&
          other.pageCount == this.pageCount &&
          other.durationSecs == this.durationSecs &&
          other.completedAt == this.completedAt &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class CachedActivitiesCompanion extends UpdateCompanion<CachedActivity> {
  final Value<String> resourceId;
  final Value<String> resourceType;
  final Value<String> title;
  final Value<String> status;
  final Value<int> positionSecs;
  final Value<int> percent;
  final Value<int?> lastPage;
  final Value<int?> pageCount;
  final Value<int?> durationSecs;
  final Value<DateTime?> completedAt;
  final Value<DateTime> lastAccessedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<int> rowid;
  const CachedActivitiesCompanion({
    this.resourceId = const Value.absent(),
    this.resourceType = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.positionSecs = const Value.absent(),
    this.percent = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.durationSecs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedActivitiesCompanion.insert({
    required String resourceId,
    required String resourceType,
    this.title = const Value.absent(),
    required String status,
    this.positionSecs = const Value.absent(),
    this.percent = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.durationSecs = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime lastAccessedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : resourceId = Value(resourceId),
       resourceType = Value(resourceType),
       status = Value(status),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<CachedActivity> custom({
    Expression<String>? resourceId,
    Expression<String>? resourceType,
    Expression<String>? title,
    Expression<String>? status,
    Expression<int>? positionSecs,
    Expression<int>? percent,
    Expression<int>? lastPage,
    Expression<int>? pageCount,
    Expression<int>? durationSecs,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceId != null) 'resource_id': resourceId,
      if (resourceType != null) 'resource_type': resourceType,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (positionSecs != null) 'position_secs': positionSecs,
      if (percent != null) 'percent': percent,
      if (lastPage != null) 'last_page': lastPage,
      if (pageCount != null) 'page_count': pageCount,
      if (durationSecs != null) 'duration_secs': durationSecs,
      if (completedAt != null) 'completed_at': completedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedActivitiesCompanion copyWith({
    Value<String>? resourceId,
    Value<String>? resourceType,
    Value<String>? title,
    Value<String>? status,
    Value<int>? positionSecs,
    Value<int>? percent,
    Value<int?>? lastPage,
    Value<int?>? pageCount,
    Value<int?>? durationSecs,
    Value<DateTime?>? completedAt,
    Value<DateTime>? lastAccessedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return CachedActivitiesCompanion(
      resourceId: resourceId ?? this.resourceId,
      resourceType: resourceType ?? this.resourceType,
      title: title ?? this.title,
      status: status ?? this.status,
      positionSecs: positionSecs ?? this.positionSecs,
      percent: percent ?? this.percent,
      lastPage: lastPage ?? this.lastPage,
      pageCount: pageCount ?? this.pageCount,
      durationSecs: durationSecs ?? this.durationSecs,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (positionSecs.present) {
      map['position_secs'] = Variable<int>(positionSecs.value);
    }
    if (percent.present) {
      map['percent'] = Variable<int>(percent.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (durationSecs.present) {
      map['duration_secs'] = Variable<int>(durationSecs.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedActivitiesCompanion(')
          ..write('resourceId: $resourceId, ')
          ..write('resourceType: $resourceType, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('positionSecs: $positionSecs, ')
          ..write('percent: $percent, ')
          ..write('lastPage: $lastPage, ')
          ..write('pageCount: $pageCount, ')
          ..write('durationSecs: $durationSecs, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxRowsTable outboxRows = $OutboxRowsTable(this);
  late final $CachedActivitiesTable cachedActivities = $CachedActivitiesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    outboxRows,
    cachedActivities,
  ];
}

typedef $$OutboxRowsTableCreateCompanionBuilder =
    OutboxRowsCompanion Function({
      required String id,
      required String kind,
      required String resourceId,
      required DateTime clientUpdatedAt,
      Value<int?> positionSecs,
      Value<String> intervalsJson,
      Value<int?> lastPage,
      Value<int?> pageCount,
      Value<String?> resourceKind,
      Value<String?> bookmarkId,
      Value<String?> collectionId,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<int> sequence,
    });
typedef $$OutboxRowsTableUpdateCompanionBuilder =
    OutboxRowsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> resourceId,
      Value<DateTime> clientUpdatedAt,
      Value<int?> positionSecs,
      Value<String> intervalsJson,
      Value<int?> lastPage,
      Value<int?> pageCount,
      Value<String?> resourceKind,
      Value<String?> bookmarkId,
      Value<String?> collectionId,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<int> sequence,
    });

class $$OutboxRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxRowsTable> {
  $$OutboxRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionSecs => $composableBuilder(
    column: $table.positionSecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalsJson => $composableBuilder(
    column: $table.intervalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceKind => $composableBuilder(
    column: $table.resourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookmarkId => $composableBuilder(
    column: $table.bookmarkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxRowsTable> {
  $$OutboxRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionSecs => $composableBuilder(
    column: $table.positionSecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalsJson => $composableBuilder(
    column: $table.intervalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceKind => $composableBuilder(
    column: $table.resourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookmarkId => $composableBuilder(
    column: $table.bookmarkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxRowsTable> {
  $$OutboxRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionSecs => $composableBuilder(
    column: $table.positionSecs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervalsJson => $composableBuilder(
    column: $table.intervalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get resourceKind => $composableBuilder(
    column: $table.resourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookmarkId => $composableBuilder(
    column: $table.bookmarkId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);
}

class $$OutboxRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxRowsTable,
          OutboxRow,
          $$OutboxRowsTableFilterComposer,
          $$OutboxRowsTableOrderingComposer,
          $$OutboxRowsTableAnnotationComposer,
          $$OutboxRowsTableCreateCompanionBuilder,
          $$OutboxRowsTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$AppDatabase, $OutboxRowsTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxRowsTableTableManager(_$AppDatabase db, $OutboxRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<DateTime> clientUpdatedAt = const Value.absent(),
                Value<int?> positionSecs = const Value.absent(),
                Value<String> intervalsJson = const Value.absent(),
                Value<int?> lastPage = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> resourceKind = const Value.absent(),
                Value<String?> bookmarkId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> sequence = const Value.absent(),
              }) => OutboxRowsCompanion(
                id: id,
                kind: kind,
                resourceId: resourceId,
                clientUpdatedAt: clientUpdatedAt,
                positionSecs: positionSecs,
                intervalsJson: intervalsJson,
                lastPage: lastPage,
                pageCount: pageCount,
                resourceKind: resourceKind,
                bookmarkId: bookmarkId,
                collectionId: collectionId,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                sequence: sequence,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String resourceId,
                required DateTime clientUpdatedAt,
                Value<int?> positionSecs = const Value.absent(),
                Value<String> intervalsJson = const Value.absent(),
                Value<int?> lastPage = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> resourceKind = const Value.absent(),
                Value<String?> bookmarkId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> sequence = const Value.absent(),
              }) => OutboxRowsCompanion.insert(
                id: id,
                kind: kind,
                resourceId: resourceId,
                clientUpdatedAt: clientUpdatedAt,
                positionSecs: positionSecs,
                intervalsJson: intervalsJson,
                lastPage: lastPage,
                pageCount: pageCount,
                resourceKind: resourceKind,
                bookmarkId: bookmarkId,
                collectionId: collectionId,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                sequence: sequence,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxRowsTable,
      OutboxRow,
      $$OutboxRowsTableFilterComposer,
      $$OutboxRowsTableOrderingComposer,
      $$OutboxRowsTableAnnotationComposer,
      $$OutboxRowsTableCreateCompanionBuilder,
      $$OutboxRowsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxRowsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$CachedActivitiesTableCreateCompanionBuilder =
    CachedActivitiesCompanion Function({
      required String resourceId,
      required String resourceType,
      Value<String> title,
      required String status,
      Value<int> positionSecs,
      Value<int> percent,
      Value<int?> lastPage,
      Value<int?> pageCount,
      Value<int?> durationSecs,
      Value<DateTime?> completedAt,
      required DateTime lastAccessedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$CachedActivitiesTableUpdateCompanionBuilder =
    CachedActivitiesCompanion Function({
      Value<String> resourceId,
      Value<String> resourceType,
      Value<String> title,
      Value<String> status,
      Value<int> positionSecs,
      Value<int> percent,
      Value<int?> lastPage,
      Value<int?> pageCount,
      Value<int?> durationSecs,
      Value<DateTime?> completedAt,
      Value<DateTime> lastAccessedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$CachedActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedActivitiesTable> {
  $$CachedActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionSecs => $composableBuilder(
    column: $table.positionSecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedActivitiesTable> {
  $$CachedActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionSecs => $composableBuilder(
    column: $table.positionSecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedActivitiesTable> {
  $$CachedActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get positionSecs => $composableBuilder(
    column: $table.positionSecs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$CachedActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedActivitiesTable,
          CachedActivity,
          $$CachedActivitiesTableFilterComposer,
          $$CachedActivitiesTableOrderingComposer,
          $$CachedActivitiesTableAnnotationComposer,
          $$CachedActivitiesTableCreateCompanionBuilder,
          $$CachedActivitiesTableUpdateCompanionBuilder,
          (
            CachedActivity,
            BaseReferences<
              _$AppDatabase,
              $CachedActivitiesTable,
              CachedActivity
            >,
          ),
          CachedActivity,
          PrefetchHooks Function()
        > {
  $$CachedActivitiesTableTableManager(
    _$AppDatabase db,
    $CachedActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> resourceId = const Value.absent(),
                Value<String> resourceType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> positionSecs = const Value.absent(),
                Value<int> percent = const Value.absent(),
                Value<int?> lastPage = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> durationSecs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedActivitiesCompanion(
                resourceId: resourceId,
                resourceType: resourceType,
                title: title,
                status: status,
                positionSecs: positionSecs,
                percent: percent,
                lastPage: lastPage,
                pageCount: pageCount,
                durationSecs: durationSecs,
                completedAt: completedAt,
                lastAccessedAt: lastAccessedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String resourceId,
                required String resourceType,
                Value<String> title = const Value.absent(),
                required String status,
                Value<int> positionSecs = const Value.absent(),
                Value<int> percent = const Value.absent(),
                Value<int?> lastPage = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> durationSecs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime lastAccessedAt,
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedActivitiesCompanion.insert(
                resourceId: resourceId,
                resourceType: resourceType,
                title: title,
                status: status,
                positionSecs: positionSecs,
                percent: percent,
                lastPage: lastPage,
                pageCount: pageCount,
                durationSecs: durationSecs,
                completedAt: completedAt,
                lastAccessedAt: lastAccessedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedActivitiesTable,
      CachedActivity,
      $$CachedActivitiesTableFilterComposer,
      $$CachedActivitiesTableOrderingComposer,
      $$CachedActivitiesTableAnnotationComposer,
      $$CachedActivitiesTableCreateCompanionBuilder,
      $$CachedActivitiesTableUpdateCompanionBuilder,
      (
        CachedActivity,
        BaseReferences<_$AppDatabase, $CachedActivitiesTable, CachedActivity>,
      ),
      CachedActivity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxRowsTableTableManager get outboxRows =>
      $$OutboxRowsTableTableManager(_db, _db.outboxRows);
  $$CachedActivitiesTableTableManager get cachedActivities =>
      $$CachedActivitiesTableTableManager(_db, _db.cachedActivities);
}
