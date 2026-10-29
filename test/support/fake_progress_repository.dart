import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/sync/watch_interval.dart';
import 'package:smart_teacher_mobile/src/features/activity/data/progress_repository.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/progress_summary_entity.dart';
import 'package:smart_teacher_mobile/src/features/activity/domain/resource_activity_entity.dart';

/// A recorded call to one of the progress endpoints.
///
/// The **arguments** are the assertion surface here, as with the teacher
/// assignment fake: a beat that quietly sent the wrong intervals — or a
/// `clientUpdatedAt` stamped at send time rather than at the user's action —
/// returns a perfectly plausible response either way. Only the recorded call
/// catches it.
class ProgressCall {
  const ProgressCall({
    required this.kind,
    required this.resourceId,
    this.positionSecs,
    this.intervals = const <WatchInterval>[],
    this.lastPage,
    this.pageCount,
    this.clientUpdatedAt,
  });

  final String kind;
  final String resourceId;
  final int? positionSecs;
  final List<WatchInterval> intervals;
  final int? lastPage;
  final int? pageCount;
  final DateTime? clientUpdatedAt;

  @override
  String toString() => 'ProgressCall($kind, $resourceId, $intervals)';
}

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({
    this.error,
    this.summary = const <ProgressSummaryEntity>[],
    ResourceActivityEntity? activity,
  }) : activity = activity ?? buildActivity(id: 'activity-1');

  /// Thrown by every method when set, so a test can drive the worker's
  /// discard-vs-retry split without a Dio stack.
  AppError? error;

  /// What every write answers with.
  ResourceActivityEntity activity;

  List<ProgressSummaryEntity> summary;

  final List<ProgressCall> calls = <ProgressCall>[];

  @override
  Future<ResourceActivityEntity> updateVideoProgress({
    required String videoId,
    required int positionSecs,
    required List<WatchInterval> intervals,
    required DateTime clientUpdatedAt,
  }) async {
    calls.add(
      ProgressCall(
        kind: 'videoProgress',
        resourceId: videoId,
        positionSecs: positionSecs,
        intervals: intervals,
        clientUpdatedAt: clientUpdatedAt,
      ),
    );
    return _answer();
  }

  @override
  Future<ResourceActivityEntity> updateDocumentProgress({
    required String documentId,
    required int lastPage,
    required DateTime clientUpdatedAt,
    int? pageCount,
  }) async {
    calls.add(
      ProgressCall(
        kind: 'docProgress',
        resourceId: documentId,
        lastPage: lastPage,
        pageCount: pageCount,
        clientUpdatedAt: clientUpdatedAt,
      ),
    );
    return _answer();
  }

  @override
  Future<ResourceActivityEntity> markDocumentComplete(String documentId) async {
    calls.add(ProgressCall(kind: 'docComplete', resourceId: documentId));
    return _answer();
  }

  @override
  Future<ResourceActivityEntity> unmarkDocumentComplete(
    String documentId,
  ) async {
    calls.add(ProgressCall(kind: 'docUncomplete', resourceId: documentId));
    return _answer();
  }

  @override
  Future<List<ProgressSummaryEntity>> fetchSummary() async {
    if (error case final AppError failure) {
      throw failure;
    }
    return summary;
  }

  ResourceActivityEntity _answer() {
    if (error case final AppError failure) {
      throw failure;
    }
    return activity;
  }
}

/// A video activity row by default; pass [documentId] for a document one.
ResourceActivityEntity buildActivity({
  String id = 'activity-1',
  String? videoId = 'video-1',
  String? documentId,
  String title = 'Photosynthesis',
  ActivityProgressStatus status = ActivityProgressStatus.inProgress,
  int percent = 40,
  int positionSecs = 120,
  int? lastPage,
  int? pageCount,
  int? durationSecs = 600,
  DateTime? lastAccessedAt,
  DateTime? completedAt,
}) {
  final bool isDocument = documentId != null;
  return ResourceActivityEntity(
    id: id,
    resourceType: isDocument
        ? ActivityResourceType.document
        : ActivityResourceType.video,
    videoId: isDocument ? null : videoId,
    documentId: documentId,
    status: status,
    percent: percent,
    positionSecs: positionSecs,
    lastPage: lastPage,
    pageCount: pageCount,
    completedAt: completedAt,
    lastAccessedAt: lastAccessedAt ?? DateTime(2026, 9, 11, 10),
    updatedAt: lastAccessedAt ?? DateTime(2026, 9, 11, 10),
    video: isDocument
        ? null
        : ActivityVideoEntity(
            id: videoId ?? 'video-1',
            title: title,
            durationSecs: durationSecs,
          ),
    document: isDocument
        ? ActivityDocumentEntity(
            id: documentId,
            title: title,
            pageCount: pageCount,
          )
        : null,
  );
}

ProgressSummaryEntity buildSummary({
  String subjectId = 'subject-1',
  String subjectName = 'Mathematics',
  int total = 10,
  int notStarted = 5,
  int inProgress = 3,
  int completed = 2,
  int percent = 20,
}) => ProgressSummaryEntity(
  subjectId: subjectId,
  subjectName: subjectName,
  total: total,
  notStarted: notStarted,
  inProgress: inProgress,
  completed: completed,
  percent: percent,
);
