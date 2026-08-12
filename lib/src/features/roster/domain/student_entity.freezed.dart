// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentEnrollmentEntity {

 String? get id; String? get sectionId; String? get sectionName; String? get gradeLevelId; String? get gradeLevelName; String? get rollNumber;
/// Create a copy of StudentEnrollmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentEnrollmentEntityCopyWith<StudentEnrollmentEntity> get copyWith => _$StudentEnrollmentEntityCopyWithImpl<StudentEnrollmentEntity>(this as StudentEnrollmentEntity, _$identity);

  /// Serializes this StudentEnrollmentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentEnrollmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.rollNumber, rollNumber) || other.rollNumber == rollNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sectionId,sectionName,gradeLevelId,gradeLevelName,rollNumber);

@override
String toString() {
  return 'StudentEnrollmentEntity(id: $id, sectionId: $sectionId, sectionName: $sectionName, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, rollNumber: $rollNumber)';
}


}

/// @nodoc
abstract mixin class $StudentEnrollmentEntityCopyWith<$Res>  {
  factory $StudentEnrollmentEntityCopyWith(StudentEnrollmentEntity value, $Res Function(StudentEnrollmentEntity) _then) = _$StudentEnrollmentEntityCopyWithImpl;
@useResult
$Res call({
 String? id, String? sectionId, String? sectionName, String? gradeLevelId, String? gradeLevelName, String? rollNumber
});




}
/// @nodoc
class _$StudentEnrollmentEntityCopyWithImpl<$Res>
    implements $StudentEnrollmentEntityCopyWith<$Res> {
  _$StudentEnrollmentEntityCopyWithImpl(this._self, this._then);

  final StudentEnrollmentEntity _self;
  final $Res Function(StudentEnrollmentEntity) _then;

/// Create a copy of StudentEnrollmentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? sectionId = freezed,Object? sectionName = freezed,Object? gradeLevelId = freezed,Object? gradeLevelName = freezed,Object? rollNumber = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,sectionName: freezed == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,rollNumber: freezed == rollNumber ? _self.rollNumber : rollNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentEnrollmentEntity].
extension StudentEnrollmentEntityPatterns on StudentEnrollmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentEnrollmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentEnrollmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentEnrollmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _StudentEnrollmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentEnrollmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _StudentEnrollmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? sectionId,  String? sectionName,  String? gradeLevelId,  String? gradeLevelName,  String? rollNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentEnrollmentEntity() when $default != null:
return $default(_that.id,_that.sectionId,_that.sectionName,_that.gradeLevelId,_that.gradeLevelName,_that.rollNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? sectionId,  String? sectionName,  String? gradeLevelId,  String? gradeLevelName,  String? rollNumber)  $default,) {final _that = this;
switch (_that) {
case _StudentEnrollmentEntity():
return $default(_that.id,_that.sectionId,_that.sectionName,_that.gradeLevelId,_that.gradeLevelName,_that.rollNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? sectionId,  String? sectionName,  String? gradeLevelId,  String? gradeLevelName,  String? rollNumber)?  $default,) {final _that = this;
switch (_that) {
case _StudentEnrollmentEntity() when $default != null:
return $default(_that.id,_that.sectionId,_that.sectionName,_that.gradeLevelId,_that.gradeLevelName,_that.rollNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentEnrollmentEntity extends StudentEnrollmentEntity {
  const _StudentEnrollmentEntity({this.id, this.sectionId, this.sectionName, this.gradeLevelId, this.gradeLevelName, this.rollNumber}): super._();
  factory _StudentEnrollmentEntity.fromJson(Map<String, dynamic> json) => _$StudentEnrollmentEntityFromJson(json);

@override final  String? id;
@override final  String? sectionId;
@override final  String? sectionName;
@override final  String? gradeLevelId;
@override final  String? gradeLevelName;
@override final  String? rollNumber;

/// Create a copy of StudentEnrollmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentEnrollmentEntityCopyWith<_StudentEnrollmentEntity> get copyWith => __$StudentEnrollmentEntityCopyWithImpl<_StudentEnrollmentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentEnrollmentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentEnrollmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.gradeLevelName, gradeLevelName) || other.gradeLevelName == gradeLevelName)&&(identical(other.rollNumber, rollNumber) || other.rollNumber == rollNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sectionId,sectionName,gradeLevelId,gradeLevelName,rollNumber);

@override
String toString() {
  return 'StudentEnrollmentEntity(id: $id, sectionId: $sectionId, sectionName: $sectionName, gradeLevelId: $gradeLevelId, gradeLevelName: $gradeLevelName, rollNumber: $rollNumber)';
}


}

/// @nodoc
abstract mixin class _$StudentEnrollmentEntityCopyWith<$Res> implements $StudentEnrollmentEntityCopyWith<$Res> {
  factory _$StudentEnrollmentEntityCopyWith(_StudentEnrollmentEntity value, $Res Function(_StudentEnrollmentEntity) _then) = __$StudentEnrollmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? sectionId, String? sectionName, String? gradeLevelId, String? gradeLevelName, String? rollNumber
});




}
/// @nodoc
class __$StudentEnrollmentEntityCopyWithImpl<$Res>
    implements _$StudentEnrollmentEntityCopyWith<$Res> {
  __$StudentEnrollmentEntityCopyWithImpl(this._self, this._then);

  final _StudentEnrollmentEntity _self;
  final $Res Function(_StudentEnrollmentEntity) _then;

/// Create a copy of StudentEnrollmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? sectionId = freezed,Object? sectionName = freezed,Object? gradeLevelId = freezed,Object? gradeLevelName = freezed,Object? rollNumber = freezed,}) {
  return _then(_StudentEnrollmentEntity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,sectionName: freezed == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,gradeLevelName: freezed == gradeLevelName ? _self.gradeLevelName : gradeLevelName // ignore: cast_nullable_to_non_nullable
as String?,rollNumber: freezed == rollNumber ? _self.rollNumber : rollNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StudentEntity {

 String get id; String? get email; String? get firstName; String? get lastName; String? get name;@JsonKey(unknownEnumValue: StudentStatus.unknown) StudentStatus get status; DateTime? get activatedAt; DateTime? get createdAt;// `null` is the documented unplaced-student case (§5.5.2), not a parse
// failure — see [isUnassigned].
 StudentEnrollmentEntity? get enrollment;
/// Create a copy of StudentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentEntityCopyWith<StudentEntity> get copyWith => _$StudentEntityCopyWithImpl<StudentEntity>(this as StudentEntity, _$identity);

  /// Serializes this StudentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.enrollment, enrollment) || other.enrollment == enrollment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,name,status,activatedAt,createdAt,enrollment);

@override
String toString() {
  return 'StudentEntity(id: $id, email: $email, firstName: $firstName, lastName: $lastName, name: $name, status: $status, activatedAt: $activatedAt, createdAt: $createdAt, enrollment: $enrollment)';
}


}

/// @nodoc
abstract mixin class $StudentEntityCopyWith<$Res>  {
  factory $StudentEntityCopyWith(StudentEntity value, $Res Function(StudentEntity) _then) = _$StudentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? email, String? firstName, String? lastName, String? name,@JsonKey(unknownEnumValue: StudentStatus.unknown) StudentStatus status, DateTime? activatedAt, DateTime? createdAt, StudentEnrollmentEntity? enrollment
});


$StudentEnrollmentEntityCopyWith<$Res>? get enrollment;

}
/// @nodoc
class _$StudentEntityCopyWithImpl<$Res>
    implements $StudentEntityCopyWith<$Res> {
  _$StudentEntityCopyWithImpl(this._self, this._then);

  final StudentEntity _self;
  final $Res Function(StudentEntity) _then;

/// Create a copy of StudentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? name = freezed,Object? status = null,Object? activatedAt = freezed,Object? createdAt = freezed,Object? enrollment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enrollment: freezed == enrollment ? _self.enrollment : enrollment // ignore: cast_nullable_to_non_nullable
as StudentEnrollmentEntity?,
  ));
}
/// Create a copy of StudentEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentEnrollmentEntityCopyWith<$Res>? get enrollment {
    if (_self.enrollment == null) {
    return null;
  }

  return $StudentEnrollmentEntityCopyWith<$Res>(_self.enrollment!, (value) {
    return _then(_self.copyWith(enrollment: value));
  });
}
}


