// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskResourceRef {

 String get id; String get title;
/// Create a copy of TaskResourceRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskResourceRefCopyWith<TaskResourceRef> get copyWith => _$TaskResourceRefCopyWithImpl<TaskResourceRef>(this as TaskResourceRef, _$identity);

  /// Serializes this TaskResourceRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskResourceRef&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'TaskResourceRef(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $TaskResourceRefCopyWith<$Res>  {
  factory $TaskResourceRefCopyWith(TaskResourceRef value, $Res Function(TaskResourceRef) _then) = _$TaskResourceRefCopyWithImpl;
@useResult
$Res call({
 String id, String title
});




}
/// @nodoc
class _$TaskResourceRefCopyWithImpl<$Res>
    implements $TaskResourceRefCopyWith<$Res> {
  _$TaskResourceRefCopyWithImpl(this._self, this._then);

  final TaskResourceRef _self;
  final $Res Function(TaskResourceRef) _then;

/// Create a copy of TaskResourceRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskResourceRef].
extension TaskResourceRefPatterns on TaskResourceRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskResourceRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskResourceRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskResourceRef value)  $default,){
final _that = this;
switch (_that) {
case _TaskResourceRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskResourceRef value)?  $default,){
final _that = this;
switch (_that) {
case _TaskResourceRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskResourceRef() when $default != null:
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title)  $default,) {final _that = this;
switch (_that) {
case _TaskResourceRef():
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title)?  $default,) {final _that = this;
switch (_that) {
case _TaskResourceRef() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskResourceRef extends TaskResourceRef {
  const _TaskResourceRef({required this.id, this.title = ''}): super._();
  factory _TaskResourceRef.fromJson(Map<String, dynamic> json) => _$TaskResourceRefFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;

/// Create a copy of TaskResourceRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskResourceRefCopyWith<_TaskResourceRef> get copyWith => __$TaskResourceRefCopyWithImpl<_TaskResourceRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskResourceRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskResourceRef&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'TaskResourceRef(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$TaskResourceRefCopyWith<$Res> implements $TaskResourceRefCopyWith<$Res> {
  factory _$TaskResourceRefCopyWith(_TaskResourceRef value, $Res Function(_TaskResourceRef) _then) = __$TaskResourceRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String title
});




}
/// @nodoc
class __$TaskResourceRefCopyWithImpl<$Res>
    implements _$TaskResourceRefCopyWith<$Res> {
  __$TaskResourceRefCopyWithImpl(this._self, this._then);

  final _TaskResourceRef _self;
  final $Res Function(_TaskResourceRef) _then;

/// Create a copy of TaskResourceRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_TaskResourceRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TaskAssignmentEntity {

 String get id; String? get studentId;@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus get status; DateTime? get completedAt;/// Stamped at fan-out when the student had **already** completed the
/// resource. The task is not auto-closed on this basis — the teacher
/// decides what it means — but every report and the student's own list
/// flags it (backend plan §1.3).
 DateTime? get preCompletedAt; DateTime? get createdAt;
/// Create a copy of TaskAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskAssignmentEntityCopyWith<TaskAssignmentEntity> get copyWith => _$TaskAssignmentEntityCopyWithImpl<TaskAssignmentEntity>(this as TaskAssignmentEntity, _$identity);

  /// Serializes this TaskAssignmentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskAssignmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.preCompletedAt, preCompletedAt) || other.preCompletedAt == preCompletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,status,completedAt,preCompletedAt,createdAt);

@override
String toString() {
  return 'TaskAssignmentEntity(id: $id, studentId: $studentId, status: $status, completedAt: $completedAt, preCompletedAt: $preCompletedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TaskAssignmentEntityCopyWith<$Res>  {
  factory $TaskAssignmentEntityCopyWith(TaskAssignmentEntity value, $Res Function(TaskAssignmentEntity) _then) = _$TaskAssignmentEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? studentId,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, DateTime? completedAt, DateTime? preCompletedAt, DateTime? createdAt
});




}
/// @nodoc
class _$TaskAssignmentEntityCopyWithImpl<$Res>
    implements $TaskAssignmentEntityCopyWith<$Res> {
  _$TaskAssignmentEntityCopyWithImpl(this._self, this._then);

  final TaskAssignmentEntity _self;
  final $Res Function(TaskAssignmentEntity) _then;

/// Create a copy of TaskAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = freezed,Object? status = null,Object? completedAt = freezed,Object? preCompletedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preCompletedAt: freezed == preCompletedAt ? _self.preCompletedAt : preCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskAssignmentEntity].
extension TaskAssignmentEntityPatterns on TaskAssignmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskAssignmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskAssignmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskAssignmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _TaskAssignmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskAssignmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TaskAssignmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskAssignmentEntity() when $default != null:
return $default(_that.id,_that.studentId,_that.status,_that.completedAt,_that.preCompletedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TaskAssignmentEntity():
return $default(_that.id,_that.studentId,_that.status,_that.completedAt,_that.preCompletedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskAssignmentEntity() when $default != null:
return $default(_that.id,_that.studentId,_that.status,_that.completedAt,_that.preCompletedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskAssignmentEntity extends TaskAssignmentEntity {
  const _TaskAssignmentEntity({required this.id, this.studentId, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) this.status = ActivityProgressStatus.unknown, this.completedAt, this.preCompletedAt, this.createdAt}): super._();
  factory _TaskAssignmentEntity.fromJson(Map<String, dynamic> json) => _$TaskAssignmentEntityFromJson(json);

@override final  String id;
@override final  String? studentId;
@override@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) final  ActivityProgressStatus status;
@override final  DateTime? completedAt;
/// Stamped at fan-out when the student had **already** completed the
/// resource. The task is not auto-closed on this basis — the teacher
/// decides what it means — but every report and the student's own list
/// flags it (backend plan §1.3).
@override final  DateTime? preCompletedAt;
@override final  DateTime? createdAt;

/// Create a copy of TaskAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskAssignmentEntityCopyWith<_TaskAssignmentEntity> get copyWith => __$TaskAssignmentEntityCopyWithImpl<_TaskAssignmentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskAssignmentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskAssignmentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.preCompletedAt, preCompletedAt) || other.preCompletedAt == preCompletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,status,completedAt,preCompletedAt,createdAt);

@override
String toString() {
  return 'TaskAssignmentEntity(id: $id, studentId: $studentId, status: $status, completedAt: $completedAt, preCompletedAt: $preCompletedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TaskAssignmentEntityCopyWith<$Res> implements $TaskAssignmentEntityCopyWith<$Res> {
  factory _$TaskAssignmentEntityCopyWith(_TaskAssignmentEntity value, $Res Function(_TaskAssignmentEntity) _then) = __$TaskAssignmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? studentId,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, DateTime? completedAt, DateTime? preCompletedAt, DateTime? createdAt
});




}
/// @nodoc
class __$TaskAssignmentEntityCopyWithImpl<$Res>
    implements _$TaskAssignmentEntityCopyWith<$Res> {
  __$TaskAssignmentEntityCopyWithImpl(this._self, this._then);

  final _TaskAssignmentEntity _self;
  final $Res Function(_TaskAssignmentEntity) _then;

/// Create a copy of TaskAssignmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = freezed,Object? status = null,Object? completedAt = freezed,Object? preCompletedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_TaskAssignmentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preCompletedAt: freezed == preCompletedAt ? _self.preCompletedAt : preCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TaskEntity {

 String get id; String get title; String? get instructions; DateTime? get dueAt;@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType get resourceType; String? get videoId; String? get documentId;@JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown) TaskLifecycleStatus get status; DateTime? get cancelledAt; String? get sectionId; String? get createdById; DateTime? get createdAt; DateTime? get updatedAt; TaskResourceRef? get video; TaskResourceRef? get document; List<TaskAssignmentEntity> get assignments;
/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskEntityCopyWith<TaskEntity> get copyWith => _$TaskEntityCopyWithImpl<TaskEntity>(this as TaskEntity, _$identity);

  /// Serializes this TaskEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.video, video) || other.video == video)&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other.assignments, assignments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,instructions,dueAt,resourceType,videoId,documentId,status,cancelledAt,sectionId,createdById,createdAt,updatedAt,video,document,const DeepCollectionEquality().hash(assignments));

@override
String toString() {
  return 'TaskEntity(id: $id, title: $title, instructions: $instructions, dueAt: $dueAt, resourceType: $resourceType, videoId: $videoId, documentId: $documentId, status: $status, cancelledAt: $cancelledAt, sectionId: $sectionId, createdById: $createdById, createdAt: $createdAt, updatedAt: $updatedAt, video: $video, document: $document, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class $TaskEntityCopyWith<$Res>  {
  factory $TaskEntityCopyWith(TaskEntity value, $Res Function(TaskEntity) _then) = _$TaskEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? instructions, DateTime? dueAt,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, String? videoId, String? documentId,@JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown) TaskLifecycleStatus status, DateTime? cancelledAt, String? sectionId, String? createdById, DateTime? createdAt, DateTime? updatedAt, TaskResourceRef? video, TaskResourceRef? document, List<TaskAssignmentEntity> assignments
});


