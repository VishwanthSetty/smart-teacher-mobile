import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/session/session_scoped_cache.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../data/task_progress_repository.dart';
import '../domain/task_progress_entity.dart';

/// Per-student progress for one task (mobile plan §5.9).
///
/// **One unfiltered read, split into the three tabs client-side.** The endpoint
/// does accept `?status=`, and History's chips do re-query — but this screen is
/// different in two ways that make the filtered call the wrong one here:
///
/// * the tabs carry counts, and three separately-fetched subsets would let a
///   *Not started* tab disagree with the *Completed* tab about the size of the
///   class, since a student can move between them mid-visit;
/// * *Remind pending* needs to know how many recipients are pending — the very
///   thing that separates "already sent today" from "nobody to remind" — and
///   that is a fact about the whole list, not about the tab in view.
///
/// The list is one task's recipients, so it is a class: tens of rows, one
/// round trip, with no cursor to page. The filtered call is what the server
/// offers a web client that wants one status; this one wants all three.
///
/// Auto-disposing and keyed by task id, like the task detail it is opened from.
class TaskProgressController extends AsyncNotifier<List<TaskProgressRowEntity>> {
  TaskProgressController(this.taskId);

  final String taskId;

  @override
  Future<List<TaskProgressRowEntity>> build() => _fetch();

  Future<void> refresh() async {
    final AsyncValue<List<TaskProgressRowEntity>> next =
        await AsyncValue.guard(_fetch);
    if (ref.mounted) {
      state = next;
    }
  }

  /// `POST /tasks/:id/remind`.
  ///
  /// The server dedupes per UTC day and answers `{ reminded: n }` either way, so
  /// **`0` is ambiguous on the wire** and is disambiguated here, where the
  /// recipient rows are in hand:
  ///
  /// * the task is not `ACTIVE` — the server returns without looking at anyone;
  /// * nobody is pending — there was nothing to send;
  /// * somebody is pending but `n == 0` — every write hit the per-day unique
  ///   index, so a reminder **already went out today**.
  ///
  /// That last case is the one §5.9 calls out by name: the UI must report
  /// "Reminder already sent today" rather than pretend it sent another.
  ///
  /// Throws its `AppError` at the caller, which shows it in a snackbar — this
  /// is an action taken on a screen full of data, not a load that failed.
  Future<TaskReminderOutcome> remindPending({required bool isTaskActive}) async {
    if (!isTaskActive) {
      return TaskReminderOutcome.notActive;
    }
    // Read before the call: what the server will consider pending is the list
    // as it stands now, and re-reading after would race the reminder's own
    // effect on nothing (a reminder does not change a status).
    final int pending = state.value?.where(
          (TaskProgressRowEntity row) => row.isPending,
        ).length ??
        0;
    if (pending == 0) {
      return TaskReminderOutcome.nonePending;
    }

    final TaskReminderResult result = await ref
        .read(taskProgressRepositoryProvider)
        .remindPending(taskId);

    return result.reminded > 0
        ? TaskReminderOutcome.sent
        : TaskReminderOutcome.alreadySentToday;
  }

  Future<List<TaskProgressRowEntity>> _fetch() =>
      ref.read(taskProgressRepositoryProvider).fetchTaskProgress(taskId);
}

/// One student's activity against a task's resource (mobile plan §5.9).
///
/// `null` is a **real answer**, not an absence: the server returns Prisma's
/// `findFirst`, which is `null` for a student who has never opened the
/// resource. That is "not started", and it is a different answer again from the
/// `404` a student outside the teacher's class scope produces — which surfaces
/// as a `NotFoundError` and is rendered as [NotFoundView], with no wording that
/// reads as a refusal (backend plan §4.4).
class StudentTaskActivityController
    extends AsyncNotifier<ResourceActivityEntity?> {
  StudentTaskActivityController(this.key);

  final StudentReportKey key;

  @override
  Future<ResourceActivityEntity?> build() => _fetch();

  Future<void> refresh() async {
    final AsyncValue<ResourceActivityEntity?> next = await AsyncValue.guard(
      _fetch,
    );
    if (ref.mounted) {
      state = next;
    }
  }

  Future<ResourceActivityEntity?> _fetch() => ref
      .read(taskProgressRepositoryProvider)
      .fetchStudentActivity(taskId: key.taskId, studentId: key.studentId);
}

/// The two ids the individual report is keyed by.
///
/// A value type rather than an interpolated string, so two different pairs can
/// never collide into one provider instance through a stray separator in an id.
@immutable
class StudentReportKey {
  const StudentReportKey({required this.taskId, required this.studentId});