/// Adds pattern-matching-related methods to [StudentEntity].
extension StudentEntityPatterns on StudentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentEntity value)  $default,){
final _that = this;
switch (_that) {
case _StudentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _StudentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? email,  String? firstName,  String? lastName,  String? name, @JsonKey(unknownEnumValue: StudentStatus.unknown)  StudentStatus status,  DateTime? activatedAt,  DateTime? createdAt,  StudentEnrollmentEntity? enrollment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentEntity() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.name,_that.status,_that.activatedAt,_that.createdAt,_that.enrollment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? email,  String? firstName,  String? lastName,  String? name, @JsonKey(unknownEnumValue: StudentStatus.unknown)  StudentStatus status,  DateTime? activatedAt,  DateTime? createdAt,  StudentEnrollmentEntity? enrollment)  $default,) {final _that = this;
switch (_that) {
case _StudentEntity():
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.name,_that.status,_that.activatedAt,_that.createdAt,_that.enrollment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? email,  String? firstName,  String? lastName,  String? name, @JsonKey(unknownEnumValue: StudentStatus.unknown)  StudentStatus status,  DateTime? activatedAt,  DateTime? createdAt,  StudentEnrollmentEntity? enrollment)?  $default,) {final _that = this;
switch (_that) {
case _StudentEntity() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.name,_that.status,_that.activatedAt,_that.createdAt,_that.enrollment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentEntity extends StudentEntity {
  const _StudentEntity({required this.id, this.email, this.firstName, this.lastName, this.name, @JsonKey(unknownEnumValue: StudentStatus.unknown) this.status = StudentStatus.unknown, this.activatedAt, this.createdAt, this.enrollment}): super._();
  factory _StudentEntity.fromJson(Map<String, dynamic> json) => _$StudentEntityFromJson(json);

@override final  String id;
@override final  String? email;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? name;
@override@JsonKey(unknownEnumValue: StudentStatus.unknown) final  StudentStatus status;
@override final  DateTime? activatedAt;
@override final  DateTime? createdAt;
// `null` is the documented unplaced-student case (§5.5.2), not a parse
// failure — see [isUnassigned].
@override final  StudentEnrollmentEntity? enrollment;

/// Create a copy of StudentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentEntityCopyWith<_StudentEntity> get copyWith => __$StudentEntityCopyWithImpl<_StudentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.enrollment, enrollment) || other.enrollment == enrollment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,name,status,activatedAt,createdAt,enrollment);

@override
String toString() {
  return 'StudentEntity(id: $id, email: $email, firstName: $firstName, lastName: $lastName, name: $name, status: $status, activatedAt: $activatedAt, createdAt: $createdAt, enrollment: $enrollment)';
}


}

/// @nodoc
abstract mixin class _$StudentEntityCopyWith<$Res> implements $StudentEntityCopyWith<$Res> {
  factory _$StudentEntityCopyWith(_StudentEntity value, $Res Function(_StudentEntity) _then) = __$StudentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? email, String? firstName, String? lastName, String? name,@JsonKey(unknownEnumValue: StudentStatus.unknown) StudentStatus status, DateTime? activatedAt, DateTime? createdAt, StudentEnrollmentEntity? enrollment
});


@override $StudentEnrollmentEntityCopyWith<$Res>? get enrollment;

}
/// @nodoc
class __$StudentEntityCopyWithImpl<$Res>
    implements _$StudentEntityCopyWith<$Res> {
  __$StudentEntityCopyWithImpl(this._self, this._then);

  final _StudentEntity _self;
  final $Res Function(_StudentEntity) _then;

/// Create a copy of StudentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? name = freezed,Object? status = null,Object? activatedAt = freezed,Object? createdAt = freezed,Object? enrollment = freezed,}) {
  return _then(_StudentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enrollment: freezed == enrollment ? _self.enrollment : enrollment // ignore: cast_nullable_to_non_nullable
as StudentEnrollmentEntity?,
  ));
}

/// Create a copy of StudentEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentEnrollmentEntityCopyWith<$Res>? get enrollment {
    if (_self.enrollment == null) {
    return null;
  }

  return $StudentEnrollmentEntityCopyWith<$Res>(_self.enrollment!, (value) {
    return _then(_self.copyWith(enrollment: value));
  });
}
}

// dart format on