$TaskResourceRefCopyWith<$Res>? get video;$TaskResourceRefCopyWith<$Res>? get document;

}
/// @nodoc
class _$TaskEntityCopyWithImpl<$Res>
    implements $TaskEntityCopyWith<$Res> {
  _$TaskEntityCopyWithImpl(this._self, this._then);

  final TaskEntity _self;
  final $Res Function(TaskEntity) _then;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? instructions = freezed,Object? dueAt = freezed,Object? resourceType = null,Object? videoId = freezed,Object? documentId = freezed,Object? status = null,Object? cancelledAt = freezed,Object? sectionId = freezed,Object? createdById = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? video = freezed,Object? document = freezed,Object? assignments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskLifecycleStatus,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as TaskResourceRef?,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as TaskResourceRef?,assignments: null == assignments ? _self.assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<TaskAssignmentEntity>,
  ));
}
/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskResourceRefCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $TaskResourceRefCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskResourceRefCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $TaskResourceRefCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskEntity].
extension TaskEntityPatterns on TaskEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskEntity value)  $default,){
final _that = this;
switch (_that) {
case _TaskEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? instructions,  DateTime? dueAt, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId, @JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown)  TaskLifecycleStatus status,  DateTime? cancelledAt,  String? sectionId,  String? createdById,  DateTime? createdAt,  DateTime? updatedAt,  TaskResourceRef? video,  TaskResourceRef? document,  List<TaskAssignmentEntity> assignments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
return $default(_that.id,_that.title,_that.instructions,_that.dueAt,_that.resourceType,_that.videoId,_that.documentId,_that.status,_that.cancelledAt,_that.sectionId,_that.createdById,_that.createdAt,_that.updatedAt,_that.video,_that.document,_that.assignments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? instructions,  DateTime? dueAt, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId, @JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown)  TaskLifecycleStatus status,  DateTime? cancelledAt,  String? sectionId,  String? createdById,  DateTime? createdAt,  DateTime? updatedAt,  TaskResourceRef? video,  TaskResourceRef? document,  List<TaskAssignmentEntity> assignments)  $default,) {final _that = this;
switch (_that) {
case _TaskEntity():
return $default(_that.id,_that.title,_that.instructions,_that.dueAt,_that.resourceType,_that.videoId,_that.documentId,_that.status,_that.cancelledAt,_that.sectionId,_that.createdById,_that.createdAt,_that.updatedAt,_that.video,_that.document,_that.assignments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? instructions,  DateTime? dueAt, @JsonKey(unknownEnumValue: ActivityResourceType.unknown)  ActivityResourceType resourceType,  String? videoId,  String? documentId, @JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown)  TaskLifecycleStatus status,  DateTime? cancelledAt,  String? sectionId,  String? createdById,  DateTime? createdAt,  DateTime? updatedAt,  TaskResourceRef? video,  TaskResourceRef? document,  List<TaskAssignmentEntity> assignments)?  $default,) {final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
return $default(_that.id,_that.title,_that.instructions,_that.dueAt,_that.resourceType,_that.videoId,_that.documentId,_that.status,_that.cancelledAt,_that.sectionId,_that.createdById,_that.createdAt,_that.updatedAt,_that.video,_that.document,_that.assignments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskEntity extends TaskEntity {
  const _TaskEntity({required this.id, this.title = '', this.instructions, this.dueAt, @JsonKey(unknownEnumValue: ActivityResourceType.unknown) this.resourceType = ActivityResourceType.unknown, this.videoId, this.documentId, @JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown) this.status = TaskLifecycleStatus.unknown, this.cancelledAt, this.sectionId, this.createdById, this.createdAt, this.updatedAt, this.video, this.document, final  List<TaskAssignmentEntity> assignments = const <TaskAssignmentEntity>[]}): _assignments = assignments,super._();
  factory _TaskEntity.fromJson(Map<String, dynamic> json) => _$TaskEntityFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  String? instructions;
@override final  DateTime? dueAt;
@override@JsonKey(unknownEnumValue: ActivityResourceType.unknown) final  ActivityResourceType resourceType;
@override final  String? videoId;
@override final  String? documentId;
@override@JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown) final  TaskLifecycleStatus status;
@override final  DateTime? cancelledAt;
@override final  String? sectionId;
@override final  String? createdById;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  TaskResourceRef? video;
@override final  TaskResourceRef? document;
 final  List<TaskAssignmentEntity> _assignments;
@override@JsonKey() List<TaskAssignmentEntity> get assignments {
  if (_assignments is EqualUnmodifiableListView) return _assignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignments);
}


