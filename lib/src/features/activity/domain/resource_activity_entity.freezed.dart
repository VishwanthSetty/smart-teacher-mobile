// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resource_activity_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityVideoEntity {

 String get id; String get title; int? get durationSecs;
/// Create a copy of ActivityVideoEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityVideoEntityCopyWith<ActivityVideoEntity> get copyWith => _$ActivityVideoEntityCopyWithImpl<ActivityVideoEntity>(this as ActivityVideoEntity, _$identity);

  /// Serializes this ActivityVideoEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityVideoEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,durationSecs);

@override
String toString() {
  return 'ActivityVideoEntity(id: $id, title: $title, durationSecs: $durationSecs)';
}


}

/// @nodoc
abstract mixin class $ActivityVideoEntityCopyWith<$Res>  {
  factory $ActivityVideoEntityCopyWith(ActivityVideoEntity value, $Res Function(ActivityVideoEntity) _then) = _$ActivityVideoEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, int? durationSecs
});




}
/// @nodoc
class _$ActivityVideoEntityCopyWithImpl<$Res>
    implements $ActivityVideoEntityCopyWith<$Res> {
  _$ActivityVideoEntityCopyWithImpl(this._self, this._then);

  final ActivityVideoEntity _self;
  final $Res Function(ActivityVideoEntity) _then;

/// Create a copy of ActivityVideoEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? durationSecs = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityVideoEntity].
extension ActivityVideoEntityPatterns on ActivityVideoEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityVideoEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityVideoEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityVideoEntity value)  $default,){
final _that = this;
switch (_that) {
case _ActivityVideoEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityVideoEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityVideoEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int? durationSecs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityVideoEntity() when $default != null:
return $default(_that.id,_that.title,_that.durationSecs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int? durationSecs)  $default,) {final _that = this;
switch (_that) {
case _ActivityVideoEntity():
return $default(_that.id,_that.title,_that.durationSecs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int? durationSecs)?  $default,) {final _that = this;
switch (_that) {
case _ActivityVideoEntity() when $default != null:
return $default(_that.id,_that.title,_that.durationSecs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityVideoEntity extends ActivityVideoEntity {
  const _ActivityVideoEntity({required this.id, this.title = '', this.durationSecs}): super._();
  factory _ActivityVideoEntity.fromJson(Map<String, dynamic> json) => _$ActivityVideoEntityFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  int? durationSecs;

/// Create a copy of ActivityVideoEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityVideoEntityCopyWith<_ActivityVideoEntity> get copyWith => __$ActivityVideoEntityCopyWithImpl<_ActivityVideoEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityVideoEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityVideoEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,durationSecs);

@override
String toString() {
  return 'ActivityVideoEntity(id: $id, title: $title, durationSecs: $durationSecs)';
}


}

/// @nodoc
abstract mixin class _$ActivityVideoEntityCopyWith<$Res> implements $ActivityVideoEntityCopyWith<$Res> {
  factory _$ActivityVideoEntityCopyWith(_ActivityVideoEntity value, $Res Function(_ActivityVideoEntity) _then) = __$ActivityVideoEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int? durationSecs
});




}
/// @nodoc
class __$ActivityVideoEntityCopyWithImpl<$Res>
    implements _$ActivityVideoEntityCopyWith<$Res> {
  __$ActivityVideoEntityCopyWithImpl(this._self, this._then);

  final _ActivityVideoEntity _self;
  final $Res Function(_ActivityVideoEntity) _then;

/// Create a copy of ActivityVideoEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? durationSecs = freezed,}) {
  return _then(_ActivityVideoEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ActivityDocumentEntity {

 String get id; String get title; int? get pageCount;
/// Create a copy of ActivityDocumentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityDocumentEntityCopyWith<ActivityDocumentEntity> get copyWith => _$ActivityDocumentEntityCopyWithImpl<ActivityDocumentEntity>(this as ActivityDocumentEntity, _$identity);

  /// Serializes this ActivityDocumentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityDocumentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,pageCount);

@override
String toString() {
  return 'ActivityDocumentEntity(id: $id, title: $title, pageCount: $pageCount)';
}


}

/// @nodoc
abstract mixin class $ActivityDocumentEntityCopyWith<$Res>  {
  factory $ActivityDocumentEntityCopyWith(ActivityDocumentEntity value, $Res Function(ActivityDocumentEntity) _then) = _$ActivityDocumentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, int? pageCount
});




}
/// @nodoc
class _$ActivityDocumentEntityCopyWithImpl<$Res>
    implements $ActivityDocumentEntityCopyWith<$Res> {
  _$ActivityDocumentEntityCopyWithImpl(this._self, this._then);

  final ActivityDocumentEntity _self;
  final $Res Function(ActivityDocumentEntity) _then;

/// Create a copy of ActivityDocumentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? pageCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityDocumentEntity].
extension ActivityDocumentEntityPatterns on ActivityDocumentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityDocumentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityDocumentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityDocumentEntity value)  $default,){
final _that = this;
switch (_that) {
case _ActivityDocumentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityDocumentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityDocumentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int? pageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityDocumentEntity() when $default != null:
return $default(_that.id,_that.title,_that.pageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int? pageCount)  $default,) {final _that = this;
switch (_that) {
case _ActivityDocumentEntity():
return $default(_that.id,_that.title,_that.pageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int? pageCount)?  $default,) {final _that = this;
switch (_that) {
case _ActivityDocumentEntity() when $default != null:
return $default(_that.id,_that.title,_that.pageCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityDocumentEntity extends ActivityDocumentEntity {
  const _ActivityDocumentEntity({required this.id, this.title = '', this.pageCount}): super._();
  factory _ActivityDocumentEntity.fromJson(Map<String, dynamic> json) => _$ActivityDocumentEntityFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  int? pageCount;

/// Create a copy of ActivityDocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityDocumentEntityCopyWith<_ActivityDocumentEntity> get copyWith => __$ActivityDocumentEntityCopyWithImpl<_ActivityDocumentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityDocumentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityDocumentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,pageCount);

@override
String toString() {
  return 'ActivityDocumentEntity(id: $id, title: $title, pageCount: $pageCount)';
}


}

/// @nodoc
abstract mixin class _$ActivityDocumentEntityCopyWith<$Res> implements $ActivityDocumentEntityCopyWith<$Res> {
  factory _$ActivityDocumentEntityCopyWith(_ActivityDocumentEntity value, $Res Function(_ActivityDocumentEntity) _then) = __$ActivityDocumentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int? pageCount
});




}
/// @nodoc
class __$ActivityDocumentEntityCopyWithImpl<$Res>
    implements _$ActivityDocumentEntityCopyWith<$Res> {
  __$ActivityDocumentEntityCopyWithImpl(this._self, this._then);

  final _ActivityDocumentEntity _self;
  final $Res Function(_ActivityDocumentEntity) _then;

/// Create a copy of ActivityDocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? pageCount = freezed,}) {
  return _then(_ActivityDocumentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ResourceActivityEntity {

 String get id;@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType get resourceType; String? get videoId; String? get documentId;@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus get status; int get positionSecs; int get coveredSecs; int get percent; int? get lastPage; int? get pageCount; DateTime? get markedCompleteAt; DateTime? get completedAt; DateTime? get firstAccessedAt; DateTime? get lastAccessedAt; DateTime? get updatedAt; ActivityVideoEntity? get video; ActivityDocumentEntity? get document;
/// Create a copy of ResourceActivityEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceActivityEntityCopyWith<ResourceActivityEntity> get copyWith => _$ResourceActivityEntityCopyWithImpl<ResourceActivityEntity>(this as ResourceActivityEntity, _$identity);

  /// Serializes this ResourceActivityEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceActivityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.positionSecs, positionSecs) || other.positionSecs == positionSecs)&&(identical(other.coveredSecs, coveredSecs) || other.coveredSecs == coveredSecs)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.markedCompleteAt, markedCompleteAt) || other.markedCompleteAt == markedCompleteAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.firstAccessedAt, firstAccessedAt) || other.firstAccessedAt == firstAccessedAt)&&(identical(other.lastAccessedAt, lastAccessedAt) || other.lastAccessedAt == lastAccessedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.video, video) || other.video == video)&&(identical(other.document, document) || other.document == document));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceType,videoId,documentId,status,positionSecs,coveredSecs,percent,lastPage,pageCount,markedCompleteAt,completedAt,firstAccessedAt,lastAccessedAt,updatedAt,video,document);

@override
String toString() {
  return 'ResourceActivityEntity(id: $id, resourceType: $resourceType, videoId: $videoId, documentId: $documentId, status: $status, positionSecs: $positionSecs, coveredSecs: $coveredSecs, percent: $percent, lastPage: $lastPage, pageCount: $pageCount, markedCompleteAt: $markedCompleteAt, completedAt: $completedAt, firstAccessedAt: $firstAccessedAt, lastAccessedAt: $lastAccessedAt, updatedAt: $updatedAt, video: $video, document: $document)';
}


}

/// @nodoc
abstract mixin class $ResourceActivityEntityCopyWith<$Res>  {
  factory $ResourceActivityEntityCopyWith(ResourceActivityEntity value, $Res Function(ResourceActivityEntity) _then) = _$ResourceActivityEntityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, String? videoId, String? documentId,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, int positionSecs, int coveredSecs, int percent, int? lastPage, int? pageCount, DateTime? markedCompleteAt, DateTime? completedAt, DateTime? firstAccessedAt, DateTime? lastAccessedAt, DateTime? updatedAt, ActivityVideoEntity? video, ActivityDocumentEntity? document
});


$ActivityVideoEntityCopyWith<$Res>? get video;$ActivityDocumentEntityCopyWith<$Res>? get document;

}
/// @nodoc
class _$ResourceActivityEntityCopyWithImpl<$Res>
    implements $ResourceActivityEntityCopyWith<$Res> {
  _$ResourceActivityEntityCopyWithImpl(this._self, this._then);

  final ResourceActivityEntity _self;
  final $Res Function(ResourceActivityEntity) _then;

/// Create a copy of ResourceActivityEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resourceType = null,Object? videoId = freezed,Object? documentId = freezed,Object? status = null,Object? positionSecs = null,Object? coveredSecs = null,Object? percent = null,Object? lastPage = freezed,Object? pageCount = freezed,Object? markedCompleteAt = freezed,Object? completedAt = freezed,Object? firstAccessedAt = freezed,Object? lastAccessedAt = freezed,Object? updatedAt = freezed,Object? video = freezed,Object? document = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,positionSecs: null == positionSecs ? _self.positionSecs : positionSecs // ignore: cast_nullable_to_non_nullable
as int,coveredSecs: null == coveredSecs ? _self.coveredSecs : coveredSecs // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,lastPage: freezed == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int?,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,markedCompleteAt: freezed == markedCompleteAt ? _self.markedCompleteAt : markedCompleteAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,firstAccessedAt: freezed == firstAccessedAt ? _self.firstAccessedAt : firstAccessedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAccessedAt: freezed == lastAccessedAt ? _self.lastAccessedAt : lastAccessedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as ActivityVideoEntity?,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as ActivityDocumentEntity?,
  ));
}
/// Create a copy of ResourceActivityEntity
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
}/// Create a copy of ResourceActivityEntity
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
}
}


