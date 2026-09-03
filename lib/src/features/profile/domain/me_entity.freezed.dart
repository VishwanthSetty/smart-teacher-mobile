// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchoolSummary {

 String get id; String get name; String get slug;@JsonKey(unknownEnumValue: SchoolStatus.unknown) SchoolStatus get status;
/// Create a copy of SchoolSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolSummaryCopyWith<SchoolSummary> get copyWith => _$SchoolSummaryCopyWithImpl<SchoolSummary>(this as SchoolSummary, _$identity);

  /// Serializes this SchoolSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,status);

@override
String toString() {
  return 'SchoolSummary(id: $id, name: $name, slug: $slug, status: $status)';
}


}

/// @nodoc
abstract mixin class $SchoolSummaryCopyWith<$Res>  {
  factory $SchoolSummaryCopyWith(SchoolSummary value, $Res Function(SchoolSummary) _then) = _$SchoolSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug,@JsonKey(unknownEnumValue: SchoolStatus.unknown) SchoolStatus status
});




}
/// @nodoc
class _$SchoolSummaryCopyWithImpl<$Res>
    implements $SchoolSummaryCopyWith<$Res> {
  _$SchoolSummaryCopyWithImpl(this._self, this._then);

  final SchoolSummary _self;
  final $Res Function(SchoolSummary) _then;

/// Create a copy of SchoolSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SchoolStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolSummary].
extension SchoolSummaryPatterns on SchoolSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolSummary value)  $default,){
final _that = this;
switch (_that) {
case _SchoolSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug, @JsonKey(unknownEnumValue: SchoolStatus.unknown)  SchoolStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolSummary() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug, @JsonKey(unknownEnumValue: SchoolStatus.unknown)  SchoolStatus status)  $default,) {final _that = this;
switch (_that) {
case _SchoolSummary():
return $default(_that.id,_that.name,_that.slug,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug, @JsonKey(unknownEnumValue: SchoolStatus.unknown)  SchoolStatus status)?  $default,) {final _that = this;
switch (_that) {
case _SchoolSummary() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchoolSummary implements SchoolSummary {
  const _SchoolSummary({required this.id, required this.name, required this.slug, @JsonKey(unknownEnumValue: SchoolStatus.unknown) required this.status});
  factory _SchoolSummary.fromJson(Map<String, dynamic> json) => _$SchoolSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override@JsonKey(unknownEnumValue: SchoolStatus.unknown) final  SchoolStatus status;

/// Create a copy of SchoolSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolSummaryCopyWith<_SchoolSummary> get copyWith => __$SchoolSummaryCopyWithImpl<_SchoolSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,status);

@override
String toString() {
  return 'SchoolSummary(id: $id, name: $name, slug: $slug, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SchoolSummaryCopyWith<$Res> implements $SchoolSummaryCopyWith<$Res> {
  factory _$SchoolSummaryCopyWith(_SchoolSummary value, $Res Function(_SchoolSummary) _then) = __$SchoolSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug,@JsonKey(unknownEnumValue: SchoolStatus.unknown) SchoolStatus status
});




}
/// @nodoc
class __$SchoolSummaryCopyWithImpl<$Res>
    implements _$SchoolSummaryCopyWith<$Res> {
  __$SchoolSummaryCopyWithImpl(this._self, this._then);

  final _SchoolSummary _self;
  final $Res Function(_SchoolSummary) _then;

/// Create a copy of SchoolSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? status = null,}) {
  return _then(_SchoolSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SchoolStatus,
  ));
}


}


/// @nodoc
mixin _$StudentEnrollmentSummary {

 String get id; String get sectionId; String get sectionName; String get sectionLabel; String get gradeLevelId; String get gradeLevelName; int get gradeLevelRank; String? get rollNumber;
/// Create a copy of StudentEnrollmentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentEnrollmentSummaryCopyWith<StudentEnrollmentSummary> get copyWith => _$StudentEnrollmentSummaryCopyWithImpl<StudentEnrollmentSummary>(this as StudentEnrollmentSummary, _$identity);

  /// Serializes this StudentEnrollmentSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentEnrollmentSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.sectionLabel, sectionLabel) || other.sectionLabel == sectionLabel)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.gradeLevelRank, gradeLevelRank) || other.gradeLevelRank == gradeLevelRank)&&(identical(other.rollNumber, rollNumber) || other.rollNumber == rollNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sectionId,sectionName,sectionLabel,gradeLevelId,gradeLevelName,gradeLevelRank,rollNumber);

@override
String toString() {
  return 'StudentEnrollmentSummary(id: $id, sectionId: $sectionId, sectionName: $sectionName, sectionLabel: $sectionLabel, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, gradeLevelRank: $gradeLevelRank, rollNumber: $rollNumber)';
}


}

