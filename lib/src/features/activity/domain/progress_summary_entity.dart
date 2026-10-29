import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_summary_entity.freezed.dart';
part 'progress_summary_entity.g.dart';

/// One per-subject rollup from `GET /me/progress/summary` (backend plan §3.3).
///
/// The endpoint is **actor-scoped**, which is why one widget serves both the
/// student's "Learning Progress" and the teacher's "My Preparation Progress"
/// (mobile plan §5.3). Nothing here reads the role; the two screens differ only
/// in their heading, and the teacher's is labelled "My preparation" explicitly
/// so a teacher's own reading progress is never mistaken for their class's.
///
/// [total] counts the resources inside the actor's resolved content scope, so a
/// summary shrinks on its own when an entitlement lapses — and [notStarted]
/// needs no stored rows, since the absence of a `ResourceActivity` *is*
/// not-started.
@freezed
abstract class ProgressSummaryEntity with _$ProgressSummaryEntity {
  const factory ProgressSummaryEntity({
    required String subjectId,
    @Default('') String subjectName,
    String? gradeLevelId,
    @Default(0) int total,
    @Default(0) int notStarted,
    @Default(0) int inProgress,
    @Default(0) int completed,
    @Default(0) int percent,
  }) = _ProgressSummaryEntity;

  const ProgressSummaryEntity._();

  factory ProgressSummaryEntity.fromJson(Map<String, dynamic> json) =>
      _$ProgressSummaryEntityFromJson(json);

  String get displayName =>
      subjectName.trim().isEmpty ? 'Untitled subject' : subjectName.trim();

  /// A subject with nothing in it. Worth its own check because the
  /// three-segment bar has no sensible rendering at zero and would otherwise
  /// divide by it.
  bool get isEmpty => total <= 0;

  /// The three bar segments as fractions of [total], in render order.
  ///
  /// Computed from the counts rather than from [percent]: `percent` is
  /// completed-over-total only, so it cannot describe the middle segment, and
  /// deriving all three from one number would put a rounding error in the bar.
  (double, double, double) get segments {
    if (isEmpty) {
      return (0, 0, 0);
    }
    return (
      notStarted / total,
      inProgress / total,
      completed / total,
    );
  }
}