/// Adds pattern-matching-related methods to [ResourceActivityEntity].
extension ResourceActivityEntityPatterns on ResourceActivityEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResourceActivityEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResourceActivityEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResourceActivityEntity value)  $default,){
final _that = this;
switch (_that) {
case _ResourceActivityEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResourceActivityEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ResourceActivityEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  int positionSecs,  int coveredSecs,  int percent,  int? lastPage,  int? pageCount,  DateTime? markedCompleteAt,  DateTime? completedAt,  DateTime? firstAccessedAt,  DateTime? lastAccessedAt,  DateTime? updatedAt,  ActivityVideoEntity? video,  ActivityDocumentEntity? document)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResourceActivityEntity() when $default != null:
return $default(_that.id,_that.resourceType,_that.videoId,_that.documentId,_that.status,_that.positionSecs,_that.coveredSecs,_that.percent,_that.lastPage,_that.pageCount,_that.markedCompleteAt,_that.completedAt,_that.firstAccessedAt,_that.lastAccessedAt,_that.updatedAt,_that.video,_that.document);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  int positionSecs,  int coveredSecs,  int percent,  int? lastPage,  int? pageCount,  DateTime? markedCompleteAt,  DateTime? completedAt,  DateTime? firstAccessedAt,  DateTime? lastAccessedAt,  DateTime? updatedAt,  ActivityVideoEntity? video,  ActivityDocumentEntity? document)  $default,) {final _that = this;
switch (_that) {
case _ResourceActivityEntity():
return $default(_that.id,_that.resourceType,_that.videoId,_that.documentId,_that.status,_that.positionSecs,_that.coveredSecs,_that.percent,_that.lastPage,_that.pageCount,_that.markedCompleteAt,_that.completedAt,_that.firstAccessedAt,_that.lastAccessedAt,_that.updatedAt,_that.video,_that.document);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  int positionSecs,  int coveredSecs,  int percent,  int? lastPage,  int? pageCount,  DateTime? markedCompleteAt,  DateTime? completedAt,  DateTime? firstAccessedAt,  DateTime? lastAccessedAt,  DateTime? updatedAt,  ActivityVideoEntity? video,  ActivityDocumentEntity? document)?  $default,) {final _that = this;
switch (_that) {
case _ResourceActivityEntity() when $default != null:
return $default(_that.id,_that.resourceType,_that.videoId,_that.documentId,_that.status,_that.positionSecs,_that.coveredSecs,_that.percent,_that.lastPage,_that.pageCount,_that.markedCompleteAt,_that.completedAt,_that.firstAccessedAt,_that.lastAccessedAt,_that.updatedAt,_that.video,_that.document);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResourceActivityEntity extends ResourceActivityEntity {
  const _ResourceActivityEntity({required this.id, @JsonKey(unknownEnumValue: ActivityResourceType.unknown) this.resourceType = ActivityResourceType.unknown, this.videoId, this.documentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) this.status = ActivityProgressStatus.unknown, this.positionSecs = 0, this.coveredSecs = 0, this.percent = 0, this.lastPage, this.pageCount, this.markedCompleteAt, this.completedAt, this.firstAccessedAt, this.lastAccessedAt, this.updatedAt, this.video, this.document}): super._();
  factory _ResourceActivityEntity.fromJson(Map<String, dynamic> json) => _$ResourceActivityEntityFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: ActivityResourceType.unknown) final  ActivityResourceType resourceType;
@override final  String? videoId;
@override final  String? documentId;
@override@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) final  ActivityProgressStatus status;
@override@JsonKey() final  int positionSecs;
@override@JsonKey() final  int coveredSecs;
@override@JsonKey() final  int percent;
@override final  int? lastPage;
@override final  int? pageCount;
@override final  DateTime? markedCompleteAt;
@override final  DateTime? completedAt;
@override final  DateTime? firstAccessedAt;
@override final  DateTime? lastAccessedAt;
@override final  DateTime? updatedAt;
@override final  ActivityVideoEntity? video;
@override final  ActivityDocumentEntity? document;

