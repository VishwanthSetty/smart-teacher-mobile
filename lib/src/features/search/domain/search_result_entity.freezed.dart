// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchResultNode {

 String get title; String? get curriculumId;
/// Create a copy of SearchResultNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultNodeCopyWith<SearchResultNode> get copyWith => _$SearchResultNodeCopyWithImpl<SearchResultNode>(this as SearchResultNode, _$identity);

  /// Serializes this SearchResultNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResultNode&&(identical(other.title, title) || other.title == title)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,curriculumId);

@override
String toString() {
  return 'SearchResultNode(title: $title, curriculumId: $curriculumId)';
}


}

/// @nodoc
abstract mixin class $SearchResultNodeCopyWith<$Res>  {
  factory $SearchResultNodeCopyWith(SearchResultNode value, $Res Function(SearchResultNode) _then) = _$SearchResultNodeCopyWithImpl;
@useResult
$Res call({
 String title, String? curriculumId
});




}
/// @nodoc
class _$SearchResultNodeCopyWithImpl<$Res>
    implements $SearchResultNodeCopyWith<$Res> {
  _$SearchResultNodeCopyWithImpl(this._self, this._then);

  final SearchResultNode _self;
  final $Res Function(SearchResultNode) _then;

/// Create a copy of SearchResultNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? curriculumId = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,curriculumId: freezed == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResultNode].
extension SearchResultNodePatterns on SearchResultNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResultNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResultNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResultNode value)  $default,){
final _that = this;
switch (_that) {
case _SearchResultNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResultNode value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResultNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? curriculumId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResultNode() when $default != null:
return $default(_that.title,_that.curriculumId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? curriculumId)  $default,) {final _that = this;
switch (_that) {
case _SearchResultNode():
return $default(_that.title,_that.curriculumId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? curriculumId)?  $default,) {final _that = this;
switch (_that) {
case _SearchResultNode() when $default != null:
return $default(_that.title,_that.curriculumId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchResultNode extends SearchResultNode {
  const _SearchResultNode({this.title = '', this.curriculumId}): super._();
  factory _SearchResultNode.fromJson(Map<String, dynamic> json) => _$SearchResultNodeFromJson(json);

@override@JsonKey() final  String title;
@override final  String? curriculumId;

/// Create a copy of SearchResultNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultNodeCopyWith<_SearchResultNode> get copyWith => __$SearchResultNodeCopyWithImpl<_SearchResultNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResultNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResultNode&&(identical(other.title, title) || other.title == title)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,curriculumId);

@override
String toString() {
  return 'SearchResultNode(title: $title, curriculumId: $curriculumId)';
}


}

/// @nodoc
abstract mixin class _$SearchResultNodeCopyWith<$Res> implements $SearchResultNodeCopyWith<$Res> {
  factory _$SearchResultNodeCopyWith(_SearchResultNode value, $Res Function(_SearchResultNode) _then) = __$SearchResultNodeCopyWithImpl;
@override @useResult
$Res call({
 String title, String? curriculumId
});




}
/// @nodoc
class __$SearchResultNodeCopyWithImpl<$Res>
    implements _$SearchResultNodeCopyWith<$Res> {
  __$SearchResultNodeCopyWithImpl(this._self, this._then);

  final _SearchResultNode _self;
  final $Res Function(_SearchResultNode) _then;

/// Create a copy of SearchResultNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? curriculumId = freezed,}) {
  return _then(_SearchResultNode(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,curriculumId: freezed == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SearchResultEntity {

 String get id; String get title; String? get description;@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType get resourceType; int? get durationSecs; int? get pageCount; SearchResultNode? get node;
/// Create a copy of SearchResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultEntityCopyWith<SearchResultEntity> get copyWith => _$SearchResultEntityCopyWithImpl<SearchResultEntity>(this as SearchResultEntity, _$identity);

  /// Serializes this SearchResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResultEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.node, node) || other.node == node));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,resourceType,durationSecs,pageCount,node);

@override
String toString() {
  return 'SearchResultEntity(id: $id, title: $title, description: $description, resourceType: $resourceType, durationSecs: $durationSecs, pageCount: $pageCount, node: $node)';
}


}

/// @nodoc
abstract mixin class $SearchResultEntityCopyWith<$Res>  {
  factory $SearchResultEntityCopyWith(SearchResultEntity value, $Res Function(SearchResultEntity) _then) = _$SearchResultEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, int? durationSecs, int? pageCount, SearchResultNode? node
});


$SearchResultNodeCopyWith<$Res>? get node;

}
/// @nodoc
class _$SearchResultEntityCopyWithImpl<$Res>
    implements $SearchResultEntityCopyWith<$Res> {
  _$SearchResultEntityCopyWithImpl(this._self, this._then);

  final SearchResultEntity _self;
  final $Res Function(SearchResultEntity) _then;

/// Create a copy of SearchResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? resourceType = null,Object? durationSecs = freezed,Object? pageCount = freezed,Object? node = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,node: freezed == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as SearchResultNode?,
  ));
}
/// Create a copy of SearchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultNodeCopyWith<$Res>? get node {
    if (_self.node == null) {
    return null;
  }

  return $SearchResultNodeCopyWith<$Res>(_self.node!, (value) {
    return _then(_self.copyWith(node: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchResultEntity].
extension SearchResultEntityPatterns on SearchResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _SearchResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  int? durationSecs,  int? pageCount,  SearchResultNode? node)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResultEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.resourceType,_that.durationSecs,_that.pageCount,_that.node);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  int? durationSecs,  int? pageCount,  SearchResultNode? node)  $default,) {final _that = this;
switch (_that) {
case _SearchResultEntity():
return $default(_that.id,_that.title,_that.description,_that.resourceType,_that.durationSecs,_that.pageCount,_that.node);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  int? durationSecs,  int? pageCount,  SearchResultNode? node)?  $default,) {final _that = this;
switch (_that) {
case _SearchResultEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.resourceType,_that.durationSecs,_that.pageCount,_that.node);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchResultEntity extends SearchResultEntity {
  const _SearchResultEntity({required this.id, this.title = '', this.description, @JsonKey(unknownEnumValue: ActivityResourceType.unknown) this.resourceType = ActivityResourceType.unknown, this.durationSecs, this.pageCount, this.node}): super._();
  factory _SearchResultEntity.fromJson(Map<String, dynamic> json) => _$SearchResultEntityFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  String? description;
@override@JsonKey(unknownEnumValue: ActivityResourceType.unknown) final  ActivityResourceType resourceType;
@override final  int? durationSecs;
@override final  int? pageCount;
@override final  SearchResultNode? node;

/// Create a copy of SearchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultEntityCopyWith<_SearchResultEntity> get copyWith => __$SearchResultEntityCopyWithImpl<_SearchResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResultEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.node, node) || other.node == node));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,resourceType,durationSecs,pageCount,node);

@override
String toString() {
  return 'SearchResultEntity(id: $id, title: $title, description: $description, resourceType: $resourceType, durationSecs: $durationSecs, pageCount: $pageCount, node: $node)';
}


}

/// @nodoc
abstract mixin class _$SearchResultEntityCopyWith<$Res> implements $SearchResultEntityCopyWith<$Res> {
  factory _$SearchResultEntityCopyWith(_SearchResultEntity value, $Res Function(_SearchResultEntity) _then) = __$SearchResultEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, int? durationSecs, int? pageCount, SearchResultNode? node
});


@override $SearchResultNodeCopyWith<$Res>? get node;

}
/// @nodoc
class __$SearchResultEntityCopyWithImpl<$Res>
    implements _$SearchResultEntityCopyWith<$Res> {
  __$SearchResultEntityCopyWithImpl(this._self, this._then);

  final _SearchResultEntity _self;
  final $Res Function(_SearchResultEntity) _then;

/// Create a copy of SearchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? resourceType = null,Object? durationSecs = freezed,Object? pageCount = freezed,Object? node = freezed,}) {
  return _then(_SearchResultEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,node: freezed == node ? _self.node : node // ignore: cast_nullable_to_non_nullable
as SearchResultNode?,
  ));
}

/// Create a copy of SearchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultNodeCopyWith<$Res>? get node {
    if (_self.node == null) {
    return null;
  }

  return $SearchResultNodeCopyWith<$Res>(_self.node!, (value) {
    return _then(_self.copyWith(node: value));
  });
}
}

// dart format on
