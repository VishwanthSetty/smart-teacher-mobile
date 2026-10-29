// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_progress_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskProgressStudentRef {

 String? get name; String? get email;
/// Create a copy of TaskProgressStudentRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskProgressStudentRefCopyWith<TaskProgressStudentRef> get copyWith => _$TaskProgressStudentRefCopyWithImpl<TaskProgressStudentRef>(this as TaskProgressStudentRef, _$identity);

  /// Serializes this TaskProgressStudentRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskProgressStudentRef&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'TaskProgressStudentRef(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class $TaskProgressStudentRefCopyWith<$Res>  {
  factory $TaskProgressStudentRefCopyWith(TaskProgressStudentRef value, $Res Function(TaskProgressStudentRef) _then) = _$TaskProgressStudentRefCopyWithImpl;
@useResult
$Res call({
 String? name, String? email
});




}
/// @nodoc
class _$TaskProgressStudentRefCopyWithImpl<$Res>
    implements $TaskProgressStudentRefCopyWith<$Res> {
  _$TaskProgressStudentRefCopyWithImpl(this._self, this._then);

  final TaskProgressStudentRef _self;
  final $Res Function(TaskProgressStudentRef) _then;

/// Create a copy of TaskProgressStudentRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskProgressStudentRef].
extension TaskProgressStudentRefPatterns on TaskProgressStudentRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskProgressStudentRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskProgressStudentRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskProgressStudentRef value)  $default,){
final _that = this;
switch (_that) {
case _TaskProgressStudentRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskProgressStudentRef value)?  $default,){
final _that = this;
switch (_that) {
case _TaskProgressStudentRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskProgressStudentRef() when $default != null:
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? email)  $default,) {final _that = this;
switch (_that) {
case _TaskProgressStudentRef():
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _TaskProgressStudentRef() when $default != null:
return $default(_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskProgressStudentRef extends TaskProgressStudentRef {
  const _TaskProgressStudentRef({this.name, this.email}): super._();
  factory _TaskProgressStudentRef.fromJson(Map<String, dynamic> json) => _$TaskProgressStudentRefFromJson(json);

@override final  String? name;
@override final  String? email;

/// Create a copy of TaskProgressStudentRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskProgressStudentRefCopyWith<_TaskProgressStudentRef> get copyWith => __$TaskProgressStudentRefCopyWithImpl<_TaskProgressStudentRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskProgressStudentRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskProgressStudentRef&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'TaskProgressStudentRef(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$TaskProgressStudentRefCopyWith<$Res> implements $TaskProgressStudentRefCopyWith<$Res> {
  factory _$TaskProgressStudentRefCopyWith(_TaskProgressStudentRef value, $Res Function(_TaskProgressStudentRef) _then) = __$TaskProgressStudentRefCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? email
});




}
/// @nodoc
class __$TaskProgressStudentRefCopyWithImpl<$Res>
    implements _$TaskProgressStudentRefCopyWith<$Res> {
  __$TaskProgressStudentRefCopyWithImpl(this._self, this._then);

  final _TaskProgressStudentRef _self;
  final $Res Function(_TaskProgressStudentRef) _then;

/// Create a copy of TaskProgressStudentRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? email = freezed,}) {
  return _then(_TaskProgressStudentRef(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TaskProgressRowEntity {

 String get id; String? get studentId;@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus get status; DateTime? get completedAt; DateTime? get preCompletedAt; TaskProgressStudentRef? get student;
/// Create a copy of TaskProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskProgressRowEntityCopyWith<TaskProgressRowEntity> get copyWith => _$TaskProgressRowEntityCopyWithImpl<TaskProgressRowEntity>(this as TaskProgressRowEntity, _$identity);

  /// Serializes this TaskProgressRowEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskProgressRowEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.preCompletedAt, preCompletedAt) || other.preCompletedAt == preCompletedAt)&&(identical(other.student, student) || other.student == student));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,status,completedAt,preCompletedAt,student);

@override
String toString() {
  return 'TaskProgressRowEntity(id: $id, studentId: $studentId, status: $status, completedAt: $completedAt, preCompletedAt: $preCompletedAt, student: $student)';
}


}

/// @nodoc
abstract mixin class $TaskProgressRowEntityCopyWith<$Res>  {
  factory $TaskProgressRowEntityCopyWith(TaskProgressRowEntity value, $Res Function(TaskProgressRowEntity) _then) = _$TaskProgressRowEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? studentId,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, DateTime? completedAt, DateTime? preCompletedAt, TaskProgressStudentRef? student
});


$TaskProgressStudentRefCopyWith<$Res>? get student;

}
/// @nodoc
class _$TaskProgressRowEntityCopyWithImpl<$Res>
    implements $TaskProgressRowEntityCopyWith<$Res> {
  _$TaskProgressRowEntityCopyWithImpl(this._self, this._then);

  final TaskProgressRowEntity _self;
  final $Res Function(TaskProgressRowEntity) _then;

/// Create a copy of TaskProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = freezed,Object? status = null,Object? completedAt = freezed,Object? preCompletedAt = freezed,Object? student = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preCompletedAt: freezed == preCompletedAt ? _self.preCompletedAt : preCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,student: freezed == student ? _self.student : student // ignore: cast_nullable_to_non_nullable
as TaskProgressStudentRef?,
  ));
}
/// Create a copy of TaskProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskProgressStudentRefCopyWith<$Res>? get student {
    if (_self.student == null) {
    return null;
  }

  return $TaskProgressStudentRefCopyWith<$Res>(_self.student!, (value) {
    return _then(_self.copyWith(student: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskProgressRowEntity].
extension TaskProgressRowEntityPatterns on TaskProgressRowEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskProgressRowEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskProgressRowEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskProgressRowEntity value)  $default,){
final _that = this;
switch (_that) {
case _TaskProgressRowEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskProgressRowEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TaskProgressRowEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  TaskProgressStudentRef? student)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskProgressRowEntity() when $default != null:
return $default(_that.id,_that.studentId,_that.status,_that.completedAt,_that.preCompletedAt,_that.student);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  TaskProgressStudentRef? student)  $default,) {final _that = this;
switch (_that) {
case _TaskProgressRowEntity():
return $default(_that.id,_that.studentId,_that.status,_that.completedAt,_that.preCompletedAt,_that.student);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  TaskProgressStudentRef? student)?  $default,) {final _that = this;
switch (_that) {
case _TaskProgressRowEntity() when $default != null:
return $default(_that.id,_that.studentId,_that.status,_that.completedAt,_that.preCompletedAt,_that.student);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskProgressRowEntity extends TaskProgressRowEntity {
  const _TaskProgressRowEntity({required this.id, this.studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) this.status = ActivityProgressStatus.unknown, this.completedAt, this.preCompletedAt, this.student}): super._();
  factory _TaskProgressRowEntity.fromJson(Map<String, dynamic> json) => _$TaskProgressRowEntityFromJson(json);

@override final  String id;
@override final  String? studentId;
@override@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) final  ActivityProgressStatus status;
@override final  DateTime? completedAt;
@override final  DateTime? preCompletedAt;
@override final  TaskProgressStudentRef? student;

/// Create a copy of TaskProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskProgressRowEntityCopyWith<_TaskProgressRowEntity> get copyWith => __$TaskProgressRowEntityCopyWithImpl<_TaskProgressRowEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskProgressRowEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskProgressRowEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.preCompletedAt, preCompletedAt) || other.preCompletedAt == preCompletedAt)&&(identical(other.student, student) || other.student == student));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,status,completedAt,preCompletedAt,student);

@override
String toString() {
  return 'TaskProgressRowEntity(id: $id, studentId: $studentId, status: $status, completedAt: $completedAt, preCompletedAt: $preCompletedAt, student: $student)';
}


}

