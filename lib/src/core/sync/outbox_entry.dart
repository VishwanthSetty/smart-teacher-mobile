import 'package:flutter/foundation.dart';

import 'watch_interval.dart';

/// The kinds of write that go through the outbox (mobile plan §2.2).
///
/// Every mutating call in the learning-activity feature set is one of these.
/// Nothing writes straight to Dio — a screen that did would grow its own retry
/// policy, which is precisely the duplication the outbox exists to prevent.
enum OutboxKind {
  videoProgress('videoProgress'),
  documentProgress('docProgress'),
  documentComplete('docComplete'),
  documentUncomplete('docUncomplete'),
  bookmarkAdd('bookmarkAdd'),
  bookmarkRemove('bookmarkRemove'),

  /// `POST /me/notifications/:id/read` (mobile plan §2.2, §5.10).
  ///
  /// Outboxed for the same reason a bookmark toggle is: the row greys out the
  /// instant it is tapped, and the tap is usually immediately followed by a
  /// navigation away from the inbox — so the request must survive the screen
  /// that made it. The plan's coalescing rule for this kind is *dedupe*, which
  /// the merge key gives for free.
  notificationRead('notificationRead');

  const OutboxKind(this.wireValue);

  final String wireValue;

  static OutboxKind? fromWire(String value) {
    for (final OutboxKind kind in OutboxKind.values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// Which resource an entry is about. Two entries coalesce only when this
/// matches — progress on one video says nothing about another.
@immutable
class OutboxTarget {
  const OutboxTarget({required this.kind, required this.resourceId});

  final OutboxKind kind;
  final String resourceId;

  /// Entries for the same document coalesce across the complete/uncomplete
  /// pair, so those two share a merge key — and so do the bookmark add/remove
  /// pair, which is what collapses a double tap on the save button into one
  /// request instead of two that race (mobile plan §2.2).
  /// Progress kinds key on themselves.
  String get mergeKey => switch (kind) {
    OutboxKind.documentComplete ||
    OutboxKind.documentUncomplete => 'docCompletion:$resourceId',
    OutboxKind.bookmarkAdd ||
    OutboxKind.bookmarkRemove => 'bookmark:$resourceId',
    _ => '${kind.wireValue}:$resourceId',
  };

  @override
  bool operator ==(Object other) =>
      other is OutboxTarget &&
      other.kind == kind &&
      other.resourceId == resourceId;

  @override
  int get hashCode => Object.hash(kind, resourceId);
}

/// One pending write.
///
/// [clientUpdatedAt] is stamped **at the moment of the user action**, never at
/// send time (mobile plan §2.2). The server resolves `positionSecs` and
/// `lastPage` by last-write-wins on this field, so a timestamp taken when the
/// queue happens to drain would make a beat captured an hour ago look newer
/// than one captured a minute ago on another device — silently reordering the
/// user's own history.
@immutable
class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.target,
    required this.clientUpdatedAt,
    this.positionSecs,
    this.intervals = const <WatchInterval>[],
    this.lastPage,
    this.pageCount,
    this.resourceKind,
    this.bookmarkId,
    this.collectionId,
    this.attempts = 0,
    this.nextAttemptAt,
  });

  final String id;
  final OutboxTarget target;
  final DateTime clientUpdatedAt;

  /// Video only: where to resume.
  final int? positionSecs;

  /// Video only: the ranges played since the last **successful** flush.
  ///
  /// Never the full history — the server merges, so resending everything wastes
  /// bandwidth and can trip the wall-clock clamp that truncates a beat claiming
  /// more coverage than time has elapsed (backend plan §3.1).
  final List<WatchInterval> intervals;

  /// Document only.
  final int? lastPage;
  final int? pageCount;

  /// Bookmarks only: `VIDEO` or `DOCUMENT`, as `POST /me/bookmarks` spells it.
  /// A raw string because `core/` does not own the enum the feature parses.
  final String? resourceKind;

  /// Bookmarks only, and only on a **remove**: `DELETE /me/bookmarks/:id` takes
  /// the bookmark's own id, not the resource's.
  ///
  /// Null is meaningful rather than missing. A remove that coalesced onto a
  /// still-queued add has no server id because that add never reached the
  /// server — so the pair annihilates, and the transport sends nothing at all.
  final String? bookmarkId;

  /// Bookmarks only: which teacher collection to file the save into, if any.
  final String? collectionId;

  final int attempts;

  /// Backoff gate. An entry is invisible to the worker until this passes.
  final DateTime? nextAttemptAt;

  OutboxKind get kind => target.kind;

  String get resourceId => target.resourceId;

  bool isReady(DateTime now) =>
      nextAttemptAt == null || !nextAttemptAt!.isAfter(now);