/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskEntityCopyWith<_TaskEntity> get copyWith => __$TaskEntityCopyWithImpl<_TaskEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.video, video) || other.video == video)&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other._assignments, _assignments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,instructions,dueAt,resourceType,videoId,documentId,status,cancelledAt,sectionId,createdById,createdAt,updatedAt,video,document,const DeepCollectionEquality().hash(_assignments));

@override
String toString() {
  return 'TaskEntity(id: $id, title: $title, instructions: $instructions, dueAt: $dueAt, resourceType: $resourceType, videoId: $videoId, documentId: $documentId, status: $status, cancelledAt: $cancelledAt, sectionId: $sectionId, createdById: $createdById, createdAt: $createdAt, updatedAt: $updatedAt, video: $video, document: $document, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class _$TaskEntityCopyWith<$Res> implements $TaskEntityCopyWith<$Res> {
  factory _$TaskEntityCopyWith(_TaskEntity value, $Res Function(_TaskEntity) _then) = __$TaskEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? instructions, DateTime? dueAt,@JsonKey(unknownEnumValue: ActivityResourceType.unknown) ActivityResourceType resourceType, String? videoId, String? documentId,@JsonKey(unknownEnumValue: TaskLifecycleStatus.unknown) TaskLifecycleStatus status, DateTime? cancelledAt, String? sectionId, String? createdById, DateTime? createdAt, DateTime? updatedAt, TaskResourceRef? video, TaskResourceRef? document, List<TaskAssignmentEntity> assignments
});


