import 'package:flutter/foundation.dart';

import '../../activity/domain/resource_activity_entity.dart';
import '../../library/domain/curriculum_entity.dart';

/// What the search screen is currently asking for (mobile plan §5.5).
///
/// A hand-written value type rather than a freezed one, for the same reason
/// `RosterQuery` is: it never round-trips through the API — it is *turned into*
/// query parameters — so there is nothing for `json_serializable` to do, and
/// equality is the only behaviour that matters.
///
/// Equality compares the **trimmed** term, so a trailing space costs no
/// request. Debouncing is the field's job, not this type's: every state change
/// here is meant to reach the network.
@immutable
class SearchQuery {
  const SearchQuery({
    this.term = '',
    this.subjectId,
    this.gradeLevelId,
    this.contentNodeId,
    this.type,
    this.audience,
    this.progress,
  });

  final String term;
  final String? subjectId;
  final String? gradeLevelId;
  final String? contentNodeId;
  final ActivityResourceType? type;

  /// Teacher-only in the filter sheet. A student's search is pinned to
  /// `STUDENT`-audience content by their own entitlement scope server-side, so
  /// the control would be a no-op for them — and offering one that changes
  /// nothing is worse than offering none (mobile plan §5.5).
  final CurriculumAudience? audience;

  final ActivityProgressStatus? progress;

  String get trimmedTerm => term.trim();

  /// True once there is something to send. An empty query is not run at all:
  /// `/library/search` with no `q` and no filters would return the first twenty
  /// rows of the whole library, which is the Library tab's job, not this
  /// screen's.
  bool get isRunnable =>
      trimmedTerm.isNotEmpty ||
      subjectId != null ||
      gradeLevelId != null ||
      contentNodeId != null ||
      type != null ||
      audience != null ||
      progress != null;

  /// Whether anything beyond the text term is narrowing the results — what the
  /// filter chip's badge and the empty state's "clear filters" action read.
  bool get hasFilters =>
      subjectId != null ||
      gradeLevelId != null ||
      contentNodeId != null ||
      type != null ||
      audience != null ||
      progress != null;

  int get filterCount => <Object?>[
    subjectId,
    gradeLevelId,
    contentNodeId,
    type,
    audience,
    progress,
  ].where((Object? value) => value != null).length;

  /// `copyWith` cannot clear a nullable field, so each clearable one takes an
  /// explicit flag. Verbose, and the alternative — a sentinel — reads worse at
  /// every call site.
  SearchQuery copyWith({
    String? term,
    String? subjectId,
    String? gradeLevelId,
    String? contentNodeId,
    ActivityResourceType? type,
    CurriculumAudience? audience,
    ActivityProgressStatus? progress,
    bool clearSubject = false,
    bool clearGradeLevel = false,
    bool clearContentNode = false,
    bool clearType = false,
    bool clearAudience = false,
    bool clearProgress = false,
  }) => SearchQuery(
    term: term ?? this.term,
    subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
    gradeLevelId: clearGradeLevel ? null : (gradeLevelId ?? this.gradeLevelId),
    contentNodeId: clearContentNode
        ? null
        : (contentNodeId ?? this.contentNodeId),
    type: clearType ? null : (type ?? this.type),
    audience: clearAudience ? null : (audience ?? this.audience),
    progress: clearProgress ? null : (progress ?? this.progress),
  );

  /// Drops every filter but keeps the term — what the "clear filters" action
  /// does, since clearing the text as well would leave nothing on screen to
  /// explain what happened.
  SearchQuery withoutFilters() => SearchQuery(term: term);

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.trimmedTerm == trimmedTerm &&
      other.subjectId == subjectId &&
      other.gradeLevelId == gradeLevelId &&
      other.contentNodeId == contentNodeId &&
      other.type == type &&
      other.audience == audience &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(
    trimmedTerm,
    subjectId,
    gradeLevelId,
    contentNodeId,
    type,
    audience,
    progress,
  );

  @override
  String toString() =>
      'SearchQuery("$trimmedTerm", filters: $filterCount)';
}

/// The wire value `?audience=` takes, or null for [CurriculumAudience.unknown]
/// — never send a filter value that didn't come from the server.
String? audienceWireValue(CurriculumAudience audience) => switch (audience) {
  CurriculumAudience.student => 'STUDENT',
  CurriculumAudience.teacher => 'TEACHER',
  CurriculumAudience.unknown => null,
};
