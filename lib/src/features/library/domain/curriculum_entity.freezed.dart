// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curriculum_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurriculumEntity {

 String get id; String get gradeLevelId; String get gradeLevelName; String get subjectId; String get subjectName;@JsonKey(unknownEnumValue: CurriculumAudience.unknown) CurriculumAudience get audience;@JsonKey(unknownEnumValue: CurriculumStatus.unknown) CurriculumStatus get status;// The schema is an authoring concept the mobile app doesn't render, and a
// draft curriculum can arrive without one — modelled, nullable, unused.
 String? get schemaId; String? get schemaName;// Null for anything not yet published.
 DateTime? get publishedAt;// Defaulted rather than required: a curriculum with no content at all is a
// legitimate state (§6.4), and older payloads may omit a zero count
// entirely. A missing count must not fail the whole list.
 int get nodeCount; int get videoCount; int get documentCount;
/// Create a copy of CurriculumEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurriculumEntityCopyWith<CurriculumEntity> get copyWith => _$CurriculumEntityCopyWithImpl<CurriculumEntity>(this as CurriculumEntity, _$identity);

  /// Serializes this CurriculumEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurriculumEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.status, status) || other.status == status)&&(identical(other.schemaId, schemaId) || other.schemaId == schemaId)&&(identical(other.schemaName, schemaName) || other.schemaName == schemaName)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.nodeCount, nodeCount) || other.nodeCount == nodeCount)&&(identical(other.videoCount, videoCount) || other.videoCount == videoCount)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gradeLevelId,gradeLevelName,subjectId,subjectName,audience,status,schemaId,schemaName,publishedAt,nodeCount,videoCount,documentCount);

@override
String toString() {
  return 'CurriculumEntity(id: $id, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, subjectId: $subjectId, subjectName: $subjectName, audience: $audience, status: $status, schemaId: $schemaId, schemaName: $schemaName, publishedAt: $publishedAt, nodeCount: $nodeCount, videoCount: $videoCount, documentCount: $documentCount)';
}


}