@override $TaskResourceRefCopyWith<$Res>? get video;@override $TaskResourceRefCopyWith<$Res>? get document;

}
/// @nodoc
class __$TaskEntityCopyWithImpl<$Res>
    implements _$TaskEntityCopyWith<$Res> {
  __$TaskEntityCopyWithImpl(this._self, this._then);

  final _TaskEntity _self;
  final $Res Function(_TaskEntity) _then;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? instructions = freezed,Object? dueAt = freezed,Object? resourceType = null,Object? videoId = freezed,Object? documentId = freezed,Object? status = null,Object? cancelledAt = freezed,Object? sectionId = freezed,Object? createdById = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? video = freezed,Object? document = freezed,Object? assignments = null,}) {
  return _then(_TaskEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as ActivityResourceType,videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskLifecycleStatus,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as TaskResourceRef?,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as TaskResourceRef?,assignments: null == assignments ? _self._assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<TaskAssignmentEntity>,
  ));
}

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskResourceRefCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $TaskResourceRefCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskResourceRefCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $TaskResourceRefCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// @nodoc
mixin _$StudentTaskEntity {

 String get id;@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus get status; DateTime? get completedAt; DateTime? get preCompletedAt; DateTime? get createdAt; TaskEntity? get task;
/// Create a copy of StudentTaskEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentTaskEntityCopyWith<StudentTaskEntity> get copyWith => _$StudentTaskEntityCopyWithImpl<StudentTaskEntity>(this as StudentTaskEntity, _$identity);

  /// Serializes this StudentTaskEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentTaskEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.preCompletedAt, preCompletedAt) || other.preCompletedAt == preCompletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,completedAt,preCompletedAt,createdAt,task);

@override
String toString() {
  return 'StudentTaskEntity(id: $id, status: $status, completedAt: $completedAt, preCompletedAt: $preCompletedAt, createdAt: $createdAt, task: $task)';
}


}

/// @nodoc
abstract mixin class $StudentTaskEntityCopyWith<$Res>  {
  factory $StudentTaskEntityCopyWith(StudentTaskEntity value, $Res Function(StudentTaskEntity) _then) = _$StudentTaskEntityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, DateTime? completedAt, DateTime? preCompletedAt, DateTime? createdAt, TaskEntity? task
});


