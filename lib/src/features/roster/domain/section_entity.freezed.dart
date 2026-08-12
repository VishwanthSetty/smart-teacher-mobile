// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'section_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SectionEntity {

 String get id; String get name; String? get gradeLevelId; String? get gradeLevelName;// The server's own composed form, when it sends one. Mirrors
// `TeacherAssignmentEntity.sectionLabel`.
 String? get label;
/// Create a copy of SectionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionEntityCopyWith<SectionEntity> get copyWith => _$SectionEntityCopyWithImpl<SectionEntity>(this as SectionEntity, _$identity);

  /// Serializes this SectionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,gradeLevelId,gradeLevelName,label);

@override
String toString() {
  return 'SectionEntity(id: $id, name: $name, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, label: $label)';
}


}

/// @nodoc
abstract mixin class $SectionEntityCopyWith<$Res>  {
  factory $SectionEntityCopyWith(SectionEntity value, $Res Function(SectionEntity) _then) = _$SectionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? gradeLevelId, String? gradeLevelName, String? label
});




}
/// @nodoc
class _$SectionEntityCopyWithImpl<$Res>
    implements $SectionEntityCopyWith<$Res> {
  _$SectionEntityCopyWithImpl(this._self, this._then);

  final SectionEntity _self;
  final $Res Function(SectionEntity) _then;

/// Create a copy of SectionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? gradeLevelId = freezed,Object? gradeLevelName = freezed,Object? label = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SectionEntity].
extension SectionEntityPatterns on SectionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SectionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SectionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SectionEntity value)  $default,){
final _that = this;
switch (_that) {
case _SectionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SectionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SectionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? gradeLevelId,  String? gradeLevelName,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SectionEntity() when $default != null:
return $default(_that.id,_that.name,_that.gradeLevelId,_that.gradeLevelName,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? gradeLevelId,  String? gradeLevelName,  String? label)  $default,) {final _that = this;
switch (_that) {
case _SectionEntity():
return $default(_that.id,_that.name,_that.gradeLevelId,_that.gradeLevelName,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? gradeLevelId,  String? gradeLevelName,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _SectionEntity() when $default != null:
return $default(_that.id,_that.name,_that.gradeLevelId,_that.gradeLevelName,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SectionEntity extends SectionEntity {
  const _SectionEntity({required this.id, required this.name, this.gradeLevelId, this.gradeLevelName, this.label}): super._();
  factory _SectionEntity.fromJson(Map<String, dynamic> json) => _$SectionEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? gradeLevelId;
@override final  String? gradeLevelName;
// The server's own composed form, when it sends one. Mirrors
// `TeacherAssignmentEntity.sectionLabel`.
@override final  String? label;

/// Create a copy of SectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionEntityCopyWith<_SectionEntity> get copyWith => __$SectionEntityCopyWithImpl<_SectionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SectionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,gradeLevelId,gradeLevelName,label);

@override
String toString() {
  return 'SectionEntity(id: $id, name: $name, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SectionEntityCopyWith<$Res> implements $SectionEntityCopyWith<$Res> {
  factory _$SectionEntityCopyWith(_SectionEntity value, $Res Function(_SectionEntity) _then) = __$SectionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? gradeLevelId, String? gradeLevelName, String? label
});




}
/// @nodoc
class __$SectionEntityCopyWithImpl<$Res>
    implements _$SectionEntityCopyWith<$Res> {
  __$SectionEntityCopyWithImpl(this._self, this._then);

  final _SectionEntity _self;
  final $Res Function(_SectionEntity) _then;

/// Create a copy of SectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? gradeLevelId = freezed,Object? gradeLevelName = freezed,Object? label = freezed,}) {
  return _then(_SectionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
