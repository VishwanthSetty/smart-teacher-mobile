import 'package:flutter/foundation.dart';

/// The locally-cached view of one resource's progress (mobile plan §2.1).
///
/// Deliberately a plain `core/` type rather than the activity feature's
/// entity: the outbox worker and the Drift cache both handle it, and neither
/// may import a feature. The feature converts at its own boundary.
///
/// Two sources write this. An **optimistic** write happens the moment the
/// player or reader moves, so the UI never waits on the network, and carries
/// no [serverUpdatedAt]. A **reconciling** write happens when a flush
/// succeeds, carries the server's `updatedAt`, and overwrites the optimistic
/// one wholesale — the server is authoritative for [status], [percent] and
/// [completedAt], and the client only ever for "what just happened here".
@immutable
class LocalActivity {
  const LocalActivity({
    required this.resourceId,
    required this.resourceType,
    required this.status,
    required this.lastAccessedAt,
    this.title = '',
    this.percent = 0,
    this.positionSecs = 0,
    this.lastPage,
    this.pageCount,
    this.durationSecs,
    this.completedAt,
    this.serverUpdatedAt,
  });

  final String resourceId;

  /// `VIDEO` or `DOCUMENT`, as the API spells it. A raw string because `core/`
  /// does not own the enum the feature parses this into.
  final String resourceType;

  /// `IN_PROGRESS` or `COMPLETED`. `NOT_STARTED` is never stored — server-side
  /// the absence of a row *is* not-started, and mirroring that keeps the local
  /// table proportional to real activity too.
  final String status;

  final DateTime lastAccessedAt;
  final String title;
  final int percent;
  final int positionSecs;
  final int? lastPage;
  final int? pageCount;
  final int? durationSecs;
  final DateTime? completedAt;

  /// The server's `updatedAt` as of the last successful sync, or null while
  /// this is still only an optimistic local write.
  ///
  /// This is what separates "you watched this on another device" from "you
  /// watched this here a second ago" for the resume chooser (mobile plan §3).
  final DateTime? serverUpdatedAt;

  bool get isSynced => serverUpdatedAt != null;

  LocalActivity copyWith({
    String? status,
    int? percent,
    int? positionSecs,
    int? lastPage,
    int? pageCount,
    DateTime? lastAccessedAt,
    DateTime? serverUpdatedAt,
  }) => LocalActivity(
    resourceId: resourceId,
    resourceType: resourceType,
    status: status ?? this.status,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    title: title,
    percent: percent ?? this.percent,
    positionSecs: positionSecs ?? this.positionSecs,
    lastPage: lastPage ?? this.lastPage,
    pageCount: pageCount ?? this.pageCount,
    durationSecs: durationSecs,
    completedAt: completedAt,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is LocalActivity &&
      other.resourceId == resourceId &&
      other.resourceType == resourceType &&
      other.status == status &&
      other.percent == percent &&
      other.positionSecs == positionSecs &&
      other.lastPage == lastPage &&
      other.pageCount == pageCount &&
      other.durationSecs == durationSecs &&
      other.title == title &&
      other.completedAt == completedAt &&
      other.lastAccessedAt == lastAccessedAt &&
      other.serverUpdatedAt == serverUpdatedAt;

  @override
  int get hashCode => Object.hash(
    resourceId,
    resourceType,
    status,
    percent,
    positionSecs,
    lastPage,
    pageCount,
    durationSecs,
    title,
    completedAt,
    lastAccessedAt,
    serverUpdatedAt,
  );

  @override
  String toString() =>
      'LocalActivity($resourceId, $status, $percent%, synced: $isSynced)';
}
