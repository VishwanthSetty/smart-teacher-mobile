// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_node_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContentItemEntity {

 String get id;// Defaulted rather than required: a document uploaded without a title
// should render as one untitled row, not fail the whole tree.
 String get title; String? get description;// Videos only, and only when the backend has probed the media.
 int? get durationSecs;// Documents only.
 String? get fileName;
/// Create a copy of ContentItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentItemEntityCopyWith<ContentItemEntity> get copyWith => _$ContentItemEntityCopyWithImpl<ContentItemEntity>(this as ContentItemEntity, _$identity);

  /// Serializes this ContentItemEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationSecs,fileName);

@override
String toString() {
  return 'ContentItemEntity(id: $id, title: $title, description: $description, durationSecs: $durationSecs, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $ContentItemEntityCopyWith<$Res>  {
  factory $ContentItemEntityCopyWith(ContentItemEntity value, $Res Function(ContentItemEntity) _then) = _$ContentItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, int? durationSecs, String? fileName
});




}
/// @nodoc
class _$ContentItemEntityCopyWithImpl<$Res>
    implements $ContentItemEntityCopyWith<$Res> {
  _$ContentItemEntityCopyWithImpl(this._self, this._then);

  final ContentItemEntity _self;
  final $Res Function(ContentItemEntity) _then;

/// Create a copy of ContentItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationSecs = freezed,Object? fileName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentItemEntity].
extension ContentItemEntityPatterns on ContentItemEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentItemEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _ContentItemEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ContentItemEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int? durationSecs,  String? fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationSecs,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int? durationSecs,  String? fileName)  $default,) {final _that = this;
switch (_that) {
case _ContentItemEntity():
return $default(_that.id,_that.title,_that.description,_that.durationSecs,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  int? durationSecs,  String? fileName)?  $default,) {final _that = this;
switch (_that) {
case _ContentItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationSecs,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentItemEntity extends ContentItemEntity {
  const _ContentItemEntity({required this.id, this.title = '', this.description, this.durationSecs, this.fileName}): super._();
  factory _ContentItemEntity.fromJson(Map<String, dynamic> json) => _$ContentItemEntityFromJson(json);

@override final  String id;
// Defaulted rather than required: a document uploaded without a title
// should render as one untitled row, not fail the whole tree.
@override@JsonKey() final  String title;
@override final  String? description;
// Videos only, and only when the backend has probed the media.
@override final  int? durationSecs;
// Documents only.
@override final  String? fileName;

/// Create a copy of ContentItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentItemEntityCopyWith<_ContentItemEntity> get copyWith => __$ContentItemEntityCopyWithImpl<_ContentItemEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentItemEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationSecs,fileName);

@override
String toString() {
  return 'ContentItemEntity(id: $id, title: $title, description: $description, durationSecs: $durationSecs, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$ContentItemEntityCopyWith<$Res> implements $ContentItemEntityCopyWith<$Res> {
  factory _$ContentItemEntityCopyWith(_ContentItemEntity value, $Res Function(_ContentItemEntity) _then) = __$ContentItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, int? durationSecs, String? fileName
});




}
/// @nodoc
class __$ContentItemEntityCopyWithImpl<$Res>
    implements _$ContentItemEntityCopyWith<$Res> {
  __$ContentItemEntityCopyWithImpl(this._self, this._then);

  final _ContentItemEntity _self;
  final $Res Function(_ContentItemEntity) _then;

/// Create a copy of ContentItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? durationSecs = freezed,Object? fileName = freezed,}) {
  return _then(_ContentItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContentNodeEntity {

 String get id; String get title; String? get description;// `children` is the documented shape; `nodes` is tolerated because the PRD
// (§5.4.2) names the payload without pinning its key, and a wrong guess
// would silently flatten every tree to its root level. See [_readChildren].
@JsonKey(readValue: _readChildren) List<ContentNodeEntity> get children; List<ContentItemEntity> get videos; List<ContentItemEntity> get documents;// Defaulted for the same reason the curriculum counts are (§8.3): a node
// with nothing in it is a legitimate state, and an omitted zero must not
// fail the whole tree. A missing count reads as "empty", which is also how
// the branch renders — the conservative direction.
 int get videoCountDeep; int get documentCountDeep;
/// Create a copy of ContentNodeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentNodeEntityCopyWith<ContentNodeEntity> get copyWith => _$ContentNodeEntityCopyWithImpl<ContentNodeEntity>(this as ContentNodeEntity, _$identity);

  /// Serializes this ContentNodeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentNodeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.children, children)&&const DeepCollectionEquality().equals(other.videos, videos)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.videoCountDeep, videoCountDeep) || other.videoCountDeep == videoCountDeep)&&(identical(other.documentCountDeep, documentCountDeep) || other.documentCountDeep == documentCountDeep));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(children),const DeepCollectionEquality().hash(videos),const DeepCollectionEquality().hash(documents),videoCountDeep,documentCountDeep);

@override
String toString() {
  return 'ContentNodeEntity(id: $id, title: $title, description: $description, children: $children, videos: $videos, documents: $documents, videoCountDeep: $videoCountDeep, documentCountDeep: $documentCountDeep)';
}


}

/// @nodoc
abstract mixin class $ContentNodeEntityCopyWith<$Res>  {
  factory $ContentNodeEntityCopyWith(ContentNodeEntity value, $Res Function(ContentNodeEntity) _then) = _$ContentNodeEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description,@JsonKey(readValue: _readChildren) List<ContentNodeEntity> children, List<ContentItemEntity> videos, List<ContentItemEntity> documents, int videoCountDeep, int documentCountDeep
});




}
/// @nodoc
class _$ContentNodeEntityCopyWithImpl<$Res>
    implements $ContentNodeEntityCopyWith<$Res> {
  _$ContentNodeEntityCopyWithImpl(this._self, this._then);

  final ContentNodeEntity _self;
  final $Res Function(ContentNodeEntity) _then;

/// Create a copy of ContentNodeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? children = null,Object? videos = null,Object? documents = null,Object? videoCountDeep = null,Object? documentCountDeep = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ContentNodeEntity>,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<ContentItemEntity>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<ContentItemEntity>,videoCountDeep: null == videoCountDeep ? _self.videoCountDeep : videoCountDeep // ignore: cast_nullable_to_non_nullable
as int,documentCountDeep: null == documentCountDeep ? _self.documentCountDeep : documentCountDeep // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentNodeEntity].
extension ContentNodeEntityPatterns on ContentNodeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentNodeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentNodeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentNodeEntity value)  $default,){
final _that = this;
switch (_that) {
case _ContentNodeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentNodeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ContentNodeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @JsonKey(readValue: _readChildren)  List<ContentNodeEntity> children,  List<ContentItemEntity> videos,  List<ContentItemEntity> documents,  int videoCountDeep,  int documentCountDeep)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentNodeEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.children,_that.videos,_that.documents,_that.videoCountDeep,_that.documentCountDeep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @JsonKey(readValue: _readChildren)  List<ContentNodeEntity> children,  List<ContentItemEntity> videos,  List<ContentItemEntity> documents,  int videoCountDeep,  int documentCountDeep)  $default,) {final _that = this;
switch (_that) {
case _ContentNodeEntity():
return $default(_that.id,_that.title,_that.description,_that.children,_that.videos,_that.documents,_that.videoCountDeep,_that.documentCountDeep);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description, @JsonKey(readValue: _readChildren)  List<ContentNodeEntity> children,  List<ContentItemEntity> videos,  List<ContentItemEntity> documents,  int videoCountDeep,  int documentCountDeep)?  $default,) {final _that = this;
switch (_that) {
case _ContentNodeEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.children,_that.videos,_that.documents,_that.videoCountDeep,_that.documentCountDeep);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentNodeEntity extends ContentNodeEntity {
  const _ContentNodeEntity({required this.id, this.title = '', this.description, @JsonKey(readValue: _readChildren) final  List<ContentNodeEntity> children = const <ContentNodeEntity>[], final  List<ContentItemEntity> videos = const <ContentItemEntity>[], final  List<ContentItemEntity> documents = const <ContentItemEntity>[], this.videoCountDeep = 0, this.documentCountDeep = 0}): _children = children,_videos = videos,_documents = documents,super._();
  factory _ContentNodeEntity.fromJson(Map<String, dynamic> json) => _$ContentNodeEntityFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  String? description;
// `children` is the documented shape; `nodes` is tolerated because the PRD
// (§5.4.2) names the payload without pinning its key, and a wrong guess
// would silently flatten every tree to its root level. See [_readChildren].
 final  List<ContentNodeEntity> _children;
// `children` is the documented shape; `nodes` is tolerated because the PRD
// (§5.4.2) names the payload without pinning its key, and a wrong guess
// would silently flatten every tree to its root level. See [_readChildren].
@override@JsonKey(readValue: _readChildren) List<ContentNodeEntity> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

 final  List<ContentItemEntity> _videos;
@override@JsonKey() List<ContentItemEntity> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

 final  List<ContentItemEntity> _documents;
@override@JsonKey() List<ContentItemEntity> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

// Defaulted for the same reason the curriculum counts are (§8.3): a node
// with nothing in it is a legitimate state, and an omitted zero must not
// fail the whole tree. A missing count reads as "empty", which is also how
// the branch renders — the conservative direction.
@override@JsonKey() final  int videoCountDeep;
@override@JsonKey() final  int documentCountDeep;

/// Create a copy of ContentNodeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentNodeEntityCopyWith<_ContentNodeEntity> get copyWith => __$ContentNodeEntityCopyWithImpl<_ContentNodeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentNodeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentNodeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._children, _children)&&const DeepCollectionEquality().equals(other._videos, _videos)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.videoCountDeep, videoCountDeep) || other.videoCountDeep == videoCountDeep)&&(identical(other.documentCountDeep, documentCountDeep) || other.documentCountDeep == documentCountDeep));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(_children),const DeepCollectionEquality().hash(_videos),const DeepCollectionEquality().hash(_documents),videoCountDeep,documentCountDeep);

@override
String toString() {
  return 'ContentNodeEntity(id: $id, title: $title, description: $description, children: $children, videos: $videos, documents: $documents, videoCountDeep: $videoCountDeep, documentCountDeep: $documentCountDeep)';
}


}

/// @nodoc
abstract mixin class _$ContentNodeEntityCopyWith<$Res> implements $ContentNodeEntityCopyWith<$Res> {
  factory _$ContentNodeEntityCopyWith(_ContentNodeEntity value, $Res Function(_ContentNodeEntity) _then) = __$ContentNodeEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description,@JsonKey(readValue: _readChildren) List<ContentNodeEntity> children, List<ContentItemEntity> videos, List<ContentItemEntity> documents, int videoCountDeep, int documentCountDeep
});




}
/// @nodoc
class __$ContentNodeEntityCopyWithImpl<$Res>
    implements _$ContentNodeEntityCopyWith<$Res> {
  __$ContentNodeEntityCopyWithImpl(this._self, this._then);

  final _ContentNodeEntity _self;
  final $Res Function(_ContentNodeEntity) _then;

/// Create a copy of ContentNodeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? children = null,Object? videos = null,Object? documents = null,Object? videoCountDeep = null,Object? documentCountDeep = null,}) {
  return _then(_ContentNodeEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ContentNodeEntity>,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<ContentItemEntity>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<ContentItemEntity>,videoCountDeep: null == videoCountDeep ? _self.videoCountDeep : videoCountDeep // ignore: cast_nullable_to_non_nullable
as int,documentCountDeep: null == documentCountDeep ? _self.documentCountDeep : documentCountDeep // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ContentTreeEntity {

 String? get curriculumId; String? get subjectName; String? get gradeLevelName;@JsonKey(readValue: _readNodes) List<ContentNodeEntity> get nodes;
/// Create a copy of ContentTreeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentTreeEntityCopyWith<ContentTreeEntity> get copyWith => _$ContentTreeEntityCopyWithImpl<ContentTreeEntity>(this as ContentTreeEntity, _$identity);

  /// Serializes this ContentTreeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentTreeEntity&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&const DeepCollectionEquality().equals(other.nodes, nodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,curriculumId,subjectName,gradeLevelName,const DeepCollectionEquality().hash(nodes));

@override
String toString() {
  return 'ContentTreeEntity(curriculumId: $curriculumId, subjectName: $subjectName, gradeLevelName: $gradeLevelName, nodes: $nodes)';
}


}

/// @nodoc
abstract mixin class $ContentTreeEntityCopyWith<$Res>  {
  factory $ContentTreeEntityCopyWith(ContentTreeEntity value, $Res Function(ContentTreeEntity) _then) = _$ContentTreeEntityCopyWithImpl;
@useResult
$Res call({
 String? curriculumId, String? subjectName, String? gradeLevelName,@JsonKey(readValue: _readNodes) List<ContentNodeEntity> nodes
});




}
/// @nodoc
class _$ContentTreeEntityCopyWithImpl<$Res>
    implements $ContentTreeEntityCopyWith<$Res> {
  _$ContentTreeEntityCopyWithImpl(this._self, this._then);

  final ContentTreeEntity _self;
  final $Res Function(ContentTreeEntity) _then;

/// Create a copy of ContentTreeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? curriculumId = freezed,Object? subjectName = freezed,Object? gradeLevelName = freezed,Object? nodes = null,}) {
  return _then(_self.copyWith(
curriculumId: freezed == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String?,subjectName: freezed == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<ContentNodeEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentTreeEntity].
extension ContentTreeEntityPatterns on ContentTreeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentTreeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentTreeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentTreeEntity value)  $default,){
final _that = this;
switch (_that) {
case _ContentTreeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentTreeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ContentTreeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? curriculumId,  String? subjectName,  String? gradeLevelName, @JsonKey(readValue: _readNodes)  List<ContentNodeEntity> nodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentTreeEntity() when $default != null:
return $default(_that.curriculumId,_that.subjectName,_that.gradeLevelName,_that.nodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? curriculumId,  String? subjectName,  String? gradeLevelName, @JsonKey(readValue: _readNodes)  List<ContentNodeEntity> nodes)  $default,) {final _that = this;
switch (_that) {
case _ContentTreeEntity():
return $default(_that.curriculumId,_that.subjectName,_that.gradeLevelName,_that.nodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? curriculumId,  String? subjectName,  String? gradeLevelName, @JsonKey(readValue: _readNodes)  List<ContentNodeEntity> nodes)?  $default,) {final _that = this;
switch (_that) {
case _ContentTreeEntity() when $default != null:
return $default(_that.curriculumId,_that.subjectName,_that.gradeLevelName,_that.nodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentTreeEntity extends ContentTreeEntity {
  const _ContentTreeEntity({this.curriculumId, this.subjectName, this.gradeLevelName, @JsonKey(readValue: _readNodes) final  List<ContentNodeEntity> nodes = const <ContentNodeEntity>[]}): _nodes = nodes,super._();
  factory _ContentTreeEntity.fromJson(Map<String, dynamic> json) => _$ContentTreeEntityFromJson(json);

@override final  String? curriculumId;
@override final  String? subjectName;
@override final  String? gradeLevelName;
 final  List<ContentNodeEntity> _nodes;
@override@JsonKey(readValue: _readNodes) List<ContentNodeEntity> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}


/// Create a copy of ContentTreeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentTreeEntityCopyWith<_ContentTreeEntity> get copyWith => __$ContentTreeEntityCopyWithImpl<_ContentTreeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentTreeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentTreeEntity&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&const DeepCollectionEquality().equals(other._nodes, _nodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,curriculumId,subjectName,gradeLevelName,const DeepCollectionEquality().hash(_nodes));

@override
String toString() {
  return 'ContentTreeEntity(curriculumId: $curriculumId, subjectName: $subjectName, gradeLevelName: $gradeLevelName, nodes: $nodes)';
}


}

/// @nodoc
abstract mixin class _$ContentTreeEntityCopyWith<$Res> implements $ContentTreeEntityCopyWith<$Res> {
  factory _$ContentTreeEntityCopyWith(_ContentTreeEntity value, $Res Function(_ContentTreeEntity) _then) = __$ContentTreeEntityCopyWithImpl;
@override @useResult
$Res call({
 String? curriculumId, String? subjectName, String? gradeLevelName,@JsonKey(readValue: _readNodes) List<ContentNodeEntity> nodes
});




}
/// @nodoc
class __$ContentTreeEntityCopyWithImpl<$Res>
    implements _$ContentTreeEntityCopyWith<$Res> {
  __$ContentTreeEntityCopyWithImpl(this._self, this._then);

  final _ContentTreeEntity _self;
  final $Res Function(_ContentTreeEntity) _then;

/// Create a copy of ContentTreeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? curriculumId = freezed,Object? subjectName = freezed,Object? gradeLevelName = freezed,Object? nodes = null,}) {
  return _then(_ContentTreeEntity(
curriculumId: freezed == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String?,subjectName: freezed == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<ContentNodeEntity>,
  ));
}


}

// dart format on