$TaskEntityCopyWith<$Res>? get task;

}
/// @nodoc
class _$StudentTaskEntityCopyWithImpl<$Res>
    implements $StudentTaskEntityCopyWith<$Res> {
  _$StudentTaskEntityCopyWithImpl(this._self, this._then);

  final StudentTaskEntity _self;
  final $Res Function(StudentTaskEntity) _then;

/// Create a copy of StudentTaskEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? completedAt = freezed,Object? preCompletedAt = freezed,Object? createdAt = freezed,Object? task = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preCompletedAt: freezed == preCompletedAt ? _self.preCompletedAt : preCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as TaskEntity?,
  ));
}
/// Create a copy of StudentTaskEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskEntityCopyWith<$Res>? get task {
    if (_self.task == null) {
    return null;
  }

  return $TaskEntityCopyWith<$Res>(_self.task!, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}


/// Adds pattern-matching-related methods to [StudentTaskEntity].
extension StudentTaskEntityPatterns on StudentTaskEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentTaskEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentTaskEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentTaskEntity value)  $default,){
final _that = this;
switch (_that) {
case _StudentTaskEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentTaskEntity value)?  $default,){
final _that = this;
switch (_that) {
case _StudentTaskEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  DateTime? createdAt,  TaskEntity? task)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentTaskEntity() when $default != null:
return $default(_that.id,_that.status,_that.completedAt,_that.preCompletedAt,_that.createdAt,_that.task);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  DateTime? createdAt,  TaskEntity? task)  $default,) {final _that = this;
switch (_that) {
case _StudentTaskEntity():
return $default(_that.id,_that.status,_that.completedAt,_that.preCompletedAt,_that.createdAt,_that.task);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown)  ActivityProgressStatus status,  DateTime? completedAt,  DateTime? preCompletedAt,  DateTime? createdAt,  TaskEntity? task)?  $default,) {final _that = this;
switch (_that) {
case _StudentTaskEntity() when $default != null:
return $default(_that.id,_that.status,_that.completedAt,_that.preCompletedAt,_that.createdAt,_that.task);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentTaskEntity extends StudentTaskEntity {
  const _StudentTaskEntity({required this.id, @JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) this.status = ActivityProgressStatus.unknown, this.completedAt, this.preCompletedAt, this.createdAt, this.task}): super._();
  factory _StudentTaskEntity.fromJson(Map<String, dynamic> json) => _$StudentTaskEntityFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) final  ActivityProgressStatus status;
@override final  DateTime? completedAt;
@override final  DateTime? preCompletedAt;
@override final  DateTime? createdAt;
@override final  TaskEntity? task;

/// Create a copy of StudentTaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentTaskEntityCopyWith<_StudentTaskEntity> get copyWith => __$StudentTaskEntityCopyWithImpl<_StudentTaskEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentTaskEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentTaskEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.preCompletedAt, preCompletedAt) || other.preCompletedAt == preCompletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,completedAt,preCompletedAt,createdAt,task);

@override
String toString() {
  return 'StudentTaskEntity(id: $id, status: $status, completedAt: $completedAt, preCompletedAt: $preCompletedAt, createdAt: $createdAt, task: $task)';
}


}

/// @nodoc
abstract mixin class _$StudentTaskEntityCopyWith<$Res> implements $StudentTaskEntityCopyWith<$Res> {
  factory _$StudentTaskEntityCopyWith(_StudentTaskEntity value, $Res Function(_StudentTaskEntity) _then) = __$StudentTaskEntityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: ActivityProgressStatus.unknown) ActivityProgressStatus status, DateTime? completedAt, DateTime? preCompletedAt, DateTime? createdAt, TaskEntity? task
});


@override $TaskEntityCopyWith<$Res>? get task;

}
/// @nodoc
class __$StudentTaskEntityCopyWithImpl<$Res>
    implements _$StudentTaskEntityCopyWith<$Res> {
  __$StudentTaskEntityCopyWithImpl(this._self, this._then);

  final _StudentTaskEntity _self;
  final $Res Function(_StudentTaskEntity) _then;

/// Create a copy of StudentTaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? completedAt = freezed,Object? preCompletedAt = freezed,Object? createdAt = freezed,Object? task = freezed,}) {
  return _then(_StudentTaskEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityProgressStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preCompletedAt: freezed == preCompletedAt ? _self.preCompletedAt : preCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as TaskEntity?,
  ));
}

/// Create a copy of StudentTaskEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskEntityCopyWith<$Res>? get task {
    if (_self.task == null) {
    return null;
  }

  return $TaskEntityCopyWith<$Res>(_self.task!, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}

// dart format on
