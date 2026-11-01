import 'package:flutter/foundation.dart';

import '../../activity/domain/resource_activity_entity.dart';

/// `GET /home/student` (backend plan §5.3) — four rails in one round trip.
///
/// A single aggregate on purpose: the mobile client renders one screen and
/// should not fan out five calls on cold start.
///
/// **The task and saved payloads are reduced to counts here.** `tasksDue`
/// carries `TaskAssignment` rows and `saved` carries `Bookmark` rows, both of
/// which belong to later phases — modelling them now would mean two entities
/// with no screen, written against a shape nothing yet renders. The counts are
/// enough for the rails that exist, and the reduction is deliberate rather than
/// a payload silently dropped on the floor.
@immutable
class StudentHomeEntity {
  const StudentHomeEntity({
    this.continueLearning = const <ResourceActivityEntity>[],
    this.recent = const <ResourceActivityEntity>[],
    this.tasksDueCount = 0,
    this.savedCount = 0,
  });

  factory StudentHomeEntity.fromJson(Map<String, dynamic> json) =>
      StudentHomeEntity(
        continueLearning: _activityList(json['continue']),
        recent: _activityList(json['recent']),
        tasksDueCount: _lengthOf(json['tasksDue']),
        savedCount: _lengthOf(json['saved']),
      );

  /// In-progress resources, newest first. Videos and documents in one rail,
  /// ordered by `lastAccessedAt` — which is how the server already returns it.
  final List<ResourceActivityEntity> continueLearning;

  final List<ResourceActivityEntity> recent;

  /// Open tasks due soonest. Rendered as a count until phase 4 builds the
  /// tasks feature.
  final int tasksDueCount;

  /// Saved bookmarks. Rendered as a count until phase 3 builds Saved.
  final int savedCount;

  /// A brand-new account with nothing anywhere.
  ///
  /// Worth its own check because the screen's empty state must never read as
  /// an error: a student with no active enrollment has an empty library **by
  /// design**, and the copy for that case is "your class hasn't been set up
  /// yet", not a failure (mobile plan §5.1).
  bool get isEmpty =>
      continueLearning.isEmpty &&
      recent.isEmpty &&
      tasksDueCount == 0 &&
      savedCount == 0;
}

/// One of the teacher's assigned sections, as `/home/teacher` returns it.
@immutable
class HomeClassEntity {
  const HomeClassEntity({
    required this.id,
    this.name = '',
    this.gradeLevelName,
  });

  factory HomeClassEntity.fromJson(Map<String, dynamic> json) =>
      HomeClassEntity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        gradeLevelName: switch (json['gradeLevel']) {
          final Map<String, dynamic> grade => grade['name']?.toString(),
          _ => null,
        },
      );

  final String id;
  final String name;
  final String? gradeLevelName;

  /// `'Grade 5 - A'`, or whichever half arrived. Same precedence the roster and
  /// My Classes already use, so one section reads identically across screens.
  String get displayLabel {
    final String grade = gradeLevelName?.trim() ?? '';
    final String section = name.trim();
    if (grade.isNotEmpty && section.isNotEmpty) {
      return '$grade - $section';
    }
    return grade.isNotEmpty ? grade : (section.isEmpty ? 'Section' : section);
  }
}

/// The aggregate completion counts across this teacher's active tasks.
@immutable
class TaskCompletionSummary {
  const TaskCompletionSummary({
    this.notStarted = 0,
    this.inProgress = 0,
    this.completed = 0,
  });

  factory TaskCompletionSummary.fromJson(Map<String, dynamic> json) =>
      TaskCompletionSummary(
        notStarted: _intOf(json['notStarted']),
        inProgress: _intOf(json['inProgress']),
        completed: _intOf(json['completed']),
      );

  final int notStarted;
  final int inProgress;
  final int completed;

  int get total => notStarted + inProgress + completed;

  bool get isEmpty => total == 0;
}

/// `GET /home/teacher` (backend plan §5.3).
///
/// [activeTaskCount] is a count for the same reason as the student's: the tasks
/// feature is phase 4, and phase 2's deliverable is explicitly the dashboard
/// *without* task tiles.
@immutable
class TeacherHomeEntity {
  const TeacherHomeEntity({
    this.classes = const <HomeClassEntity>[],
    this.continuePreparation = const <ResourceActivityEntity>[],
    this.completionSummary = const TaskCompletionSummary(),
    this.activeTaskCount = 0,
  });

  factory TeacherHomeEntity.fromJson(Map<String, dynamic> json) =>
      TeacherHomeEntity(
        classes: switch (json['classes']) {
          final List<dynamic> rows =>
            rows
                .whereType<Map<String, dynamic>>()
                .map(HomeClassEntity.fromJson)
                .toList(growable: false),
          _ => const <HomeClassEntity>[],
        },
        continuePreparation: _activityList(json['continuePreparation']),
        completionSummary: switch (json['completionSummary']) {
          final Map<String, dynamic> summary => TaskCompletionSummary.fromJson(
            summary,
          ),
          _ => const TaskCompletionSummary(),
        },
        activeTaskCount: _lengthOf(json['activeTasks']),
      );

  /// Sections from **section-bearing** teacher assignments only.
  ///
  /// Deliberately narrower than the roster's school-wide `/sections`: this
  /// comes from `TeacherClassScopeService`, which fails closed. A teacher with
  /// no section-bearing assignment legitimately sees none (backend plan §4.2),
  /// and that is an empty state, not an error.
  final List<HomeClassEntity> classes;

  /// The teacher's own in-progress TEACHER-audience material.
  final List<ResourceActivityEntity> continuePreparation;

  final TaskCompletionSummary completionSummary;
  final int activeTaskCount;

  bool get isEmpty =>
      classes.isEmpty &&
      continuePreparation.isEmpty &&
      completionSummary.isEmpty &&
      activeTaskCount == 0;
}

/// Rows that aren't objects are skipped rather than thrown on — one malformed
/// entry must not fail a whole home screen.
List<ResourceActivityEntity> _activityList(dynamic value) {
  if (value is! List<dynamic>) {
    return const <ResourceActivityEntity>[];
  }
  return value
      .whereType<Map<String, dynamic>>()
      .map(ResourceActivityEntity.fromJson)
      .toList(growable: false);
}

int _lengthOf(dynamic value) => value is List<dynamic> ? value.length : 0;

int _intOf(dynamic value) => switch (value) {
  final int number => number,
  final double number when number.isFinite => number.round(),
  final String text => int.tryParse(text) ?? 0,
  _ => 0,
};