  final String taskId;
  final String studentId;

  @override
  bool operator ==(Object other) =>
      other is StudentReportKey &&
      other.taskId == taskId &&
      other.studentId == studentId;

  @override
  int get hashCode => Object.hash(taskId, studentId);

  @override
  String toString() => 'StudentReportKey($taskId, $studentId)';
}

/// The class-progress filters (mobile plan §5.9).
///
/// Its own notifier, watched by the controller, so **changing a filter
/// re-queries by construction** — the arrangement `rosterQueryProvider` and
/// `teacherTaskQueryProvider` both use.
@immutable
class ClassProgressQuery {
  const ClassProgressQuery({this.sectionId, this.subjectId});

  final String? sectionId;
  final String? subjectId;

  ClassProgressQuery copyWith({
    String? sectionId,
    String? subjectId,
    bool clearSection = false,
    bool clearSubject = false,
  }) => ClassProgressQuery(
    sectionId: clearSection ? null : (sectionId ?? this.sectionId),
    subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
  );

  @override
  bool operator ==(Object other) =>
      other is ClassProgressQuery &&
      other.sectionId == sectionId &&
      other.subjectId == subjectId;

  @override
  int get hashCode => Object.hash(sectionId, subjectId);
}

class ClassProgressQueryNotifier extends Notifier<ClassProgressQuery> {
  @override
  ClassProgressQuery build() => const ClassProgressQuery();

  void setSection(String? sectionId) {
    final ClassProgressQuery next = sectionId == null
        ? state.copyWith(clearSection: true)
        : state.copyWith(sectionId: sectionId);
    if (next != state) {
      state = next;
    }
  }

  void setSubject(String? subjectId) {
    final ClassProgressQuery next = subjectId == null
        ? state.copyWith(clearSubject: true)
        : state.copyWith(subjectId: subjectId);
    if (next != state) {
      state = next;
    }
  }
}

/// Class progress (mobile plan §5.9) — `GET /teacher/class-progress`.
///
/// Scoped server-side to the teacher's **own** class scope through
/// `TeacherClassScopeService`, which fails closed: a teacher with no
/// section-bearing assignment legitimately sees nothing here, which is an
/// explanatory empty state rather than an error — and deliberately does not
/// contradict My Classes, which reads the broader `/teacher-assignments`.
///
/// An unrecognised `sectionId` is a `404` rather than an empty list, because
/// filtering to a section outside the teacher's scope is a question the server
/// refuses to answer (backend plan §4.4). The filter here is built from the
/// teacher's own classes, so that is unreachable in practice.
class ClassProgressController
    extends AsyncNotifier<List<ClassProgressRowEntity>> {
  bool _refreshing = false;

  @override
  Future<List<ClassProgressRowEntity>> build() {
    invalidateOnSignOut(ref);
    return _fetch(ref.watch(classProgressQueryProvider));
  }

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<List<ClassProgressRowEntity>> next =
          await AsyncValue.guard(
            () => _fetch(ref.read(classProgressQueryProvider)),
          );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<List<ClassProgressRowEntity>> _fetch(ClassProgressQuery query) => ref
      .read(taskProgressRepositoryProvider)
      .fetchClassProgress(
        sectionId: query.sectionId,
        subjectId: query.subjectId,
      );
}

final AsyncNotifierProviderFamily<
  TaskProgressController,
  List<TaskProgressRowEntity>,
  String
>
taskProgressControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TaskProgressController, List<TaskProgressRowEntity>, String>(
      TaskProgressController.new,
      retry: (int retryCount, Object error) => null,
    );

final AsyncNotifierProviderFamily<
  StudentTaskActivityController,
  ResourceActivityEntity?,
  StudentReportKey
>
studentTaskActivityProvider = AsyncNotifierProvider.autoDispose
    .family<
      StudentTaskActivityController,
      ResourceActivityEntity?,
      StudentReportKey
    >(
      StudentTaskActivityController.new,
      retry: (int retryCount, Object error) => null,
    );

final NotifierProvider<ClassProgressQueryNotifier, ClassProgressQuery>
classProgressQueryProvider =
    NotifierProvider<ClassProgressQueryNotifier, ClassProgressQuery>(
      ClassProgressQueryNotifier.new,
    );

final AsyncNotifierProvider<ClassProgressController, List<ClassProgressRowEntity>>
classProgressControllerProvider =
    AsyncNotifierProvider<ClassProgressController, List<ClassProgressRowEntity>>(
      ClassProgressController.new,
      retry: (int retryCount, Object error) => null,
    );