/// Create a copy of ResourceActivityEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResourceActivityEntityCopyWith<_ResourceActivityEntity> get copyWith => __$ResourceActivityEntityCopyWithImpl<_ResourceActivityEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResourceActivityEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResourceActivityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.positionSecs, positionSecs) || other.positionSecs == positionSecs)&&(identical(other.coveredSecs, coveredSecs) || other.coveredSecs == coveredSecs)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.markedCompleteAt, markedCompleteAt) || other.markedCompleteAt == markedCompleteAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.firstAccessedAt, firstAccessedAt) || other.firstAccessedAt == firstAccessedAt)&&(identical(other.lastAccessedAt, lastAccessedAt) || other.lastAccessedAt == lastAccessedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.video, video) || other.video == video)&&(identical(other.document, document) || other.document == document));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceType,videoId,documentId,status,positionSecs,coveredSecs,percent,lastPage,pageCount,markedCompleteAt,completedAt,firstAccessedAt,lastAccessedAt,updatedAt,video,document);

@override
String toString() {
  return 'ResourceActivityEntity(id: $id, resourceType: $resourceType, videoId: $videoId, documentId: $documentId, status: $status, positionSecs: $positionSecs, coveredSecs: $coveredSecs, percent: $percent, lastPage: $lastPage, pageCount: $pageCount, markedCompleteAt: $markedCompleteAt, completedAt: $completedAt, firstAccessedAt: $firstAccessedAt, lastAccessedAt: $lastAccessedAt, updatedAt: $updatedAt, video: $video, document: $document)';
}


}

