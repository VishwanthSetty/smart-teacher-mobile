import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/sync/local_activity.dart';

part 'resource_activity_entity.freezed.dart';
part 'resource_activity_entity.g.dart';

/// Which kind of resource an activity row is about (backend plan §1.1).
///
/// [unknown] is the usual fallback so a type added later cannot fail a whole
/// page of history.
enum ActivityResourceType {
  @JsonValue('VIDEO')
  video,

  @JsonValue('DOCUMENT')
  document,

  unknown;

  /// What `GET /me/activity?type=` takes. `null` for [unknown] — never send a
  /// filter value that didn't come from the server.
  String? get wireValue => switch (this) {
    ActivityResourceType.video => 'VIDEO',
    ActivityResourceType.document => 'DOCUMENT',
    ActivityResourceType.unknown => null,
  };
}

/// Progress status (backend plan §1.1).
///
/// `NOT_STARTED` exists in the enum but **is never persisted server-side** —
/// the absence of a row *is* not-started. It is modelled anyway because
/// `TaskAssignment.status` does store it and the progress summary reports it
/// as a computed count.
enum ActivityProgressStatus {
  @JsonValue('NOT_STARTED')
  notStarted,

  @JsonValue('IN_PROGRESS')
  inProgress,

  @JsonValue('COMPLETED')
  completed,

  unknown;

  String? get wireValue => switch (this) {
    ActivityProgressStatus.notStarted => 'NOT_STARTED',
    ActivityProgressStatus.inProgress => 'IN_PROGRESS',
    ActivityProgressStatus.completed => 'COMPLETED',
    ActivityProgressStatus.unknown => null,
  };

  /// The chip wording on a history row. [notStarted] has none: a row only
  /// exists because something happened, so the label would never be true.
  String? get label => switch (this) {
    ActivityProgressStatus.inProgress => 'In progress',
    ActivityProgressStatus.completed => 'Completed',
    ActivityProgressStatus.notStarted ||
    ActivityProgressStatus.unknown => null,
  };
}

/// The nested `video` of an activity row.
@freezed
abstract class ActivityVideoEntity with _$ActivityVideoEntity {
  const factory ActivityVideoEntity({
    required String id,
    @Default('') String title,
    int? durationSecs,
  }) = _ActivityVideoEntity;

  const ActivityVideoEntity._();

  factory ActivityVideoEntity.fromJson(Map<String, dynamic> json) =>
      _$ActivityVideoEntityFromJson(json);
}

/// The nested `document` of an activity row.
@freezed
abstract class ActivityDocumentEntity with _$ActivityDocumentEntity {
  const factory ActivityDocumentEntity({
    required String id,
    @Default('') String title,
    int? pageCount,
  }) = _ActivityDocumentEntity;

  const ActivityDocumentEntity._();

  factory ActivityDocumentEntity.fromJson(Map<String, dynamic> json) =>
      _$ActivityDocumentEntityFromJson(json);
}

