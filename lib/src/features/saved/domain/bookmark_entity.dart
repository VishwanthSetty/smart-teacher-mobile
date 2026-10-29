import 'package:freezed_annotation/freezed_annotation.dart';

import '../../activity/domain/resource_activity_entity.dart';

part 'bookmark_entity.freezed.dart';
part 'bookmark_entity.g.dart';

/// The nested `collection` a bookmark may be filed into.
///
/// Only ever present for a teacher: students have no collections at all, and
/// their Saved list is simply the bookmarks whose `collectionId` is null
/// (backend plan §1.2).
@freezed
abstract class BookmarkCollectionRef with _$BookmarkCollectionRef {
  const factory BookmarkCollectionRef({
    required String id,
    @Default('') String name,
  }) = _BookmarkCollectionRef;

  const BookmarkCollectionRef._();

  factory BookmarkCollectionRef.fromJson(Map<String, dynamic> json) =>
      _$BookmarkCollectionRefFromJson(json);
}

/// One row of `GET /me/bookmarks` (backend plan §1.2, mobile plan §5.4).
///
/// Reuses [ActivityVideoEntity] / [ActivityDocumentEntity] rather than
/// modelling two more nested shapes: the bookmark endpoint selects the same
/// `{ id, title, durationSecs }` and `{ id, title, pageCount }` the activity
/// rows carry, and one nested type per resource keeps a saved card and a
/// history row captioned identically.
///
/// Every field but [id] is optional or defaulted, for the same reason as
/// `ResourceActivityEntity`: a row whose resource was deleted between the query
/// and the include must degrade to an unlabelled card, not fail the grid.
@freezed
abstract class BookmarkEntity with _$BookmarkEntity {
  const factory BookmarkEntity({
    required String id,
    @JsonKey(unknownEnumValue: ActivityResourceType.unknown)
    @Default(ActivityResourceType.unknown)
    ActivityResourceType resourceType,
    String? videoId,
    String? documentId,
    String? collectionId,
    DateTime? createdAt,
    ActivityVideoEntity? video,
    ActivityDocumentEntity? document,
    BookmarkCollectionRef? collection,
  }) = _BookmarkEntity;

  const BookmarkEntity._();

  factory BookmarkEntity.fromJson(Map<String, dynamic> json) =>
      _$BookmarkEntityFromJson(json);

  /// Exactly one of the two id columns is non-null server-side (a CHECK
  /// constraint enforces it), so falling through them is unambiguous.
  String get resourceId =>
      videoId ?? documentId ?? video?.id ?? document?.id ?? '';

  /// Prefers the row's own `resourceType`, then infers from whichever id came.
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

  /// Whether this save is filed into a collection. **Unfiled is a state, not a
  /// gap**: deleting a collection un-files its bookmarks rather than unsaving
  /// them, so a null [collectionId] is where those land (backend plan §1.2).
  bool get isUnfiled => (collectionId ?? collection?.id) == null;

  String get title {
    final String? videoTitle = _trimToNull(video?.title);
    final String? documentTitle = _trimToNull(document?.title);
    return videoTitle ??
        documentTitle ??
        (isVideo ? 'Untitled video' : 'Untitled document');
  }
}

String? _trimToNull(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