/// @nodoc
abstract mixin class _$ResourceActivityEntityCopyWith<$Res> implements $ResourceActivityEntityCopyWith<$Res> {
  factory _$ResourceActivityEntityCopyWith(_ResourceActivityEntity value, $Res Function(_ResourceActivityEntity) _then) = __$ResourceActivityEntityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, String? videoId, String? documentId,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, int positionSecs, int coveredSecs, int percent, int? lastPage, int? pageCount, DateTime? markedCompleteAt, DateTime? completedAt, DateTime? firstAccessedAt, DateTime? lastAccessedAt, DateTime? updatedAt, ActivityVideoEntity? video, ActivityDocumentEntity? document
});


@override $ActivityVideoEntityCopyWith<$Res>? get video;@override $ActivityDocumentEntityCopyWith<$Res>? get document;

}
/// @nodoc
class __$ResourceActivityEntityCopyWithImpl<$Res>
    implements _$ResourceActivityEntityCopyWith<$Res> {
  __$ResourceActivityEntityCopyWithImpl(this._self, this._then);

  final _ResourceActivityEntity _self;
  final $Res Function(_ResourceActivityEntity) _then;

/// Create a copy of ResourceActivityEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resourceType = null,Object? videoId = freezed,Object? documentId = freezed,Object? status = null,Object? positionSecs = null,Object? coveredSecs = null,Object? percent = null,Object? lastPage = freezed,Object? pageCount = freezed,Object? markedCompleteAt = freezed,Object? completedAt = freezed,Object? firstAccessedAt = freezed,Object? lastAccessedAt = freezed,Object? updatedAt = freezed,Object? video = freezed,Object? document = freezed,}) {
  return _then(_ResourceActivityEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,positionSecs: null == positionSecs ? _self.positionSecs : positionSecs // ignore: cast_nullable_to_non_nullable
as int,coveredSecs: null == coveredSecs ? _self.coveredSecs : coveredSecs // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,lastPage: freezed == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int?,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,markedCompleteAt: freezed == markedCompleteAt ? _self.markedCompleteAt : markedCompleteAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,firstAccessedAt: freezed == firstAccessedAt ? _self.firstAccessedAt : firstAccessedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAccessedAt: freezed == lastAccessedAt ? _self.lastAccessedAt : lastAccessedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as ActivityVideoEntity?,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as ActivityDocumentEntity?,
  ));
}

/// Create a copy of ResourceActivityEntity
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
}/// Create a copy of ResourceActivityEntity
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
}
}

// dart format on
