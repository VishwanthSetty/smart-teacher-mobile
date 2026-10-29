import 'package:freezed_annotation/freezed_annotation.dart';

import '../../activity/domain/resource_activity_entity.dart';

part 'search_result_entity.freezed.dart';
part 'search_result_entity.g.dart';

/// The nested `node` a hit belongs to — the chapter or sub-topic it hangs off.
@freezed
abstract class SearchResultNode with _$SearchResultNode {
  const factory SearchResultNode({
    @Default('') String title,
    String? curriculumId,
  }) = _SearchResultNode;

  const SearchResultNode._();

  factory SearchResultNode.fromJson(Map<String, dynamic> json) =>
      _$SearchResultNodeFromJson(json);
}

/// One hit from `GET /library/search` (backend plan §5.3).
///
/// The endpoint returns videos and documents in **one array**, each tagged with
/// `resourceType`, so this is one entity rather than two — the row differs only
/// in its glyph and in whether it captions a duration or a page count.
///
/// Results are filtered to the actor's resolved scope **before** the text query
/// runs, so an unreachable title can never appear even as a name (backend plan
/// §4.1). There is therefore no client-side filtering here of any kind.
@freezed
abstract class SearchResultEntity with _$SearchResultEntity {
  const factory SearchResultEntity({
    required String id,
    @Default('') String title,
    String? description,
    @JsonKey(unknownEnumValue: ActivityResourceType.unknown)
    @Default(ActivityResourceType.unknown)
    ActivityResourceType resourceType,
    int? durationSecs,
    int? pageCount,
    SearchResultNode? node,
  }) = _SearchResultEntity;

  const SearchResultEntity._();

  factory SearchResultEntity.fromJson(Map<String, dynamic> json) =>
      _$SearchResultEntityFromJson(json);

  /// Falls back to whichever field is populated rather than to the type alone:
  /// a video carries `durationSecs` and a document `pageCount`, so an untagged
  /// row is still placeable.
  ActivityResourceType get kind {
    if (resourceType != ActivityResourceType.unknown) {
      return resourceType;
    }
    if (pageCount != null) {
      return ActivityResourceType.document;
    }
    return ActivityResourceType.video;
  }

  bool get isVideo => kind == ActivityResourceType.video;

  String get displayTitle {
    final String trimmed = title.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return isVideo ? 'Untitled video' : 'Untitled document';
  }

  /// The chapter line under the title, or null when the payload omitted it.
  String? get nodeLabel {
    final String trimmed = node?.title.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