/// @nodoc
abstract mixin class _$TaskProgressRowEntityCopyWith<$Res> implements $TaskProgressRowEntityCopyWith<$Res> {
  factory _$TaskProgressRowEntityCopyWith(_TaskProgressRowEntity value, $Res Function(_TaskProgressRowEntity) _then) = __$TaskProgressRowEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? studentId,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, DateTime? completedAt, DateTime? preCompletedAt, TaskProgressStudentRef? student
});


@override $TaskProgressStudentRefCopyWith<$Res>? get student;

}
/// @nodoc
class __$TaskProgressRowEntityCopyWithImpl<$Res>
    implements _$TaskProgressRowEntityCopyWith<$Res> {
  __$TaskProgressRowEntityCopyWithImpl(this._self, this._then);

  final _TaskProgressRowEntity _self;
  final $Res Function(_TaskProgressRowEntity) _then;

/// Create a copy of TaskProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = freezed,Object? status = null,Object? completedAt = freezed,Object? preCompletedAt = freezed,Object? student = freezed,}) {
  return _then(_TaskProgressRowEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preCompletedAt: freezed == preCompletedAt ? _self.preCompletedAt : preCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,student: freezed == student ? _self.student : student // ignore: cast_nullable_to_non_nullable
as TaskProgressStudentRef?,
  ));
}

/// Create a copy of TaskProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskProgressStudentRefCopyWith<$Res>? get student {
    if (_self.student == null) {
    return null;
  }

  return $TaskProgressStudentRefCopyWith<$Res>(_self.student!, (value) {
    return _then(_self.copyWith(student: value));
  });
}
}