/// @nodoc
abstract mixin class $CurriculumEntityCopyWith<$Res>  {
  factory $CurriculumEntityCopyWith(CurriculumEntity value, $Res Function(CurriculumEntity) _then) = _$CurriculumEntityCopyWithImpl;
@useResult
$Res call({
 String id, String gradeLevelId, String gradeLevelName, String subjectId, String subjectName,@JsonKey(unknownEnumValue: CurriculumAudience.unknown) CurriculumAudience audience,@JsonKey(unknownEnumValue: CurriculumStatus.unknown) CurriculumStatus status, String? schemaId, String? schemaName, DateTime? publishedAt, int nodeCount, int videoCount, int documentCount
});




}
/// @nodoc
class _$CurriculumEntityCopyWithImpl<$Res>
    implements $CurriculumEntityCopyWith<$Res> {
  _$CurriculumEntityCopyWithImpl(this._self, this._then);

  final CurriculumEntity _self;
  final $Res Function(CurriculumEntity) _then;

/// Create a copy of CurriculumEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gradeLevelId = null,Object? gradeLevelName = null,Object? subjectId = null,Object? subjectName = null,Object? audience = null,Object? status = null,Object? schemaId = freezed,Object? schemaName = freezed,Object? publishedAt = freezed,Object? nodeCount = null,Object? videoCount = null,Object? documentCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelName: null == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as CurriculumAudience,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CurriculumStatus,schemaId: freezed == schemaId ? _self.schemaId : schemaId // ignore: cast_nullable_to_non_nullable
as String?,schemaName: freezed == schemaName ? _self.schemaName : schemaName // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nodeCount: null == nodeCount ? _self.nodeCount : nodeCount // ignore: cast_nullable_to_non_nullable
as int,videoCount: null == videoCount ? _self.videoCount : videoCount // ignore: cast_nullable_to_non_nullable
as int,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CurriculumEntity].
extension CurriculumEntityPatterns on CurriculumEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurriculumEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurriculumEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurriculumEntity value)  $default,){
final _that = this;
switch (_that) {
case _CurriculumEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurriculumEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CurriculumEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gradeLevelId,  String gradeLevelName,  String subjectId,  String subjectName, @JsonKey(unknownEnumValue: CurriculumAudience.unknown)  CurriculumAudience audience, @JsonKey(unknownEnumValue: CurriculumStatus.unknown)  CurriculumStatus status,  String? schemaId,  String? schemaName,  DateTime? publishedAt,  int nodeCount,  int videoCount,  int documentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurriculumEntity() when $default != null:
return $default(_that.id,_that.gradeLevelId,_that.gradeLevelName,_that.subjectId,_that.subjectName,_that.audience,_that.status,_that.schemaId,_that.schemaName,_that.publishedAt,_that.nodeCount,_that.videoCount,_that.documentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gradeLevelId,  String gradeLevelName,  String subjectId,  String subjectName, @JsonKey(unknownEnumValue: CurriculumAudience.unknown)  CurriculumAudience audience, @JsonKey(unknownEnumValue: CurriculumStatus.unknown)  CurriculumStatus status,  String? schemaId,  String? schemaName,  DateTime? publishedAt,  int nodeCount,  int videoCount,  int documentCount)  $default,) {final _that = this;
switch (_that) {
case _CurriculumEntity():
return $default(_that.id,_that.gradeLevelId,_that.gradeLevelName,_that.subjectId,_that.subjectName,_that.audience,_that.status,_that.schemaId,_that.schemaName,_that.publishedAt,_that.nodeCount,_that.videoCount,_that.documentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gradeLevelId,  String gradeLevelName,  String subjectId,  String subjectName, @JsonKey(unknownEnumValue: CurriculumAudience.unknown)  CurriculumAudience audience, @JsonKey(unknownEnumValue: CurriculumStatus.unknown)  CurriculumStatus status,  String? schemaId,  String? schemaName,  DateTime? publishedAt,  int nodeCount,  int videoCount,  int documentCount)?  $default,) {final _that = this;
switch (_that) {
case _CurriculumEntity() when $default != null:
return $default(_that.id,_that.gradeLevelId,_that.gradeLevelName,_that.subjectId,_that.subjectName,_that.audience,_that.status,_that.schemaId,_that.schemaName,_that.publishedAt,_that.nodeCount,_that.videoCount,_that.documentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurriculumEntity extends CurriculumEntity {
  const _CurriculumEntity({required this.id, required this.gradeLevelId, required this.gradeLevelName, required this.subjectId, required this.subjectName, @JsonKey(unknownEnumValue: CurriculumAudience.unknown) this.audience = CurriculumAudience.unknown, @JsonKey(unknownEnumValue: CurriculumStatus.unknown) this.status = CurriculumStatus.unknown, this.schemaId, this.schemaName, this.publishedAt, this.nodeCount = 0, this.videoCount = 0, this.documentCount = 0}): super._();
  factory _CurriculumEntity.fromJson(Map<String, dynamic> json) => _$CurriculumEntityFromJson(json);

@override final  String id;
@override final  String gradeLevelId;
@override final  String gradeLevelName;
@override final  String subjectId;
@override final  String subjectName;
@override@JsonKey(unknownEnumValue: CurriculumAudience.unknown) final  CurriculumAudience audience;
@override@JsonKey(unknownEnumValue: CurriculumStatus.unknown) final  CurriculumStatus status;
// The schema is an authoring concept the mobile app doesn't render, and a
// draft curriculum can arrive without one — modelled, nullable, unused.
@override final  String? schemaId;
@override final  String? schemaName;
// Null for anything not yet published.
@override final  DateTime? publishedAt;
// Defaulted rather than required: a curriculum with no content at all is a
// legitimate state (§6.4), and older payloads may omit a zero count
// entirely. A missing count must not fail the whole list.
@override@JsonKey() final  int nodeCount;
@override@JsonKey() final  int videoCount;
@override@JsonKey() final  int documentCount;

/// Create a copy of CurriculumEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurriculumEntityCopyWith<_CurriculumEntity> get copyWith => __$CurriculumEntityCopyWithImpl<_CurriculumEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurriculumEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurriculumEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.status, status) || other.status == status)&&(identical(other.schemaId, schemaId) || other.schemaId == schemaId)&&(identical(other.schemaName, schemaName) || other.schemaName == schemaName)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.nodeCount, nodeCount) || other.nodeCount == nodeCount)&&(identical(other.videoCount, videoCount) || other.videoCount == videoCount)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gradeLevelId,gradeLevelName,subjectId,subjectName,audience,status,schemaId,schemaName,publishedAt,nodeCount,videoCount,documentCount);

@override
String toString() {
  return 'CurriculumEntity(id: $id, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, subjectId: $subjectId, subjectName: $subjectName, audience: $audience, status: $status, schemaId: $schemaId, schemaName: $schemaName, publishedAt: $publishedAt, nodeCount: $nodeCount, videoCount: $videoCount, documentCount: $documentCount)';
}


}

/// @nodoc
abstract mixin class _$CurriculumEntityCopyWith<$Res> implements $CurriculumEntityCopyWith<$Res> {
  factory _$CurriculumEntityCopyWith(_CurriculumEntity value, $Res Function(_CurriculumEntity) _then) = __$CurriculumEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String gradeLevelId, String gradeLevelName, String subjectId, String subjectName,@JsonKey(unknownEnumValue: CurriculumAudience.unknown) CurriculumAudience audience,@JsonKey(unknownEnumValue: CurriculumStatus.unknown) CurriculumStatus status, String? schemaId, String? schemaName, DateTime? publishedAt, int nodeCount, int videoCount, int documentCount
});




}
/// @nodoc
class __$CurriculumEntityCopyWithImpl<$Res>
    implements _$CurriculumEntityCopyWith<$Res> {
  __$CurriculumEntityCopyWithImpl(this._self, this._then);

  final _CurriculumEntity _self;
  final $Res Function(_CurriculumEntity) _then;

/// Create a copy of CurriculumEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gradeLevelId = null,Object? gradeLevelName = null,Object? subjectId = null,Object? subjectName = null,Object? audience = null,Object? status = null,Object? schemaId = freezed,Object? schemaName = freezed,Object? publishedAt = freezed,Object? nodeCount = null,Object? videoCount = null,Object? documentCount = null,}) {
  return _then(_CurriculumEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelName: null == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as CurriculumAudience,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CurriculumStatus,schemaId: freezed == schemaId ? _self.schemaId : schemaId // ignore: cast_nullable_to_non_nullable
as String?,schemaName: freezed == schemaName ? _self.schemaName : schemaName // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nodeCount: null == nodeCount ? _self.nodeCount : nodeCount // ignore: cast_nullable_to_non_nullable
as int,videoCount: null == videoCount ? _self.videoCount : videoCount // ignore: cast_nullable_to_non_nullable
as int,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
