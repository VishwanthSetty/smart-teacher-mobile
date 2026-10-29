// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_summary_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgressSummaryEntity {

 String get subjectId; String get subjectName; String? get gradeLevelId; int get total; int get notStarted; int get inProgress; int get completed; int get percent;
/// Create a copy of ProgressSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressSummaryEntityCopyWith<ProgressSummaryEntity> get copyWith => _$ProgressSummaryEntityCopyWithImpl<ProgressSummaryEntity>(this as ProgressSummaryEntity, _$identity);

  /// Serializes this ProgressSummaryEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressSummaryEntity&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.total, total) || other.total == total)&&(identical(other.notStarted, notStarted) || other.notStarted == notStarted)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subjectId,subjectName,gradeLevelId,total,notStarted,inProgress,completed,percent);

@override
String toString() {
  return 'ProgressSummaryEntity(subjectId: $subjectId, subjectName: $subjectName, gradeLevelId: $gradeLevelId, total: $total, notStarted: $notStarted, inProgress: $inProgress, completed: $completed, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $ProgressSummaryEntityCopyWith<$Res>  {
  factory $ProgressSummaryEntityCopyWith(ProgressSummaryEntity value, $Res Function(ProgressSummaryEntity) _then) = _$ProgressSummaryEntityCopyWithImpl;
@useResult
$Res call({
 String subjectId, String subjectName, String? gradeLevelId, int total, int notStarted, int inProgress, int completed, int percent
});




}
/// @nodoc
class _$ProgressSummaryEntityCopyWithImpl<$Res>
    implements $ProgressSummaryEntityCopyWith<$Res> {
  _$ProgressSummaryEntityCopyWithImpl(this._self, this._then);

  final ProgressSummaryEntity _self;
  final $Res Function(ProgressSummaryEntity) _then;

/// Create a copy of ProgressSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subjectId = null,Object? subjectName = null,Object? gradeLevelId = freezed,Object? total = null,Object? notStarted = null,Object? inProgress = null,Object? completed = null,Object? percent = null,}) {
  return _then(_self.copyWith(
subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,notStarted: null == notStarted ? _self.notStarted : notStarted // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressSummaryEntity].
extension ProgressSummaryEntityPatterns on ProgressSummaryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressSummaryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressSummaryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressSummaryEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProgressSummaryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressSummaryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressSummaryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String subjectId,  String subjectName,  String? gradeLevelId,  int total,  int notStarted,  int inProgress,  int completed,  int percent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressSummaryEntity() when $default != null:
return $default(_that.subjectId,_that.subjectName,_that.gradeLevelId,_that.total,_that.notStarted,_that.inProgress,_that.completed,_that.percent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String subjectId,  String subjectName,  String? gradeLevelId,  int total,  int notStarted,  int inProgress,  int completed,  int percent)  $default,) {final _that = this;
switch (_that) {
case _ProgressSummaryEntity():
return $default(_that.subjectId,_that.subjectName,_that.gradeLevelId,_that.total,_that.notStarted,_that.inProgress,_that.completed,_that.percent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String subjectId,  String subjectName,  String? gradeLevelId,  int total,  int notStarted,  int inProgress,  int completed,  int percent)?  $default,) {final _that = this;
switch (_that) {
case _ProgressSummaryEntity() when $default != null:
return $default(_that.subjectId,_that.subjectName,_that.gradeLevelId,_that.total,_that.notStarted,_that.inProgress,_that.completed,_that.percent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgressSummaryEntity extends ProgressSummaryEntity {
  const _ProgressSummaryEntity({required this.subjectId, this.subjectName = '', this.gradeLevelId, this.total = 0, this.notStarted = 0, this.inProgress = 0, this.completed = 0, this.percent = 0}): super._();
  factory _ProgressSummaryEntity.fromJson(Map<String, dynamic> json) => _$ProgressSummaryEntityFromJson(json);

@override final  String subjectId;
@override@JsonKey() final  String subjectName;
@override final  String? gradeLevelId;
@override@JsonKey() final  int total;
@override@JsonKey() final  int notStarted;
@override@JsonKey() final  int inProgress;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int percent;

/// Create a copy of ProgressSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressSummaryEntityCopyWith<_ProgressSummaryEntity> get copyWith => __$ProgressSummaryEntityCopyWithImpl<_ProgressSummaryEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgressSummaryEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressSummaryEntity&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.gradeLevelId, gradeLevelId) || other.gradeLevelId == gradeLevelId)&&(identical(other.total, total) || other.total == total)&&(identical(other.notStarted, notStarted) || other.notStarted == notStarted)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subjectId,subjectName,gradeLevelId,total,notStarted,inProgress,completed,percent);

@override
String toString() {
  return 'ProgressSummaryEntity(subjectId: $subjectId, subjectName: $subjectName, gradeLevelId: $gradeLevelId, total: $total, notStarted: $notStarted, inProgress: $inProgress, completed: $completed, percent: $percent)';
}


}

/// @nodoc
abstract mixin class _$ProgressSummaryEntityCopyWith<$Res> implements $ProgressSummaryEntityCopyWith<$Res> {
  factory _$ProgressSummaryEntityCopyWith(_ProgressSummaryEntity value, $Res Function(_ProgressSummaryEntity) _then) = __$ProgressSummaryEntityCopyWithImpl;
@override @useResult
$Res call({
 String subjectId, String subjectName, String? gradeLevelId, int total, int notStarted, int inProgress, int completed, int percent
});




}
/// @nodoc
class __$ProgressSummaryEntityCopyWithImpl<$Res>
    implements _$ProgressSummaryEntityCopyWith<$Res> {
  __$ProgressSummaryEntityCopyWithImpl(this._self, this._then);

  final _ProgressSummaryEntity _self;
  final $Res Function(_ProgressSummaryEntity) _then;

/// Create a copy of ProgressSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subjectId = null,Object? subjectName = null,Object? gradeLevelId = freezed,Object? total = null,Object? notStarted = null,Object? inProgress = null,Object? completed = null,Object? percent = null,}) {
  return _then(_ProgressSummaryEntity(
subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,gradeLevelId: freezed == gradeLevelId ? _self.gradeLevelId : gradeLevelId // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,notStarted: null == notStarted ? _self.notStarted : notStarted // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
