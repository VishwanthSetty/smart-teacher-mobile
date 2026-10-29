import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../../home/domain/home_entity.dart';
import '../../home/presentation/home_controller.dart';
import '../data/task_repository.dart';
import 'teacher_tasks_controller.dart';

/// The resource the teacher picked (mobile plan §5.8, step 1).
@immutable
class AssignableResource {
  const AssignableResource({
    required this.id,
    required this.type,
    required this.title,
  });

  final String id;
  final ActivityResourceType type;
  final String title;
}

/// The three-step sheet's state (mobile plan §5.8).
@immutable
class AssignTaskState {
  const AssignTaskState({
    this.resource,
    this.sectionId,
    this.studentIds = const <String>[],
    this.title = '',
    this.instructions = '',
    this.dueAt,
    this.isSubmitting = false,
    this.error,
    this.unreachableStudentIds = const <String>[],
  });

  final AssignableResource? resource;

  /// Exactly one of these two is ever set. The server rejects both and neither
  /// with a `400` ("Choose either a section or one or more students"), so the
  /// recipient step is built so only one can be chosen — [selectSection] and
  /// [selectStudents] each clear the other.
  final String? sectionId;
  final List<String> studentIds;

  final String title;
  final String instructions;
  final DateTime? dueAt;

  final bool isSubmitting;
  final AppError? error;

  /// From the `422`: recipients whose own scope does not include the resource.
  /// Listed by name so the teacher can deselect and retry — never silently
  /// dropped (backend plan §4.3).
  final List<String> unreachableStudentIds;

  bool get hasResource => resource != null;

  bool get hasRecipients => sectionId != null || studentIds.isNotEmpty;

  bool get canSubmit =>
      hasResource && hasRecipients && title.trim().isNotEmpty && !isSubmitting;

  AssignTaskState copyWith({
    AssignableResource? resource,
    String? sectionId,
    List<String>? studentIds,
    String? title,
    String? instructions,
    DateTime? dueAt,
    bool? isSubmitting,
    AppError? error,
    List<String>? unreachableStudentIds,
    bool clearSection = false,
    bool clearDueAt = false,
    bool clearError = false,
  }) => AssignTaskState(
    resource: resource ?? this.resource,
    sectionId: clearSection ? null : (sectionId ?? this.sectionId),
    studentIds: studentIds ?? this.studentIds,
    title: title ?? this.title,
    instructions: instructions ?? this.instructions,
    dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: clearError ? null : (error ?? this.error),
    unreachableStudentIds: unreachableStudentIds ?? this.unreachableStudentIds,
  );
}

/// Drives the assign sheet (mobile plan §5.8).
///
/// Auto-disposing: the sheet is opened, used and dismissed, and a half-filled
/// draft surviving until the next one would be worse than starting clean.
class AssignTaskController extends Notifier<AssignTaskState> {
  @override
  AssignTaskState build() => const AssignTaskState();

  void selectResource(AssignableResource resource) {
    state = state.copyWith(
      resource: resource,
      // The title defaults to the resource's, which is what a teacher would
      // type anyway — and is still editable on the details step.
      title: state.title.trim().isEmpty ? resource.title : state.title,
      clearError: true,
    );
  }

  void selectSection(String sectionId) {
    state = state.copyWith(
      sectionId: sectionId,
      studentIds: const <String>[],
      unreachableStudentIds: const <String>[],
      clearError: true,
    );
  }

  void selectStudents(List<String> studentIds) {
    state = state.copyWith(
      studentIds: List<String>.unmodifiable(studentIds),
      clearSection: true,
      clearError: true,
    );
  }

  void toggleStudent(String studentId) {
    final List<String> next = state.studentIds.contains(studentId)
        ? (state.studentIds.where((String id) => id != studentId).toList())
        : (<String>[...state.studentIds, studentId]);
    selectStudents(next);
  }

  void setTitle(String title) => state = state.copyWith(title: title);

  void setInstructions(String instructions) =>
      state = state.copyWith(instructions: instructions);

  void setDueAt(DateTime? dueAt) => state = dueAt == null
      ? state.copyWith(clearDueAt: true)
      : state.copyWith(dueAt: dueAt);

  /// Creates the task. Answers `true` on success.
  ///
  /// The `422` is caught and turned into [AssignTaskState.unreachableStudentIds]
  /// rather than a generic failure, because the ids are the actionable part:
  /// the recipient step highlights those students and the teacher can deselect
  /// them and retry. A `400` for a teacher-audience resource is caught too, but
  /// the picker already blocks those, so reaching it means something upstream
  /// changed.
  Future<bool> submit() async {
    final AssignTaskState current = state;
    final AssignableResource? resource = current.resource;
    if (resource == null || !current.canSubmit) {
      return false;
    }
    state = current.copyWith(
      isSubmitting: true,
      clearError: true,
      unreachableStudentIds: const <String>[],
    );

    try {
      await ref
          .read(taskRepositoryProvider)
          .createTask(
            title: current.title,
            resourceType: resource.type,
            resourceId: resource.id,
            instructions: current.instructions,
            dueAt: current.dueAt,
            sectionId: current.sectionId,
            studentIds: current.sectionId == null ? current.studentIds : null,
          );
      // The teacher's list is what they land back on, so it is re-read here
      // rather than left to a pull-to-refresh.
      await ref.read(teacherTasksControllerProvider.notifier).refresh();
      if (ref.mounted) {
        state = const AssignTaskState();
      }
      return true;
    } on TaskRecipientsUnreachable catch (rejection) {
      if (ref.mounted) {
        state = current.copyWith(
          isSubmitting: false,
          unreachableStudentIds: rejection.studentIds,
          error: ValidationError(
            message: rejection.message,
            fieldErrors: const <String>[],
          ),
        );
      }
      return false;
    } on AppError catch (error) {
      if (ref.mounted) {
        state = current.copyWith(isSubmitting: false, error: error);
      }
      return false;
    }
  }
}

final NotifierProvider<AssignTaskController, AssignTaskState>
assignTaskControllerProvider = NotifierProvider.autoDispose<
  AssignTaskController,
  AssignTaskState
>(AssignTaskController.new);

/// The sections a teacher may actually assign to.
///
/// **Not** `GET /sections`, which is school-wide. These come from
/// `/home/teacher`, whose `classes` are resolved through
/// `TeacherClassScopeService` — section-bearing assignments only, failing
/// closed (backend plan §4.2). That is exactly the set the server will accept,
/// so offering anything wider would mean building a picker whose choices `404`.
///
/// A teacher with none sees "You aren't assigned to a class yet" and the flow
/// is disabled, which matches the server refusing such a teacher outright.
final Provider<List<HomeClassEntity>> assignableSectionsProvider =
    Provider<List<HomeClassEntity>>(
      (Ref ref) =>
          ref.watch(teacherHomeControllerProvider).value?.classes ??
          const <HomeClassEntity>[],
    );