/// @nodoc
abstract mixin class $StudentEnrollmentSummaryCopyWith<$Res>  {
  factory $StudentEnrollmentSummaryCopyWith(StudentEnrollmentSummary value, $Res Function(StudentEnrollmentSummary) _then) = _$StudentEnrollmentSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String sectionId, String sectionName, String sectionLabel, String gradeLevelId, String gradeLevelName, int gradeLevelRank, String? rollNumber
});




}
/// @nodoc
class _$StudentEnrollmentSummaryCopyWithImpl<$Res>
    implements $StudentEnrollmentSummaryCopyWith<$Res> {
  _$StudentEnrollmentSummaryCopyWithImpl(this._self, this._then);

  final StudentEnrollmentSummary _self;
  final $Res Function(StudentEnrollmentSummary) _then;

/// Create a copy of StudentEnrollmentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sectionId = null,Object? sectionName = null,Object? sectionLabel = null,Object? gradeLevelId = null,Object? gradeLevelName = null,Object? gradeLevelRank = null,Object? rollNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,sectionName: null == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String,sectionLabel: null == sectionLabel ? _self.sectionLabel : sectionLabel // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelName: null == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String,gradeLevelRank: null == gradeLevelRank ? _self.gradeLevelRank : gradeLevelRank // ignore: cast_nullable_to_non_nullable
as int,rollNumber: freezed == rollNumber ? _self.rollNumber : rollNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentEnrollmentSummary].
extension StudentEnrollmentSummaryPatterns on StudentEnrollmentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentEnrollmentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentEnrollmentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentEnrollmentSummary value)  $default,){
final _that = this;
switch (_that) {
case _StudentEnrollmentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentEnrollmentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StudentEnrollmentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sectionId,  String sectionName,  String sectionLabel,  String gradeLevelId,  String gradeLevelName,  int gradeLevelRank,  String? rollNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentEnrollmentSummary() when $default != null:
return $default(_that.id,_that.sectionId,_that.sectionName,_that.sectionLabel,_that.gradeLevelId,_that.gradeLevelName,_that.gradeLevelRank,_that.rollNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sectionId,  String sectionName,  String sectionLabel,  String gradeLevelId,  String gradeLevelName,  int gradeLevelRank,  String? rollNumber)  $default,) {final _that = this;
switch (_that) {
case _StudentEnrollmentSummary():
return $default(_that.id,_that.sectionId,_that.sectionName,_that.sectionLabel,_that.gradeLevelId,_that.gradeLevelName,_that.gradeLevelRank,_that.rollNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sectionId,  String sectionName,  String sectionLabel,  String gradeLevelId,  String gradeLevelName,  int gradeLevelRank,  String? rollNumber)?  $default,) {final _that = this;
switch (_that) {
case _StudentEnrollmentSummary() when $default != null:
return $default(_that.id,_that.sectionId,_that.sectionName,_that.sectionLabel,_that.gradeLevelId,_that.gradeLevelName,_that.gradeLevelRank,_that.rollNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentEnrollmentSummary implements StudentEnrollmentSummary {
  const _StudentEnrollmentSummary({required this.id, required this.sectionId, required this.sectionName, required this.sectionLabel, required this.gradeLevelId, required this.gradeLevelName, required this.gradeLevelRank, this.rollNumber});
  factory _StudentEnrollmentSummary.fromJson(Map<String, dynamic> json) => _$StudentEnrollmentSummaryFromJson(json);

@override final  String id;
@override final  String sectionId;
@override final  String sectionName;
@override final  String sectionLabel;
@override final  String gradeLevelId;
@override final  String gradeLevelName;
@override final  int gradeLevelRank;
@override final  String? rollNumber;

/// Create a copy of StudentEnrollmentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentEnrollmentSummaryCopyWith<_StudentEnrollmentSummary> get copyWith => __$StudentEnrollmentSummaryCopyWithImpl<_StudentEnrollmentSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentEnrollmentSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentEnrollmentSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.sectionLabel, sectionLabel) || other.sectionLabel == sectionLabel)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.gradeLevelRank, gradeLevelRank) || other.gradeLevelRank == gradeLevelRank)&&(identical(other.rollNumber, rollNumber) || other.rollNumber == rollNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sectionId,sectionName,sectionLabel,gradeLevelId,gradeLevelName,gradeLevelRank,rollNumber);

@override
String toString() {
  return 'StudentEnrollmentSummary(id: $id, sectionId: $sectionId, sectionName: $sectionName, sectionLabel: $sectionLabel, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, gradeLevelRank: $gradeLevelRank, rollNumber: $rollNumber)';
}


}

/// @nodoc
abstract mixin class _$StudentEnrollmentSummaryCopyWith<$Res> implements $StudentEnrollmentSummaryCopyWith<$Res> {
  factory _$StudentEnrollmentSummaryCopyWith(_StudentEnrollmentSummary value, $Res Function(_StudentEnrollmentSummary) _then) = __$StudentEnrollmentSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String sectionId, String sectionName, String sectionLabel, String gradeLevelId, String gradeLevelName, int gradeLevelRank, String? rollNumber
});




}
/// @nodoc
class __$StudentEnrollmentSummaryCopyWithImpl<$Res>
    implements _$StudentEnrollmentSummaryCopyWith<$Res> {
  __$StudentEnrollmentSummaryCopyWithImpl(this._self, this._then);

  final _StudentEnrollmentSummary _self;
  final $Res Function(_StudentEnrollmentSummary) _then;

/// Create a copy of StudentEnrollmentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sectionId = null,Object? sectionName = null,Object? sectionLabel = null,Object? gradeLevelId = null,Object? gradeLevelName = null,Object? gradeLevelRank = null,Object? rollNumber = freezed,}) {
  return _then(_StudentEnrollmentSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,sectionName: null == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String,sectionLabel: null == sectionLabel ? _self.sectionLabel : sectionLabel // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: null == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String,gradeLevelName: null == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String,gradeLevelRank: null == gradeLevelRank ? _self.gradeLevelRank : gradeLevelRank // ignore: cast_nullable_to_non_nullable
as int,rollNumber: freezed == rollNumber ? _self.rollNumber : rollNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MeEntity {

 String get id; String get email; String get name;@JsonKey(unknownEnumValue: UserRole.unknown) UserRole get role; String get schoolId; SchoolSummary get school; StudentEnrollmentSummary? get enrollment;
/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeEntityCopyWith<MeEntity> get copyWith => _$MeEntityCopyWithImpl<MeEntity>(this as MeEntity, _$identity);

  /// Serializes this MeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.school, school) || other.school == school)&&(identical(other.enrollment, enrollment) || other.enrollment == enrollment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,role,schoolId,school,enrollment);

@override
String toString() {
  return 'MeEntity(id: $id, email: $email, name: $name, role: $role, schoolId: $schoolId, school: $school, enrollment: $enrollment)';
}


}

/// @nodoc
abstract mixin class $MeEntityCopyWith<$Res>  {
  factory $MeEntityCopyWith(MeEntity value, $Res Function(MeEntity) _then) = _$MeEntityCopyWithImpl;
@useResult
$Res call({
 String id, String email, String name,@JsonKey(unknownEnumValue: UserRole.unknown) UserRole role, String schoolId, SchoolSummary school, StudentEnrollmentSummary? enrollment
});


$SchoolSummaryCopyWith<$Res> get school;$StudentEnrollmentSummaryCopyWith<$Res>? get enrollment;

}
/// @nodoc
class _$MeEntityCopyWithImpl<$Res>
    implements $MeEntityCopyWith<$Res> {
  _$MeEntityCopyWithImpl(this._self, this._then);

  final MeEntity _self;
  final $Res Function(MeEntity) _then;

/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = null,Object? role = null,Object? schoolId = null,Object? school = null,Object? enrollment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as SchoolSummary,enrollment: freezed == enrollment ? _self.enrollment : enrollment // ignore: cast_nullable_to_non_nullable
as StudentEnrollmentSummary?,
  ));
}
/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SchoolSummaryCopyWith<$Res> get school {
  
  return $SchoolSummaryCopyWith<$Res>(_self.school, (value) {
    return _then(_self.copyWith(school: value));
  });
}/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentEnrollmentSummaryCopyWith<$Res>? get enrollment {
    if (_self.enrollment == null) {
    return null;
  }

  return $StudentEnrollmentSummaryCopyWith<$Res>(_self.enrollment!, (value) {
    return _then(_self.copyWith(enrollment: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeEntity].
extension MeEntityPatterns on MeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeEntity value)  $default,){
final _that = this;
switch (_that) {
case _MeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String name, @JsonKey(unknownEnumValue: UserRole.unknown)  UserRole role,  String schoolId,  SchoolSummary school,  StudentEnrollmentSummary? enrollment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeEntity() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.role,_that.schoolId,_that.school,_that.enrollment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String name, @JsonKey(unknownEnumValue: UserRole.unknown)  UserRole role,  String schoolId,  SchoolSummary school,  StudentEnrollmentSummary? enrollment)  $default,) {final _that = this;
switch (_that) {
case _MeEntity():
return $default(_that.id,_that.email,_that.name,_that.role,_that.schoolId,_that.school,_that.enrollment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String name, @JsonKey(unknownEnumValue: UserRole.unknown)  UserRole role,  String schoolId,  SchoolSummary school,  StudentEnrollmentSummary? enrollment)?  $default,) {final _that = this;
switch (_that) {
case _MeEntity() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.role,_that.schoolId,_that.school,_that.enrollment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeEntity extends MeEntity {
  const _MeEntity({required this.id, required this.email, required this.name, @JsonKey(unknownEnumValue: UserRole.unknown) required this.role, required this.schoolId, required this.school, this.enrollment}): super._();
  factory _MeEntity.fromJson(Map<String, dynamic> json) => _$MeEntityFromJson(json);

@override final  String id;
@override final  String email;
@override final  String name;
@override@JsonKey(unknownEnumValue: UserRole.unknown) final  UserRole role;
@override final  String schoolId;
@override final  SchoolSummary school;
@override final  StudentEnrollmentSummary? enrollment;

/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeEntityCopyWith<_MeEntity> get copyWith => __$MeEntityCopyWithImpl<_MeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.school, school) || other.school == school)&&(identical(other.enrollment, enrollment) || other.enrollment == enrollment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,role,schoolId,school,enrollment);

@override
String toString() {
  return 'MeEntity(id: $id, email: $email, name: $name, role: $role, schoolId: $schoolId, school: $school, enrollment: $enrollment)';
}


}

/// @nodoc
abstract mixin class _$MeEntityCopyWith<$Res> implements $MeEntityCopyWith<$Res> {
  factory _$MeEntityCopyWith(_MeEntity value, $Res Function(_MeEntity) _then) = __$MeEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String name,@JsonKey(unknownEnumValue: UserRole.unknown) UserRole role, String schoolId, SchoolSummary school, StudentEnrollmentSummary? enrollment
});


@override $SchoolSummaryCopyWith<$Res> get school;@override $StudentEnrollmentSummaryCopyWith<$Res>? get enrollment;

}
/// @nodoc
class __$MeEntityCopyWithImpl<$Res>
    implements _$MeEntityCopyWith<$Res> {
  __$MeEntityCopyWithImpl(this._self, this._then);

  final _MeEntity _self;
  final $Res Function(_MeEntity) _then;

/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = null,Object? role = null,Object? schoolId = null,Object? school = null,Object? enrollment = freezed,}) {
  return _then(_MeEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as SchoolSummary,enrollment: freezed == enrollment ? _self.enrollment : enrollment // ignore: cast_nullable_to_non_nullable
as StudentEnrollmentSummary?,
  ));
}

/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SchoolSummaryCopyWith<$Res> get school {
  
  return $SchoolSummaryCopyWith<$Res>(_self.school, (value) {
    return _then(_self.copyWith(school: value));
  });
}/// Create a copy of MeEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentEnrollmentSummaryCopyWith<$Res>? get enrollment {
    if (_self.enrollment == null) {
    return null;
  }

  return $StudentEnrollmentSummaryCopyWith<$Res>(_self.enrollment!, (value) {
    return _then(_self.copyWith(enrollment: value));
  });
}
}

// dart format on