/// @nodoc
mixin _$ClassProgressRowEntity {

 String get taskId; String get title; String? get sectionId; int get total; int get notStarted; int get inProgress; int get completed; int get preCompleted;
/// Create a copy of ClassProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassProgressRowEntityCopyWith<ClassProgressRowEntity> get copyWith => _$ClassProgressRowEntityCopyWithImpl<ClassProgressRowEntity>(this as ClassProgressRowEntity, _$identity);

  /// Serializes this ClassProgressRowEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassProgressRowEntity&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.total, total) || other.total == total)&&(identical(other.notStarted, notStarted) || other.notStarted == notStarted)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.preCompleted, preCompleted) || other.preCompleted == preCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,title,sectionId,total,notStarted,inProgress,completed,preCompleted);

@override
String toString() {
  return 'ClassProgressRowEntity(taskId: $taskId, title: $title, sectionId: $sectionId, total: $total, notStarted: $notStarted, inProgress: $inProgress, completed: $completed, preCompleted: $preCompleted)';
}


}

/// @nodoc
abstract mixin class $ClassProgressRowEntityCopyWith<$Res>  {
  factory $ClassProgressRowEntityCopyWith(ClassProgressRowEntity value, $Res Function(ClassProgressRowEntity) _then) = _$ClassProgressRowEntityCopyWithImpl;
@useResult
$Res call({
 String taskId, String title, String? sectionId, int total, int notStarted, int inProgress, int completed, int preCompleted
});




}
/// @nodoc
class _$ClassProgressRowEntityCopyWithImpl<$Res>
    implements $ClassProgressRowEntityCopyWith<$Res> {
  _$ClassProgressRowEntityCopyWithImpl(this._self, this._then);

  final ClassProgressRowEntity _self;
  final $Res Function(ClassProgressRowEntity) _then;

/// Create a copy of ClassProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? title = null,Object? sectionId = freezed,Object? total = null,Object? notStarted = null,Object? inProgress = null,Object? completed = null,Object? preCompleted = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,notStarted: null == notStarted ? _self.notStarted : notStarted // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,preCompleted: null == preCompleted ? _self.preCompleted : preCompleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassProgressRowEntity].
extension ClassProgressRowEntityPatterns on ClassProgressRowEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassProgressRowEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassProgressRowEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassProgressRowEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClassProgressRowEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassProgressRowEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClassProgressRowEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  String title,  String? sectionId,  int total,  int notStarted,  int inProgress,  int completed,  int preCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassProgressRowEntity() when $default != null:
return $default(_that.taskId,_that.title,_that.sectionId,_that.total,_that.notStarted,_that.inProgress,_that.completed,_that.preCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  String title,  String? sectionId,  int total,  int notStarted,  int inProgress,  int completed,  int preCompleted)  $default,) {final _that = this;
switch (_that) {
case _ClassProgressRowEntity():
return $default(_that.taskId,_that.title,_that.sectionId,_that.total,_that.notStarted,_that.inProgress,_that.completed,_that.preCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  String title,  String? sectionId,  int total,  int notStarted,  int inProgress,  int completed,  int preCompleted)?  $default,) {final _that = this;
switch (_that) {
case _ClassProgressRowEntity() when $default != null:
return $default(_that.taskId,_that.title,_that.sectionId,_that.total,_that.notStarted,_that.inProgress,_that.completed,_that.preCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassProgressRowEntity extends ClassProgressRowEntity {
  const _ClassProgressRowEntity({required this.taskId, this.title = '', this.sectionId, this.total = 0, this.notStarted = 0, this.inProgress = 0, this.completed = 0, this.preCompleted = 0}): super._();
  factory _ClassProgressRowEntity.fromJson(Map<String, dynamic> json) => _$ClassProgressRowEntityFromJson(json);

@override final  String taskId;
@override@JsonKey() final  String title;
@override final  String? sectionId;
@override@JsonKey() final  int total;
@override@JsonKey() final  int notStarted;
@override@JsonKey() final  int inProgress;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int preCompleted;

/// Create a copy of ClassProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassProgressRowEntityCopyWith<_ClassProgressRowEntity> get copyWith => __$ClassProgressRowEntityCopyWithImpl<_ClassProgressRowEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassProgressRowEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassProgressRowEntity&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.total, total) || other.total == total)&&(identical(other.notStarted, notStarted) || other.notStarted == notStarted)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.preCompleted, preCompleted) || other.preCompleted == preCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,title,sectionId,total,notStarted,inProgress,completed,preCompleted);

@override
String toString() {
  return 'ClassProgressRowEntity(taskId: $taskId, title: $title, sectionId: $sectionId, total: $total, notStarted: $notStarted, inProgress: $inProgress, completed: $completed, preCompleted: $preCompleted)';
}


}

/// @nodoc
abstract mixin class _$ClassProgressRowEntityCopyWith<$Res> implements $ClassProgressRowEntityCopyWith<$Res> {
  factory _$ClassProgressRowEntityCopyWith(_ClassProgressRowEntity value, $Res Function(_ClassProgressRowEntity) _then) = __$ClassProgressRowEntityCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String title, String? sectionId, int total, int notStarted, int inProgress, int completed, int preCompleted
});




}
/// @nodoc
class __$ClassProgressRowEntityCopyWithImpl<$Res>
    implements _$ClassProgressRowEntityCopyWith<$Res> {
  __$ClassProgressRowEntityCopyWithImpl(this._self, this._then);

  final _ClassProgressRowEntity _self;
  final $Res Function(_ClassProgressRowEntity) _then;

/// Create a copy of ClassProgressRowEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? title = null,Object? sectionId = freezed,Object? total = null,Object? notStarted = null,Object? inProgress = null,Object? completed = null,Object? preCompleted = null,}) {
  return _then(_ClassProgressRowEntity(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,notStarted: null == notStarted ? _self.notStarted : notStarted // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,preCompleted: null == preCompleted ? _self.preCompleted : preCompleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TaskReminderResult {

 int get reminded;
/// Create a copy of TaskReminderResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskReminderResultCopyWith<TaskReminderResult> get copyWith => _$TaskReminderResultCopyWithImpl<TaskReminderResult>(this as TaskReminderResult, _$identity);

  /// Serializes this TaskReminderResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskReminderResult&&(identical(other.reminded, reminded) || other.reminded == reminded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reminded);

@override
String toString() {
  return 'TaskReminderResult(reminded: $reminded)';
}


}

/// @nodoc
abstract mixin class $TaskReminderResultCopyWith<$Res>  {
  factory $TaskReminderResultCopyWith(TaskReminderResult value, $Res Function(TaskReminderResult) _then) = _$TaskReminderResultCopyWithImpl;
@useResult
$Res call({
 int reminded
});




}
/// @nodoc
class _$TaskReminderResultCopyWithImpl<$Res>
    implements $TaskReminderResultCopyWith<$Res> {
  _$TaskReminderResultCopyWithImpl(this._self, this._then);

  final TaskReminderResult _self;
  final $Res Function(TaskReminderResult) _then;

/// Create a copy of TaskReminderResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reminded = null,}) {
  return _then(_self.copyWith(
reminded: null == reminded ? _self.reminded : reminded // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskReminderResult].
extension TaskReminderResultPatterns on TaskReminderResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskReminderResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskReminderResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskReminderResult value)  $default,){
final _that = this;
switch (_that) {
case _TaskReminderResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskReminderResult value)?  $default,){
final _that = this;
switch (_that) {
case _TaskReminderResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reminded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskReminderResult() when $default != null:
return $default(_that.reminded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reminded)  $default,) {final _that = this;
switch (_that) {
case _TaskReminderResult():
return $default(_that.reminded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reminded)?  $default,) {final _that = this;
switch (_that) {
case _TaskReminderResult() when $default != null:
return $default(_that.reminded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskReminderResult extends TaskReminderResult {
  const _TaskReminderResult({this.reminded = 0}): super._();
  factory _TaskReminderResult.fromJson(Map<String, dynamic> json) => _$TaskReminderResultFromJson(json);

@override@JsonKey() final  int reminded;

/// Create a copy of TaskReminderResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskReminderResultCopyWith<_TaskReminderResult> get copyWith => __$TaskReminderResultCopyWithImpl<_TaskReminderResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskReminderResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskReminderResult&&(identical(other.reminded, reminded) || other.reminded == reminded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reminded);

@override
String toString() {
  return 'TaskReminderResult(reminded: $reminded)';
}


}

/// @nodoc
abstract mixin class _$TaskReminderResultCopyWith<$Res> implements $TaskReminderResultCopyWith<$Res> {
  factory _$TaskReminderResultCopyWith(_TaskReminderResult value, $Res Function(_TaskReminderResult) _then) = __$TaskReminderResultCopyWithImpl;
@override @useResult
$Res call({
 int reminded
});




}
/// @nodoc
class __$TaskReminderResultCopyWithImpl<$Res>
    implements _$TaskReminderResultCopyWith<$Res> {
  __$TaskReminderResultCopyWithImpl(this._self, this._then);

  final _TaskReminderResult _self;
  final $Res Function(_TaskReminderResult) _then;

/// Create a copy of TaskReminderResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reminded = null,}) {
  return _then(_TaskReminderResult(
reminded: null == reminded ? _self.reminded : reminded // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
