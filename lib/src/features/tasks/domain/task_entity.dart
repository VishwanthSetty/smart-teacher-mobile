import 'package:freezed_annotation/freezed_annotation.dart';

import '../../activity/domain/resource_activity_entity.dart';

part 'task_entity.freezed.dart';
part 'task_entity.g.dart';

/// A task's lifecycle (backend plan §1.3).
///
/// Cancellation is **soft**: the assignments stay for the record, so a
/// cancelled task is still readable and still counts in a student's history of
/// what they were asked to do.
enum TaskLifecycleStatus {
  @JsonValue('ACTIVE')
  active,

  @JsonValue('CANCELLED')
  cancelled,

  unknown;

  String? get wireValue => switch (this) {
    TaskLifecycleStatus.active => 'ACTIVE',
    TaskLifecycleStatus.cancelled => 'CANCELLED',
    TaskLifecycleStatus.unknown => null,
  };

  String? get label => switch (this) {
    TaskLifecycleStatus.active => 'Active',
    TaskLifecycleStatus.cancelled => 'Cancelled',
    TaskLifecycleStatus.unknown => null,
  };
}

/// The minimal resource reference a task carries.
///
/// `TASK_DETAIL_SELECT` includes only `{ id, title }` for the video or
/// document, which is all a task row needs — opening it goes through the
/// player/reader route, which fetches the full detail itself.
@freezed
abstract class TaskResourceRef with _$TaskResourceRef {
  const factory TaskResourceRef({
    required String id,
    @Default('') String title,
  }) = _TaskResourceRef;

  const TaskResourceRef._();

  factory TaskResourceRef.fromJson(Map<String, dynamic> json) =>
      _$TaskResourceRefFromJson(json);
}

/// One `TaskAssignment` — a single student's standing against a task
/// (backend plan §1.3).
///
/// [status] is **derived server-side** from the linked resource's progress and
/// is never client-supplied (backend plan §6). Nothing in this app writes it:
/// the student completes the *resource*, and the task follows.
@freezed
abstract class TaskAssignmentEntity with _$TaskAssignmentEntity {
  const factory TaskAssignmentEntity({
    required String id,
    String? studentId,
    @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)
    @Default(ActivityProgressStatus.unknown)
    ActivityProgressStatus status,
    DateTime? completedAt,

    /// Stamped at fan-out when the student had **already** completed the
    /// resource. The task is not auto-closed on this basis — the teacher
    /// decides what it means — but every report and the student's own list
    /// flags it (backend plan §1.3).
    DateTime? preCompletedAt,
    DateTime? createdAt,
  }) = _TaskAssignmentEntity;

  const TaskAssignmentEntity._();

  factory TaskAssignmentEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentEntityFromJson(json);

  bool get isCompleted => status == ActivityProgressStatus.completed;

  bool get wasPreCompleted => preCompletedAt != null;
}

