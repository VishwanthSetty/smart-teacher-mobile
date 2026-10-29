// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookmarkCollectionRef {

 String get id; String get name;
/// Create a copy of BookmarkCollectionRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkCollectionRefCopyWith<BookmarkCollectionRef> get copyWith => _$BookmarkCollectionRefCopyWithImpl<BookmarkCollectionRef>(this as BookmarkCollectionRef, _$identity);

  /// Serializes this BookmarkCollectionRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkCollectionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'BookmarkCollectionRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $BookmarkCollectionRefCopyWith<$Res>  {
  factory $BookmarkCollectionRefCopyWith(BookmarkCollectionRef value, $Res Function(BookmarkCollectionRef) _then) = _$BookmarkCollectionRefCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$BookmarkCollectionRefCopyWithImpl<$Res>
    implements $BookmarkCollectionRefCopyWith<$Res> {
  _$BookmarkCollectionRefCopyWithImpl(this._self, this._then);

  final BookmarkCollectionRef _self;
  final $Res Function(BookmarkCollectionRef) _then;

/// Create a copy of BookmarkCollectionRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookmarkCollectionRef].
extension BookmarkCollectionRefPatterns on BookmarkCollectionRef {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkCollectionRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkCollectionRef() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkCollectionRef value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkCollectionRef():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkCollectionRef value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkCollectionRef() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkCollectionRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _BookmarkCollectionRef():
return $default(_that.id,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkCollectionRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkCollectionRef extends BookmarkCollectionRef {
  const _BookmarkCollectionRef({required this.id, this.name = ''}): super._();
  factory _BookmarkCollectionRef.fromJson(Map<String, dynamic> json) => _$BookmarkCollectionRefFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;

/// Create a copy of BookmarkCollectionRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkCollectionRefCopyWith<_BookmarkCollectionRef> get copyWith => __$BookmarkCollectionRefCopyWithImpl<_BookmarkCollectionRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkCollectionRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkCollectionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'BookmarkCollectionRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$BookmarkCollectionRefCopyWith<$Res> implements $BookmarkCollectionRefCopyWith<$Res> {
  factory _$BookmarkCollectionRefCopyWith(_BookmarkCollectionRef value, $Res Function(_BookmarkCollectionRef) _then) = __$BookmarkCollectionRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$BookmarkCollectionRefCopyWithImpl<$Res>
    implements _$BookmarkCollectionRefCopyWith<$Res> {
  __$BookmarkCollectionRefCopyWithImpl(this._self, this._then);

  final _BookmarkCollectionRef _self;
  final $Res Function(_BookmarkCollectionRef) _then;

/// Create a copy of BookmarkCollectionRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_BookmarkCollectionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BookmarkEntity {

 String get id;@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType get resourceType; String? get videoId; String? get documentId; String? get collectionId; DateTime? get createdAt; ActivityVideoEntity? get video; ActivityDocumentEntity? get document; BookmarkCollectionRef? get collection;
/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkEntityCopyWith<BookmarkEntity> get copyWith => _$BookmarkEntityCopyWithImpl<BookmarkEntity>(this as BookmarkEntity, _$identity);

  /// Serializes this BookmarkEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.video, video) || other.video == video)&&(identical(other.document, document) || other.document == document)&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceType,videoId,documentId,collectionId,createdAt,video,document,collection);

@override
String toString() {
  return 'BookmarkEntity(id: $id, resourceType: $resourceType, videoId: $videoId, documentId: $documentId, collectionId: $collectionId, createdAt: $createdAt, video: $video, document: $document, collection: $collection)';
}


}

/// @nodoc
abstract mixin class $BookmarkEntityCopyWith<$Res>  {
  factory $BookmarkEntityCopyWith(BookmarkEntity value, $Res Function(BookmarkEntity) _then) = _$BookmarkEntityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, String? videoId, String? documentId, String? collectionId, DateTime? createdAt, ActivityVideoEntity? video, ActivityDocumentEntity? document, BookmarkCollectionRef? collection
});


$ActivityVideoEntityCopyWith<$Res>? get video;$ActivityDocumentEntityCopyWith<$Res>? get document;$BookmarkCollectionRefCopyWith<$Res>? get collection;

}
/// @nodoc
class _$BookmarkEntityCopyWithImpl<$Res>
    implements $BookmarkEntityCopyWith<$Res> {
  _$BookmarkEntityCopyWithImpl(this._self, this._then);

  final BookmarkEntity _self;
  final $Res Function(BookmarkEntity) _then;

/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resourceType = null,Object? videoId = freezed,Object? documentId = freezed,Object? collectionId = freezed,Object? createdAt = freezed,Object? video = freezed,Object? document = freezed,Object? collection = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as ActivityVideoEntity?,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as ActivityDocumentEntity?,collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as BookmarkCollectionRef?,
  ));
}
/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityVideoEntityCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $ActivityVideoEntityCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityDocumentEntityCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $ActivityDocumentEntityCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookmarkCollectionRefCopyWith<$Res>? get collection {
    if (_self.collection == null) {
    return null;
  }

  return $BookmarkCollectionRefCopyWith<$Res>(_self.collection!, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookmarkEntity].
extension BookmarkEntityPatterns on BookmarkEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkEntity value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId,  String? collectionId,  DateTime? createdAt,  ActivityVideoEntity? video,  ActivityDocumentEntity? document,  BookmarkCollectionRef? collection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkEntity() when $default != null:
return $default(_that.id,_that.resourceType,_that.videoId,_that.documentId,_that.collectionId,_that.createdAt,_that.video,_that.document,_that.collection);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId,  String? collectionId,  DateTime? createdAt,  ActivityVideoEntity? video,  ActivityDocumentEntity? document,  BookmarkCollectionRef? collection)  $default,) {final _that = this;
switch (_that) {
case _BookmarkEntity():
return $default(_that.id,_that.resourceType,_that.videoId,_that.documentId,_that.collectionId,_that.createdAt,_that.video,_that.document,_that.collection);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId,  String? collectionId,  DateTime? createdAt,  ActivityVideoEntity? video,  ActivityDocumentEntity? document,  BookmarkCollectionRef? collection)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkEntity() when $default != null:
return $default(_that.id,_that.resourceType,_that.videoId,_that.documentId,_that.collectionId,_that.createdAt,_that.video,_that.document,_that.collection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkEntity extends BookmarkEntity {
  const _BookmarkEntity({required this.id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown) this.resourceType = ActivityResourceType.unknown, this.videoId, this.documentId, this.collectionId, this.createdAt, this.video, this.document, this.collection}): super._();
  factory _BookmarkEntity.fromJson(Map<String, dynamic> json) => _$BookmarkEntityFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: ActivityResourceType.unknown) final  ActivityResourceType resourceType;
@override final  String? videoId;
@override final  String? documentId;
@override final  String? collectionId;
@override final  DateTime? createdAt;
@override final  ActivityVideoEntity? video;
@override final  ActivityDocumentEntity? document;
@override final  BookmarkCollectionRef? collection;

/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkEntityCopyWith<_BookmarkEntity> get copyWith => __$BookmarkEntityCopyWithImpl<_BookmarkEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.video, video) || other.video == video)&&(identical(other.document, document) || other.document == document)&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceType,videoId,documentId,collectionId,createdAt,video,document,collection);