  /// Folds [other] — which must be the newer entry — onto this one.
  ///
  /// The rules differ per kind because the server's conflict rules do
  /// (backend plan §7):
  ///
  /// * video progress unions the intervals (commutative, so nothing is lost)
  ///   and takes the newer `positionSecs`;
  /// * document progress keeps the newer `lastPage` only;
  /// * a complete/uncomplete pair is last-one-wins, so the newer entry simply
  ///   replaces the older — which is how an add-then-remove cancels out to one
  ///   request instead of two that race.
  ///
  /// Attempt counts reset: a coalesced entry is a new payload, and inheriting
  /// the older one's backoff would delay a write the user just made.
  OutboxEntry mergeWith(OutboxEntry other) {
    assert(
      other.target.mergeKey == target.mergeKey,
      'Only entries sharing a merge key may coalesce',
    );

    return switch (other.kind) {
      OutboxKind.videoProgress => OutboxEntry(
        id: id,
        target: target,
        clientUpdatedAt: _newerOf(clientUpdatedAt, other.clientUpdatedAt),
        positionSecs: other.clientUpdatedAt.isBefore(clientUpdatedAt)
            ? positionSecs
            : other.positionSecs,
        intervals: mergeWatchIntervals(<WatchInterval>[
          ...intervals,
          ...other.intervals,
        ]),
      ),
      OutboxKind.documentProgress => OutboxEntry(
        id: id,
        target: target,
        clientUpdatedAt: _newerOf(clientUpdatedAt, other.clientUpdatedAt),
        lastPage: other.clientUpdatedAt.isBefore(clientUpdatedAt)
            ? lastPage
            : other.lastPage,
        pageCount: other.pageCount ?? pageCount,
      ),
      // Last one wins, and it may be of the opposite kind — which is why the
      // target comes from `other` here and not from `this`.
      OutboxKind.documentComplete || OutboxKind.documentUncomplete =>
        OutboxEntry(
          id: id,
          target: other.target,
          clientUpdatedAt: other.clientUpdatedAt,
        ),
      // Same rule, and the same reason the id comes from `other` alone: a
      // remove folded onto a pending add inherits that add's *absent* server
      // id, which is exactly what makes the pair cancel out.
      OutboxKind.bookmarkAdd || OutboxKind.bookmarkRemove => OutboxEntry(
        id: id,
        target: other.target,
        clientUpdatedAt: other.clientUpdatedAt,
        resourceKind: other.resourceKind ?? resourceKind,
        bookmarkId: other.bookmarkId,
        collectionId: other.collectionId,
      ),
      // Dedupe, which is all the plan asks of this kind. Marking one
      // notification read twice is the same request twice, and the endpoint is
      // idempotent (`readAt: row.readAt ?? new Date()`), so the second adds
      // nothing but a round trip. The older entry's timestamp is kept: it is
      // when the user actually read it.
      OutboxKind.notificationRead => this,
    };
  }

  OutboxEntry withAttempt({required int attempts, DateTime? nextAttemptAt}) =>
      OutboxEntry(
        id: id,
        target: target,
        clientUpdatedAt: clientUpdatedAt,
        positionSecs: positionSecs,
        intervals: intervals,
        lastPage: lastPage,
        pageCount: pageCount,
        resourceKind: resourceKind,
        bookmarkId: bookmarkId,
        collectionId: collectionId,
        attempts: attempts,
        nextAttemptAt: nextAttemptAt,
      );

  /// The request body for this entry's endpoint.
  ///
  /// The completion kinds carry no body — they are a bare `POST`/`DELETE` — so
  /// they answer `null` rather than an empty map, which would send `{}` and
  /// invite a validation pipe to have an opinion about it.
  Map<String, dynamic>? toRequestBody() => switch (kind) {
    OutboxKind.videoProgress => <String, dynamic>{
      'positionSecs': positionSecs ?? 0,
      'intervals': intervals
          .map((WatchInterval interval) => interval.toJson())
          .toList(),
      'clientUpdatedAt': clientUpdatedAt.toUtc().toIso8601String(),
    },
    OutboxKind.documentProgress => <String, dynamic>{
      'lastPage': lastPage ?? 1,
      if (pageCount case final int count) 'pageCount': count,
      'clientUpdatedAt': clientUpdatedAt.toUtc().toIso8601String(),
    },
    OutboxKind.bookmarkAdd => <String, dynamic>{
      'resourceType': resourceKind ?? 'VIDEO',
      'resourceId': resourceId,
      if (collectionId case final String id) 'collectionId': id,
    },
    OutboxKind.documentComplete ||
    OutboxKind.documentUncomplete ||
    OutboxKind.bookmarkRemove ||
    OutboxKind.notificationRead => null,
  };

  @override
  String toString() =>
      'OutboxEntry(${kind.wireValue}, $resourceId, attempts: $attempts)';
}

DateTime _newerOf(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
