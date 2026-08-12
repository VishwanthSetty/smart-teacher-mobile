// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_detail_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoEntity {

 String get id; String get title; String? get description; int? get durationSecs; String get contentNodeId; String get contentNodeTitle; String get curriculumId; String get gradeLevelId; String get subjectId;
/// Create a copy of VideoEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoEntityCopyWith<VideoEntity> get copyWith => _$VideoEntityCopyWithImpl<VideoEntity>(this as VideoEntity, _$identity);

  /// Serializes this VideoEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.contentNodeId, contentNodeId) || other.contentNodeId == contentNodeId)&&(identical(other.contentNodeTitle, contentNodeTitle) || other.contentNodeTitle == contentNodeTitle)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationSecs,contentNodeId,contentNodeTitle,curriculumId,gradeLevelId,subjectId);

@override
String toString() {
  return 'VideoEntity(id: $id, title: $title, description: $description, durationSecs: $durationSecs, contentNodeId: $contentNodeId, contentNodeTitle: $contentNodeTitle, curriculumId: $curriculumId, gradeLevelId: $gradeLevelId, subjectId: $subjectId)';
}


}

/// @nodoc
abstract mixin class $VideoEntityCopyWith<$Res>  {
  factory $VideoEntityCopyWith(VideoEntity value, $Res Function(VideoEntity) _then) = _$VideoEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, int? durationSecs, String contentNodeId, String contentNodeTitle, String curriculumId, String gradeLevelId, String subjectId
});




}
/// @nodoc
class _$VideoEntityCopyWithImpl<$Res>
    implements $VideoEntityCopyWith<$Res> {
  _$VideoEntityCopyWithImpl(this._self, this._then);

  final VideoEntity _self;
  final $Res Function(VideoEntity) _then;

/// Create a copy of VideoEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationSecs = freezed,Object? contentNodeId = null,Object? contentNodeTitle = null,Object? curriculumId = null,Object? gradeLevelId = null,Object? subjectId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,contentNodeId: null == contentNodeId ? _self.contentNodeId : contentNodeId // ignore: cast_nullable_to_non_nullable
as String,contentNodeTitle: null == contentNodeTitle ? _self.contentNodeTitle : contentNodeTitle // ignore: cast_nullable_to_non_nullable
as String,curriculumId: null == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoEntity].
extension VideoEntityPatterns on VideoEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoEntity value)  $default,){
final _that = this;
switch (_that) {
case _VideoEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoEntity value)?  $default,){
final _that = this;
switch (_that) {
case _VideoEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int? durationSecs,  String contentNodeId,  String contentNodeTitle,  String curriculumId,  String gradeLevelId,  String subjectId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationSecs,_that.contentNodeId,_that.contentNodeTitle,_that.curriculumId,_that.gradeLevelId,_that.subjectId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int? durationSecs,  String contentNodeId,  String contentNodeTitle,  String curriculumId,  String gradeLevelId,  String subjectId)  $default,) {final _that = this;
switch (_that) {
case _VideoEntity():
return $default(_that.id,_that.title,_that.description,_that.durationSecs,_that.contentNodeId,_that.contentNodeTitle,_that.curriculumId,_that.gradeLevelId,_that.subjectId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  int? durationSecs,  String contentNodeId,  String contentNodeTitle,  String curriculumId,  String gradeLevelId,  String subjectId)?  $default,) {final _that = this;
switch (_that) {
case _VideoEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationSecs,_that.contentNodeId,_that.contentNodeTitle,_that.curriculumId,_that.gradeLevelId,_that.subjectId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoEntity implements VideoEntity {
  const _VideoEntity({required this.id, required this.title, required this.description, required this.durationSecs, required this.contentNodeId, required this.contentNodeTitle, required this.curriculumId, required this.gradeLevelId, required this.subjectId});
  factory _VideoEntity.fromJson(Map<String, dynamic> json) => _$VideoEntityFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  int? durationSecs;
@override final  String contentNodeId;
@override final  String contentNodeTitle;
@override final  String curriculumId;
@override final  String gradeLevelId;
@override final  String subjectId;

/// Create a copy of VideoEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoEntityCopyWith<_VideoEntity> get copyWith => __$VideoEntityCopyWithImpl<_VideoEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.contentNodeId, contentNodeId) || other.contentNodeId == contentNodeId)&&(identical(other.contentNodeTitle, contentNodeTitle) || other.contentNodeTitle == contentNodeTitle)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationSecs,contentNodeId,contentNodeTitle,curriculumId,gradeLevelId,subjectId);

@override
String toString() {
  return 'VideoEntity(id: $id, title: $title, description: $description, durationSecs: $durationSecs, contentNodeId: $contentNodeId, contentNodeTitle: $contentNodeTitle, curriculumId: $curriculumId, gradeLevelId: $gradeLevelId, subjectId: $subjectId)';
}


}

/// @nodoc
abstract mixin class _$VideoEntityCopyWith<$Res> implements $VideoEntityCopyWith<$Res> {
  factory _$VideoEntityCopyWith(_VideoEntity value, $Res Function(_VideoEntity) _then) = __$VideoEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, int? durationSecs, String contentNodeId, String contentNodeTitle, String curriculumId, String gradeLevelId, String subjectId
});




}
/// @nodoc
class __$VideoEntityCopyWithImpl<$Res>
    implements _$VideoEntityCopyWith<$Res> {
  __$VideoEntityCopyWithImpl(this._self, this._then);

  final _VideoEntity _self;
  final $Res Function(_VideoEntity) _then;

/// Create a copy of VideoEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationSecs = freezed,Object? contentNodeId = null,Object? contentNodeTitle = null,Object? curriculumId = null,Object? gradeLevelId = null,Object? subjectId = null,}) {
  return _then(_VideoEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,contentNodeId: null == contentNodeId ? _self.contentNodeId : contentNodeId // ignore: cast_nullable_to_non_nullable
as String,contentNodeTitle: null == contentNodeTitle ? _self.contentNodeTitle : contentNodeTitle // ignore: cast_nullable_to_non_nullable
as String,curriculumId: null == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DocumentEntity {

 String get id; String get title; String? get description; String get contentNodeId; String get contentNodeTitle; String get curriculumId; String get gradeLevelId; String get subjectId;
/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<DocumentEntity> get copyWith => _$DocumentEntityCopyWithImpl<DocumentEntity>(this as DocumentEntity, _$identity);

  /// Serializes this DocumentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentNodeId, contentNodeId) || other.contentNodeId == contentNodeId)&&(identical(other.contentNodeTitle, contentNodeTitle) || other.contentNodeTitle == contentNodeTitle)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,contentNodeId,contentNodeTitle,curriculumId,gradeLevelId,subjectId);

@override
String toString() {
  return 'DocumentEntity(id: $id, title: $title, description: $description, contentNodeId: $contentNodeId, contentNodeTitle: $contentNodeTitle, curriculumId: $curriculumId, gradeLevelId: $gradeLevelId, subjectId: $subjectId)';
}


}

/// @nodoc
abstract mixin class $DocumentEntityCopyWith<$Res>  {
  factory $DocumentEntityCopyWith(DocumentEntity value, $Res Function(DocumentEntity) _then) = _$DocumentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String contentNodeId, String contentNodeTitle, String curriculumId, String gradeLevelId, String subjectId
});




}
/// @nodoc
class _$DocumentEntityCopyWithImpl<$Res>
    implements $DocumentEntityCopyWith<$Res> {
  _$DocumentEntityCopyWithImpl(this._self, this._then);

  final DocumentEntity _self;
  final $Res Function(DocumentEntity) _then;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? contentNodeId = null,Object? contentNodeTitle = null,Object? curriculumId = null,Object? gradeLevelId = null,Object? subjectId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,contentNodeId: null == contentNodeId ? _self.contentNodeId : contentNodeId // ignore: cast_nullable_to_non_nullable
as String,contentNodeTitle: null == contentNodeTitle ? _self.contentNodeTitle : contentNodeTitle // ignore: cast_nullable_to_non_nullable
as String,curriculumId: null == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentEntity].
extension DocumentEntityPatterns on DocumentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentEntity value)  $default,){
final _that = this;
switch (_that) {
case _DocumentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String contentNodeId,  String contentNodeTitle,  String curriculumId,  String gradeLevelId,  String subjectId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.contentNodeId,_that.contentNodeTitle,_that.curriculumId,_that.gradeLevelId,_that.subjectId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String contentNodeId,  String contentNodeTitle,  String curriculumId,  String gradeLevelId,  String subjectId)  $default,) {final _that = this;
switch (_that) {
case _DocumentEntity():
return $default(_that.id,_that.title,_that.description,_that.contentNodeId,_that.contentNodeTitle,_that.curriculumId,_that.gradeLevelId,_that.subjectId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String contentNodeId,  String contentNodeTitle,  String curriculumId,  String gradeLevelId,  String subjectId)?  $default,) {final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.contentNodeId,_that.contentNodeTitle,_that.curriculumId,_that.gradeLevelId,_that.subjectId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentEntity implements DocumentEntity {
  const _DocumentEntity({required this.id, required this.title, required this.description, required this.contentNodeId, required this.contentNodeTitle, required this.curriculumId, required this.gradeLevelId, required this.subjectId});
  factory _DocumentEntity.fromJson(Map<String, dynamic> json) => _$DocumentEntityFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String contentNodeId;
@override final  String contentNodeTitle;
@override final  String curriculumId;
@override final  String gradeLevelId;
@override final  String subjectId;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentEntityCopyWith<_DocumentEntity> get copyWith => __$DocumentEntityCopyWithImpl<_DocumentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentNodeId, contentNodeId) || other.contentNodeId == contentNodeId)&&(identical(other.contentNodeTitle, contentNodeTitle) || other.contentNodeTitle == contentNodeTitle)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,contentNodeId,contentNodeTitle,curriculumId,gradeLevelId,subjectId);