@override
String toString() {
  return 'BookmarkEntity(id: $id, resourceType: $resourceType, videoId: $videoId, documentId: $documentId, collectionId: $collectionId, createdAt: $createdAt, video: $video, document: $document, collection: $collection)';
}


}

/// @nodoc
abstract mixin class _$BookmarkEntityCopyWith<$Res> implements $BookmarkEntityCopyWith<$Res> {
  factory _$BookmarkEntityCopyWith(_BookmarkEntity value, $Res Function(_BookmarkEntity) _then) = __$BookmarkEntityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, String? videoId, String? documentId, String? collectionId, DateTime? createdAt, ActivityVideoEntity? video, ActivityDocumentEntity? document, BookmarkCollectionRef? collection
});


@override $ActivityVideoEntityCopyWith<$Res>? get video;@override $ActivityDocumentEntityCopyWith<$Res>? get document;@override $BookmarkCollectionRefCopyWith<$Res>? get collection;

}
/// @nodoc
class __$BookmarkEntityCopyWithImpl<$Res>
    implements _$BookmarkEntityCopyWith<$Res> {
  __$BookmarkEntityCopyWithImpl(this._self, this._then);

  final _BookmarkEntity _self;
  final $Res Function(_BookmarkEntity) _then;

/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resourceType = null,Object? videoId = freezed,Object? documentId = freezed,Object? collectionId = freezed,Object? createdAt = freezed,Object? video = freezed,Object? document = freezed,Object? collection = freezed,}) {
  return _then(_BookmarkEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as ActivityVideoEntity?,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as ActivityDocumentEntity?,collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as BookmarkCollectionRef?,
  ));
}

/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityVideoEntityCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $ActivityVideoEntityCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityDocumentEntityCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $ActivityDocumentEntityCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of BookmarkEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookmarkCollectionRefCopyWith<$Res>? get collection {
    if (_self.collection == null) {
    return null;
  }

  return $BookmarkCollectionRefCopyWith<$Res>(_self.collection!, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}

// dart format on