/// One `ResourceActivity` row — the single source of truth for history,
/// continue-watching, continue-reading and progress status (backend plan §1.1).
///
/// Every field but [id] is optional or defaulted. The endpoints return this
/// shape from six different places (`/me/activity`, `/me/continue`, both
/// progress `PUT`s, both completion routes, and inside `/home/*`), and a row
/// missing a nested resource because it was deleted between the query and the
/// include must degrade to an unlabelled row rather than fail the page.
///
/// **[percent] and [status] are the server's** (backend plan §3.1). The client
/// never computes either: completion is unique coverage against a
/// server-configured threshold, and a client-computed percentage would be
/// unverifiable and forgeable. Treat a locally-derived percent as provisional
/// until a flush confirms it.
@freezed
abstract class ResourceActivityEntity with _$ResourceActivityEntity {
  const factory ResourceActivityEntity({
    required String id,
    @JsonKey(unknownEnumValue: ActivityResourceType.unknown)
    @Default(ActivityResourceType.unknown)
    ActivityResourceType resourceType,
    String? videoId,
    String? documentId,
    @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)
    @Default(ActivityProgressStatus.unknown)
    ActivityProgressStatus status,
    @Default(0) int positionSecs,
    @Default(0) int coveredSecs,
    @Default(0) int percent,
    int? lastPage,
    int? pageCount,
    DateTime? markedCompleteAt,
    DateTime? completedAt,
    DateTime? firstAccessedAt,
    DateTime? lastAccessedAt,
    DateTime? updatedAt,
    ActivityVideoEntity? video,
    ActivityDocumentEntity? document,
  }) = _ResourceActivityEntity;

  const ResourceActivityEntity._();

  factory ResourceActivityEntity.fromJson(Map<String, dynamic> json) =>
      _$ResourceActivityEntityFromJson(json);

  /// The resource this row is about. Exactly one of the two id columns is
  /// non-null server-side (a CHECK constraint enforces it), so falling through
  /// them is unambiguous; the nested objects are the fallback for a payload
  /// that sent the relation but not the raw column.
  String get resourceId =>
      videoId ?? documentId ?? video?.id ?? document?.id ?? '';

  /// Prefers the row's own `resourceType`, then infers from whichever id is
  /// present — `/home/*` and `/me/continue` both return the same select, but
  /// inference costs nothing and covers a payload that omitted the field.
  ActivityResourceType get kind {
    if (resourceType != ActivityResourceType.unknown) {
      return resourceType;
    }
    if (videoId != null || video != null) {
      return ActivityResourceType.video;
    }
    if (documentId != null || document != null) {
      return ActivityResourceType.document;
    }
    return ActivityResourceType.unknown;
  }

  bool get isVideo => kind == ActivityResourceType.video;

  bool get isDocument => kind == ActivityResourceType.document;

  bool get isCompleted => status == ActivityProgressStatus.completed;

  /// What the row draws. Falls back rather than blanking, for the same reason
  /// `StudentEntity.displayName` does.
  String get title {
    final String? videoTitle = _trimToNull(video?.title);
    final String? documentTitle = _trimToNull(document?.title);
    return videoTitle ??
        documentTitle ??
        (isVideo ? 'Untitled video' : 'Untitled document');
  }

  int? get durationSecs => video?.durationSecs;

  /// The document's page count, preferring the row's own snapshot.
  ///
  /// `ResourceActivity.pageCount` is deliberately a snapshot server-side, so a
  /// re-upload cannot retroactively change a stored percentage — which is why
  /// it wins over the live `Document.pageCount`.
  int? get resolvedPageCount => pageCount ?? document?.pageCount;

  /// `'page 7 of 24'`, or `'page 7'` when the count is unknown.
  ///
  /// The bare form is required, not a nicety: `Document.pageCount` is
  /// populated at ingest and is null for anything uploaded before that landed
  /// (mobile plan §4, backend plan §10.3). Guessing a denominator would be
  /// worse than omitting it.
  String? get readingLabel {
    final int? page = lastPage;
    if (page == null || page <= 0) {
      return null;
    }
    final int? count = resolvedPageCount;
    return count == null || count <= 0 ? 'page $page' : 'page $page of $count';
  }

  /// A 0–1 fraction for the row's progress bar, or `null` when there is
  /// nothing meaningful to draw.
  double? get progressFraction {
    if (isCompleted) {
      return 1;
    }
    if (percent > 0) {
      return (percent / 100).clamp(0.0, 1.0);
    }
    return null;
  }

  /// The cache row this activity becomes. [LocalActivity] is a `core/` type, so
  /// the conversion lives here rather than there.
  LocalActivity toLocalActivity() => LocalActivity(
    resourceId: resourceId,
    resourceType: kind.wireValue ?? 'VIDEO',
    status: status.wireValue ?? 'IN_PROGRESS',
    lastAccessedAt: lastAccessedAt ?? DateTime.now(),
    title: title,
    percent: percent,
    positionSecs: positionSecs,
    lastPage: lastPage,
    pageCount: resolvedPageCount,
    durationSecs: durationSecs,
    completedAt: completedAt,
    // Whatever produced this came from the server, so it is synced by
    // definition. `updatedAt` is preferred but the fallback keeps the
    // "has been reconciled" flag true, which is what the resume chooser reads.
    serverUpdatedAt: updatedAt ?? lastAccessedAt ?? DateTime.now(),
  );
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
