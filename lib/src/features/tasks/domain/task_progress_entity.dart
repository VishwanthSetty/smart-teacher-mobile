import 'package:freezed_annotation/freezed_annotation.dart';

import '../../activity/domain/resource_activity_entity.dart';

part 'task_progress_entity.freezed.dart';
part 'task_progress_entity.g.dart';

/// The student a progress row is about.
///
/// `TaskProgressService.forTask` selects exactly `{ name, email }` — no id on
/// the nested object, because the row above it already carries `studentId`.
@freezed
abstract class TaskProgressStudentRef with _$TaskProgressStudentRef {
  const factory TaskProgressStudentRef({
    String? name,
    String? email,
  }) = _TaskProgressStudentRef;

  const TaskProgressStudentRef._();

  factory TaskProgressStudentRef.fromJson(Map<String, dynamic> json) =>
      _$TaskProgressStudentRefFromJson(json);
}

/// One row of `GET /tasks/:id/progress` (backend plan §5.4).
///
/// This is a `TaskAssignment` with the student's name joined on — the same row
/// `TaskEntity.assignments` carries, plus the name the report needs to be
/// readable. The teacher's detail screen counts completions from the embedded
/// assignments and needs no call at all; this endpoint exists because *naming*
/// the pending students does.
///
/// [status] is derived server-side from the linked resource's progress
/// (backend plan §6). Nothing in this app writes it, and nothing here offers a
/// way to.
@freezed
abstract class TaskProgressRowEntity with _$TaskProgressRowEntity {
  const factory TaskProgressRowEntity({
    required String id,
    String? studentId,
    @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)
    @Default(ActivityProgressStatus.unknown)
    ActivityProgressStatus status,
    DateTime? completedAt,
    DateTime? preCompletedAt,
    TaskProgressStudentRef? student,
  }) = _TaskProgressRowEntity;

  const TaskProgressRowEntity._();

  factory TaskProgressRowEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskProgressRowEntityFromJson(json);

  bool get isCompleted => status == ActivityProgressStatus.completed;

  /// Pending is "not completed", not "not started" — a student halfway through
  /// the video still has the task open, and *Remind pending* reminds them too,
  /// exactly as `TasksService.remind` does server-side.
  bool get isPending => !isCompleted;

  bool get wasPreCompleted => preCompletedAt != null;

  /// Falls through rather than blanking, for the same reason
  /// `StudentEntity.displayName` does: one row missing a name must not leave a
  /// report with an unidentifiable line in it.
  String get displayName {
    final String? name = _trimToNull(student?.name);
    final String? email = _trimToNull(student?.email);
    return name ?? email ?? _trimToNull(studentId) ?? 'Unnamed student';
  }

  /// The second line of the row, when there is one to draw.
  String? get subtitle {
    final String? email = _trimToNull(student?.email);
    final String? name = _trimToNull(student?.name);
    // Only worth showing when it isn't already the title.
    return name == null ? null : email;
  }
}

/// One row of `GET /teacher/class-progress` (backend plan §5.4).
///
/// A per-task rollup, **not** a per-section one: the server groups by task and
/// reports the section each belongs to, so a section with three tasks appears
/// three times. Nothing here re-groups by section — that would be a second,
/// disagreeing source of truth for counts the server already computed.
///
/// [preCompleted] is reported alongside [completed] rather than folded into it,
/// so a rollup that was complete on day one is legible as such (backend plan
/// §6).
@freezed
abstract class ClassProgressRowEntity with _$ClassProgressRowEntity {
  const factory ClassProgressRowEntity({
    required String taskId,
    @Default('') String title,
    String? sectionId,
    @Default(0) int total,
    @Default(0) int notStarted,
    @Default(0) int inProgress,
    @Default(0) int completed,
    @Default(0) int preCompleted,
  }) = _ClassProgressRowEntity;

  const ClassProgressRowEntity._();

  factory ClassProgressRowEntity.fromJson(Map<String, dynamic> json) =>
      _$ClassProgressRowEntityFromJson(json);

  String get displayTitle {
    final String trimmed = title.trim();
    return trimmed.isEmpty ? 'Untitled task' : trimmed;
  }

  /// A 0–1 fraction for the bar, or `null` when there is nothing to draw.
  ///
  /// A task with no recipients answers `null` rather than `0`: an empty
  /// fan-out is not "nobody has finished", and a bar drawn at zero would read
  /// as one.
  double? get completionFraction =>
      total <= 0 ? null : (completed / total).clamp(0.0, 1.0);
}

/// The answer to `POST /tasks/:id/remind` — `{ reminded: n }`.
///
/// The count is the whole point of the response. The server dedupes per UTC day
/// through a unique `(taskAssignmentId, sentOn)` index and swallows the
/// resulting `P2002`, so a **second** press on the same day returns `0` having
/// sent nothing. The UI must say "already sent today" rather than pretend it
/// sent another (mobile plan §5.9) — see [TaskReminderOutcome].
@freezed
abstract class TaskReminderResult with _$TaskReminderResult {
  const factory TaskReminderResult({@Default(0) int reminded}) =
      _TaskReminderResult;

  const TaskReminderResult._();

  factory TaskReminderResult.fromJson(Map<String, dynamic> json) =>
      _$TaskReminderResultFromJson(json);
}

/// What a *Remind pending* press actually did, once `reminded: 0` has been
/// disambiguated.
///
/// Zero has two causes and they need different sentences: nobody was pending,
/// or everybody pending had already been reminded today. The server cannot tell
/// them apart in its response — both are `{ reminded: 0 }` — but the caller can,
/// because it is holding the progress rows that say how many are pending.
enum TaskReminderOutcome {
  /// At least one reminder was sent.
  sent,

  /// Pending students exist, but the per-day dedupe swallowed every write.
  alreadySentToday,

  /// Nothing to remind: everyone has completed the task.
  nonePending,

  /// The task is cancelled, or not `ACTIVE` — the server returns
  /// `{ reminded: 0 }` without even looking at the recipients.
  notActive,
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
