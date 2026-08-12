// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_assignment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeacherAssignmentEntity {

 String get id;// Kept because it is the one field that proves the response really was
// scoped to the actor who asked (§5.5.1).
 String get teacherId; String get subjectId; String get subjectName; String? get teacherName; String? get teacherEmail; String? get subjectCode;// The five that are null together on a school-wide grant.
 String? get sectionId; String? get sectionName; String? get gradeLevelId; String? get gradeLevelName; String? get sectionLabel; DateTime? get createdAt;
/// Create a copy of TeacherAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeacherAssignmentEntityCopyWith<TeacherAssignmentEntity> get copyWith => _$TeacherAssignmentEntityCopyWithImpl<TeacherAssignmentEntity>(this as TeacherAssignmentEntity, _$identity);

  /// Serializes this TeacherAssignmentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeacherAssignmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teacherId, teacherId) || other.teacherId == teacherId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.teacherName, teacherName) || other.teacherName == teacherName)&&(identical(other.teacherEmail, teacherEmail) || other.teacherEmail == teacherEmail)&&(identical(other.subjectCode, subjectCode) || other.subjectCode == subjectCode)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.sectionLabel, sectionLabel) || other.sectionLabel == sectionLabel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teacherId,subjectId,subjectName,teacherName,teacherEmail,subjectCode,sectionId,sectionName,gradeLevelId,gradeLevelName,sectionLabel,createdAt);