/// One `Task` (backend plan §1.3), as both `/tasks` and `/me/tasks` embed it.
///
/// The **resource and the recipients are immutable** by design: changing either
/// would invalidate every `TaskAssignment.status` already derived from the old
/// resource and silently re-fan-out, so both are a cancel-and-recreate
/// (backend plan §5.4). Only [title], [instructions] and [dueAt] are editable,
/// and nothing in this entity offers a way to say otherwise.
@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String id,
    @Default('') String title,
    String? instructions,
    DateTime? dueAt,
    @JsonKey(unknownEnumValue: ActivityResourceType.unknown)
    @Default(ActivityResourceType.unknown)
    ActivityResourceType resourceType,
    String? videoId,
    String? documentId,
    @JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown)
    @Default(TaskLifecycleStatus.unknown)
    TaskLifecycleStatus status,
    DateTime? cancelledAt,
    String? sectionId,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskResourceRef? video,
    TaskResourceRef? document,
    @Default(<TaskAssignmentEntity>[]) List<TaskAssignmentEntity> assignments,
  }) = _TaskEntity;

  const TaskEntity._();

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityFromJson(json);

  String get resourceId =>
      videoId ?? documentId ?? video?.id ?? document?.id ?? '';

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

  bool get isCancelled => status == TaskLifecycleStatus.cancelled;

  String get displayTitle {
    final String trimmed = title.trim();
    return trimmed.isEmpty ? 'Untitled task' : trimmed;
  }

  /// What the row captions under the title.
  String get resourceTitle {
    final String? videoTitle = _trimToNull(video?.title);
    final String? documentTitle = _trimToNull(document?.title);
    return videoTitle ??
        documentTitle ??
        (isVideo ? 'Untitled video' : 'Untitled document');
  }

  int get recipientCount => assignments.length;

  int get completedCount =>
      assignments.where((TaskAssignmentEntity row) => row.isCompleted).length;

  /// Counted separately from [completedCount] so a 100% rate that was 100% on
  /// day one is legible as such (backend plan §6).
  int get preCompletedCount => assignments
      .where((TaskAssignmentEntity row) => row.wasPreCompleted)
      .length;

  /// Past its due date and not yet done — the wording every list sorts on.
  ///
  /// A task with no [dueAt] is never overdue: an open-ended task is a
  /// legitimate thing to set, and calling it late would be an invention.
  bool isOverdueAt(DateTime now) {
    final DateTime? due = dueAt;
    return due != null && due.isBefore(now) && !isCancelled;
  }
}

/// One row of `GET /me/tasks` (backend plan §5.4) — the student's own
/// assignment, with the task nested inside it.
///
/// The assignment is the row, not the task: two students hold different
/// standings against the same task, and this is the one that is *theirs*.
@freezed
abstract class StudentTaskEntity with _$StudentTaskEntity {
  const factory StudentTaskEntity({
    required String id,
    @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)
    @Default(ActivityProgressStatus.unknown)
    ActivityProgressStatus status,
    DateTime? completedAt,
    DateTime? preCompletedAt,
    DateTime? createdAt,
    TaskEntity? task,
  }) = _StudentTaskEntity;

  const StudentTaskEntity._();

  factory StudentTaskEntity.fromJson(Map<String, dynamic> json) =>
      _$StudentTaskEntityFromJson(json);

  bool get isCompleted => status == ActivityProgressStatus.completed;

  /// True when the student had already finished the resource before the task
  /// existed. Surfaced on the row as "Completed before this was assigned", so
  /// a student isn't told to redo something they've done.
  bool get wasPreCompleted => preCompletedAt != null;

  bool isOverdueAt(DateTime now) =>
      !isCompleted && (task?.isOverdueAt(now) ?? false);

  String get displayTitle => task?.displayTitle ?? 'Untitled task';

  DateTime? get dueAt => task?.dueAt;
}

/// Which section of the student's list a row falls into (mobile plan §5.6).
enum StudentTaskGroup { overdue, dueSoon, completed }

/// Splits assignments into the plan's three sections.
///
/// Completed wins over overdue: a task finished after its due date is done, and
/// filing it under *Overdue* would ask the student to act on something they
/// have already closed.
Map<StudentTaskGroup, List<StudentTaskEntity>> groupStudentTasks(
  List<StudentTaskEntity> rows,
  DateTime now,
) {
  final Map<StudentTaskGroup, List<StudentTaskEntity>> grouped =
      <StudentTaskGroup, List<StudentTaskEntity>>{
        StudentTaskGroup.overdue: <StudentTaskEntity>[],
        StudentTaskGroup.dueSoon: <StudentTaskEntity>[],
        StudentTaskGroup.completed: <StudentTaskEntity>[],
      };

  for (final StudentTaskEntity row in rows) {
    if (row.isCompleted) {
      grouped[StudentTaskGroup.completed]!.add(row);
    } else if (row.isOverdueAt(now)) {
      grouped[StudentTaskGroup.overdue]!.add(row);
    } else {
      grouped[StudentTaskGroup.dueSoon]!.add(row);
    }
  }

  return grouped;
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
