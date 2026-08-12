import 'package:freezed_annotation/freezed_annotation.dart';

part 'curriculum_entity.freezed.dart';
part 'curriculum_entity.g.dart';

/// Who a curriculum is published to (PRD §8.3).
///
/// Purely descriptive here. The app **never** filters on it: `GET /curricula`
/// is already narrowed server-side to what this actor may see (§4), and a
/// client-side audience check would either duplicate that logic or contradict
/// it — a teacher legitimately sees `STUDENT`-audience curricula for the
/// grade/subject pairs they teach.
///
/// [unknown] is the landing spot for any value this build doesn't know, so an
/// audience added later can't break deserialisation of the whole list.
enum CurriculumAudience {
  @JsonValue('STUDENT')
  student,

  @JsonValue('TEACHER')
  teacher,

  unknown,
}

/// Publication state (PRD §8.3 documents `PUBLISHED`).
///
/// The other values are modelled so a non-published curriculum can be labelled
/// rather than silently rendered as if it were live; anything unrecognised
/// falls back to [unknown] and is labelled not at all.
enum CurriculumStatus {
  @JsonValue('PUBLISHED')
  published,

  @JsonValue('DRAFT')
  draft,

  @JsonValue('ARCHIVED')
  archived,

  unknown,
}

/// One row of `GET /curricula` (PRD §8.3) — a grade × subject pairing plus the
/// counts the library list (§5.4.1) shows on each card.
///
/// The counts are shallow totals for the whole curriculum; the per-node deep
/// counts live on the tree endpoint (§5.4.2), which is a separate screen.
@freezed
abstract class CurriculumEntity with _$CurriculumEntity {
  const factory CurriculumEntity({
    required String id,
    required String gradeLevelId,
    required String gradeLevelName,
    required String subjectId,
    required String subjectName,
    @JsonKey(unknownEnumValue: CurriculumAudience.unknown)
    @Default(CurriculumAudience.unknown)
    CurriculumAudience audience,
    @JsonKey(unknownEnumValue: CurriculumStatus.unknown)
    @Default(CurriculumStatus.unknown)
    CurriculumStatus status,
    // The schema is an authoring concept the mobile app doesn't render, and a
    // draft curriculum can arrive without one — modelled, nullable, unused.
    String? schemaId,
    String? schemaName,
    // Null for anything not yet published.
    DateTime? publishedAt,
    // Defaulted rather than required: a curriculum with no content at all is a
    // legitimate state (§6.4), and older payloads may omit a zero count
    // entirely. A missing count must not fail the whole list.
    @Default(0) int nodeCount,
    @Default(0) int videoCount,
    @Default(0) int documentCount,
  }) = _CurriculumEntity;

  const CurriculumEntity._();

  factory CurriculumEntity.fromJson(Map<String, dynamic> json) =>
      _$CurriculumEntityFromJson(json);

  /// True when there is nothing behind this row to open yet. Distinct from an
  /// empty *library*: the school is entitled to this curriculum, it just has
  /// no content in it.
  bool get isEmpty => nodeCount == 0 && videoCount == 0 && documentCount == 0;
}