@override
String toString() {
  return 'TeacherAssignmentEntity(id: $id, teacherId: $teacherId, subjectId: $subjectId, subjectName: $subjectName, teacherName: $teacherName, teacherEmail: $teacherEmail, subjectCode: $subjectCode, sectionId: $sectionId, sectionName: $sectionName, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, sectionLabel: $sectionLabel, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TeacherAssignmentEntityCopyWith<$Res>  {
  factory $TeacherAssignmentEntityCopyWith(TeacherAssignmentEntity value, $Res Function(TeacherAssignmentEntity) _then) = _$TeacherAssignmentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String teacherId, String subjectId, String subjectName, String? teacherName, String? teacherEmail, String? subjectCode, String? sectionId, String? sectionName, String? gradeLevelId, String? gradeLevelName, String? sectionLabel, DateTime? createdAt
});




}
/// @nodoc
class _$TeacherAssignmentEntityCopyWithImpl<$Res>
    implements $TeacherAssignmentEntityCopyWith<$Res> {
  _$TeacherAssignmentEntityCopyWithImpl(this._self, this._then);

  final TeacherAssignmentEntity _self;
  final $Res Function(TeacherAssignmentEntity) _then;

/// Create a copy of TeacherAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teacherId = null,Object? subjectId = null,Object? subjectName = null,Object? teacherName = freezed,Object? teacherEmail = freezed,Object? subjectCode = freezed,Object? sectionId = freezed,Object? sectionName = freezed,Object? gradeLevelId = freezed,Object? gradeLevelName = freezed,Object? sectionLabel = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teacherId: null == teacherId ? _self.teacherId : teacherId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,teacherName: freezed == teacherName ? _self.teacherName : teacherName // ignore: cast_nullable_to_non_nullable
as String?,teacherEmail: freezed == teacherEmail ? _self.teacherEmail : teacherEmail // ignore: cast_nullable_to_non_nullable
as String?,subjectCode: freezed == subjectCode ? _self.subjectCode : subjectCode // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,sectionName: freezed == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,sectionLabel: freezed == sectionLabel ? _self.sectionLabel : sectionLabel // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TeacherAssignmentEntity].
extension TeacherAssignmentEntityPatterns on TeacherAssignmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeacherAssignmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeacherAssignmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeacherAssignmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _TeacherAssignmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeacherAssignmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TeacherAssignmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teacherId,  String subjectId,  String subjectName,  String? teacherName,  String? teacherEmail,  String? subjectCode,  String? sectionId,  String? sectionName,  String? gradeLevelId,  String? gradeLevelName,  String? sectionLabel,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeacherAssignmentEntity() when $default != null:
return $default(_that.id,_that.teacherId,_that.subjectId,_that.subjectName,_that.teacherName,_that.teacherEmail,_that.subjectCode,_that.sectionId,_that.sectionName,_that.gradeLevelId,_that.gradeLevelName,_that.sectionLabel,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teacherId,  String subjectId,  String subjectName,  String? teacherName,  String? teacherEmail,  String? subjectCode,  String? sectionId,  String? sectionName,  String? gradeLevelId,  String? gradeLevelName,  String? sectionLabel,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TeacherAssignmentEntity():
return $default(_that.id,_that.teacherId,_that.subjectId,_that.subjectName,_that.teacherName,_that.teacherEmail,_that.subjectCode,_that.sectionId,_that.sectionName,_that.gradeLevelId,_that.gradeLevelName,_that.sectionLabel,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teacherId,  String subjectId,  String subjectName,  String? teacherName,  String? teacherEmail,  String? subjectCode,  String? sectionId,  String? sectionName,  String? gradeLevelId,  String? gradeLevelName,  String? sectionLabel,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TeacherAssignmentEntity() when $default != null:
return $default(_that.id,_that.teacherId,_that.subjectId,_that.subjectName,_that.teacherName,_that.teacherEmail,_that.subjectCode,_that.sectionId,_that.sectionName,_that.gradeLevelId,_that.gradeLevelName,_that.sectionLabel,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeacherAssignmentEntity extends TeacherAssignmentEntity {
  const _TeacherAssignmentEntity({required this.id, required this.teacherId, required this.subjectId, required this.subjectName, this.teacherName, this.teacherEmail, this.subjectCode, this.sectionId, this.sectionName, this.gradeLevelId, this.gradeLevelName, this.sectionLabel, this.createdAt}): super._();
  factory _TeacherAssignmentEntity.fromJson(Map<String, dynamic> json) => _$TeacherAssignmentEntityFromJson(json);

@override final  String id;
// Kept because it is the one field that proves the response really was
// scoped to the actor who asked (§5.5.1).
@override final  String teacherId;
@override final  String subjectId;
@override final  String subjectName;
@override final  String? teacherName;
@override final  String? teacherEmail;
@override final  String? subjectCode;
// The five that are null together on a school-wide grant.
@override final  String? sectionId;
@override final  String? sectionName;
@override final  String? gradeLevelId;
@override final  String? gradeLevelName;
@override final  String? sectionLabel;
@override final  DateTime? createdAt;

/// Create a copy of TeacherAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeacherAssignmentEntityCopyWith<_TeacherAssignmentEntity> get copyWith => __$TeacherAssignmentEntityCopyWithImpl<_TeacherAssignmentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeacherAssignmentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeacherAssignmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teacherId, teacherId) || other.teacherId == teacherId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.teacherName, teacherName) || other.teacherName == teacherName)&&(identical(other.teacherEmail, teacherEmail) || other.teacherEmail == teacherEmail)&&(identical(other.subjectCode, subjectCode) || other.subjectCode == subjectCode)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.sectionLabel, sectionLabel) || other.sectionLabel == sectionLabel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teacherId,subjectId,subjectName,teacherName,teacherEmail,subjectCode,sectionId,sectionName,gradeLevelId,gradeLevelName,sectionLabel,createdAt);

@override
String toString() {
  return 'TeacherAssignmentEntity(id: $id, teacherId: $teacherId, subjectId: $subjectId, subjectName: $subjectName, teacherName: $teacherName, teacherEmail: $teacherEmail, subjectCode: $subjectCode, sectionId: $sectionId, sectionName: $sectionName, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, sectionLabel: $sectionLabel, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TeacherAssignmentEntityCopyWith<$Res> implements $TeacherAssignmentEntityCopyWith<$Res> {
  factory _$TeacherAssignmentEntityCopyWith(_TeacherAssignmentEntity value, $Res Function(_TeacherAssignmentEntity) _then) = __$TeacherAssignmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String teacherId, String subjectId, String subjectName, String? teacherName, String? teacherEmail, String? subjectCode, String? sectionId, String? sectionName, String? gradeLevelId, String? gradeLevelName, String? sectionLabel, DateTime? createdAt
});




}
/// @nodoc
class __$TeacherAssignmentEntityCopyWithImpl<$Res>
    implements _$TeacherAssignmentEntityCopyWith<$Res> {
  __$TeacherAssignmentEntityCopyWithImpl(this._self, this._then);

  final _TeacherAssignmentEntity _self;
  final $Res Function(_TeacherAssignmentEntity) _then;

/// Create a copy of TeacherAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teacherId = null,Object? subjectId = null,Object? subjectName = null,Object? teacherName = freezed,Object? teacherEmail = freezed,Object? subjectCode = freezed,Object? sectionId = freezed,Object? sectionName = freezed,Object? gradeLevelId = freezed,Object? gradeLevelName = freezed,Object? sectionLabel = freezed,Object? createdAt = freezed,}) {
  return _then(_TeacherAssignmentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teacherId: null == teacherId ? _self.teacherId : teacherId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,teacherName: freezed == teacherName ? _self.teacherName : teacherName // ignore: cast_nullable_to_non_nullable
as String?,teacherEmail: freezed == teacherEmail ? _self.teacherEmail : teacherEmail // ignore: cast_nullable_to_non_nullable
as String?,subjectCode: freezed == subjectCode ? _self.subjectCode : subjectCode // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,sectionName: freezed == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,sectionLabel: freezed == sectionLabel ? _self.sectionLabel : sectionLabel // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