@override
String toString() {
  return 'DocumentEntity(id: $id, title: $title, description: $description, contentNodeId: $contentNodeId, contentNodeTitle: $contentNodeTitle, curriculumId: $curriculumId, gradeLevelId: $gradeLevelId, subjectId: $subjectId)';
}


}

/// @nodoc
abstract mixin class _$DocumentEntityCopyWith<$Res> implements $DocumentEntityCopyWith<$Res> {
  factory _$DocumentEntityCopyWith(_DocumentEntity value, $Res Function(_DocumentEntity) _then) = __$DocumentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String contentNodeId, String contentNodeTitle, String curriculumId, String gradeLevelId, String subjectId
});




}
/// @nodoc
class __$DocumentEntityCopyWithImpl<$Res>
    implements _$DocumentEntityCopyWith<$Res> {
  __$DocumentEntityCopyWithImpl(this._self, this._then);

  final _DocumentEntity _self;
  final $Res Function(_DocumentEntity) _then;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? contentNodeId = null,Object? contentNodeTitle = null,Object? curriculumId = null,Object? gradeLevelId = null,Object? subjectId = null,}) {
  return _then(_DocumentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,contentNodeId: null == contentNodeId ? _self.contentNodeId : contentNodeId // ignore: cast_nullable_to_non_nullable
as String,contentNodeTitle: null == contentNodeTitle ? _self.contentNodeTitle : contentNodeTitle // ignore: cast_nullable_to_non_nullable
as String,curriculumId: null == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
