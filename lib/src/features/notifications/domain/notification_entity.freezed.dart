// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationEntity {

 String get id;@JsonKey(unknownEnumValue: NotificationKind.unknown) NotificationKind get type; String get title; String get body; Map<String, dynamic> get data;/// Null while unread. The server stamps it on the first `read` and leaves
/// it alone afterwards, so it is also "when you first read this".
 DateTime? get readAt; DateTime? get createdAt;
/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationEntityCopyWith<NotificationEntity> get copyWith => _$NotificationEntityCopyWithImpl<NotificationEntity>(this as NotificationEntity, _$identity);

  /// Serializes this NotificationEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,body,const DeepCollectionEquality().hash(data),readAt,createdAt);

@override
String toString() {
  return 'NotificationEntity(id: $id, type: $type, title: $title, body: $body, data: $data, readAt: $readAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $NotificationEntityCopyWith<$Res>  {
  factory $NotificationEntityCopyWith(NotificationEntity value, $Res Function(NotificationEntity) _then) = _$NotificationEntityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: NotificationKind.unknown) NotificationKind type, String title, String body, Map<String, dynamic> data, DateTime? readAt, DateTime? createdAt
});




}
/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._self, this._then);

  final NotificationEntity _self;
  final $Res Function(NotificationEntity) _then;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? data = null,Object? readAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationEntity].
extension NotificationEntityPatterns on NotificationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationEntity value)  $default,){
final _that = this;
switch (_that) {
case _NotificationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: NotificationKind.unknown)  NotificationKind type,  String title,  String body,  Map<String, dynamic> data,  DateTime? readAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.data,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: NotificationKind.unknown)  NotificationKind type,  String title,  String body,  Map<String, dynamic> data,  DateTime? readAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationEntity():
return $default(_that.id,_that.type,_that.title,_that.body,_that.data,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: NotificationKind.unknown)  NotificationKind type,  String title,  String body,  Map<String, dynamic> data,  DateTime? readAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.data,_that.readAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationEntity extends NotificationEntity {
  const _NotificationEntity({required this.id, @JsonKey(unknownEnumValue: NotificationKind.unknown) this.type = NotificationKind.unknown, this.title = '', this.body = '', final  Map<String, dynamic> data = const <String, dynamic>{}, this.readAt, this.createdAt}): _data = data,super._();
  factory _NotificationEntity.fromJson(Map<String, dynamic> json) => _$NotificationEntityFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: NotificationKind.unknown) final  NotificationKind type;
@override@JsonKey() final  String title;
@override@JsonKey() final  String body;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

/// Null while unread. The server stamps it on the first `read` and leaves
/// it alone afterwards, so it is also "when you first read this".
@override final  DateTime? readAt;
@override final  DateTime? createdAt;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationEntityCopyWith<_NotificationEntity> get copyWith => __$NotificationEntityCopyWithImpl<_NotificationEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,body,const DeepCollectionEquality().hash(_data),readAt,createdAt);

@override
String toString() {
  return 'NotificationEntity(id: $id, type: $type, title: $title, body: $body, data: $data, readAt: $readAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationEntityCopyWith<$Res> implements $NotificationEntityCopyWith<$Res> {
  factory _$NotificationEntityCopyWith(_NotificationEntity value, $Res Function(_NotificationEntity) _then) = __$NotificationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: NotificationKind.unknown) NotificationKind type, String title, String body, Map<String, dynamic> data, DateTime? readAt, DateTime? createdAt
});




}
/// @nodoc
class __$NotificationEntityCopyWithImpl<$Res>
    implements _$NotificationEntityCopyWith<$Res> {
  __$NotificationEntityCopyWithImpl(this._self, this._then);

  final _NotificationEntity _self;
  final $Res Function(_NotificationEntity) _then;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? data = null,Object? readAt = freezed,Object? createdAt = freezed,}) {
  return _then(_NotificationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationPreferenceEntity {

 bool get inAppEnabled; bool get pushEnabled; bool get taskRemindersEnabled;/// How long before a due date the "due soon" alert fires, in minutes.
/// Server default is 1440 (a day); the DTO caps it at 10080 (a week).
 int? get dueSoonLeadMins;/// Minutes past UTC midnight. Both null means "no quiet hours".
 int? get quietFromMins; int? get quietToMins;
/// Create a copy of NotificationPreferenceEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferenceEntityCopyWith<NotificationPreferenceEntity> get copyWith => _$NotificationPreferenceEntityCopyWithImpl<NotificationPreferenceEntity>(this as NotificationPreferenceEntity, _$identity);

  /// Serializes this NotificationPreferenceEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferenceEntity&&(identical(other.inAppEnabled, inAppEnabled) || other.inAppEnabled == inAppEnabled)&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.taskRemindersEnabled, taskRemindersEnabled) || other.taskRemindersEnabled == taskRemindersEnabled)&&(identical(other.dueSoonLeadMins, dueSoonLeadMins) || other.dueSoonLeadMins == dueSoonLeadMins)&&(identical(other.quietFromMins, quietFromMins) || other.quietFromMins == quietFromMins)&&(identical(other.quietToMins, quietToMins) || other.quietToMins == quietToMins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inAppEnabled,pushEnabled,taskRemindersEnabled,dueSoonLeadMins,quietFromMins,quietToMins);

@override
String toString() {
  return 'NotificationPreferenceEntity(inAppEnabled: $inAppEnabled, pushEnabled: $pushEnabled, taskRemindersEnabled: $taskRemindersEnabled, dueSoonLeadMins: $dueSoonLeadMins, quietFromMins: $quietFromMins, quietToMins: $quietToMins)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferenceEntityCopyWith<$Res>  {
  factory $NotificationPreferenceEntityCopyWith(NotificationPreferenceEntity value, $Res Function(NotificationPreferenceEntity) _then) = _$NotificationPreferenceEntityCopyWithImpl;
@useResult
$Res call({
 bool inAppEnabled, bool pushEnabled, bool taskRemindersEnabled, int? dueSoonLeadMins, int? quietFromMins, int? quietToMins
});




}
/// @nodoc
class _$NotificationPreferenceEntityCopyWithImpl<$Res>
    implements $NotificationPreferenceEntityCopyWith<$Res> {
  _$NotificationPreferenceEntityCopyWithImpl(this._self, this._then);

  final NotificationPreferenceEntity _self;
  final $Res Function(NotificationPreferenceEntity) _then;

/// Create a copy of NotificationPreferenceEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inAppEnabled = null,Object? pushEnabled = null,Object? taskRemindersEnabled = null,Object? dueSoonLeadMins = freezed,Object? quietFromMins = freezed,Object? quietToMins = freezed,}) {
  return _then(_self.copyWith(
inAppEnabled: null == inAppEnabled ? _self.inAppEnabled : inAppEnabled // ignore: cast_nullable_to_non_nullable
as bool,pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,taskRemindersEnabled: null == taskRemindersEnabled ? _self.taskRemindersEnabled : taskRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,dueSoonLeadMins: freezed == dueSoonLeadMins ? _self.dueSoonLeadMins : dueSoonLeadMins // ignore: cast_nullable_to_non_nullable
as int?,quietFromMins: freezed == quietFromMins ? _self.quietFromMins : quietFromMins // ignore: cast_nullable_to_non_nullable
as int?,quietToMins: freezed == quietToMins ? _self.quietToMins : quietToMins // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferenceEntity].
extension NotificationPreferenceEntityPatterns on NotificationPreferenceEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferenceEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferenceEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferenceEntity value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferenceEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferenceEntity value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferenceEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool inAppEnabled,  bool pushEnabled,  bool taskRemindersEnabled,  int? dueSoonLeadMins,  int? quietFromMins,  int? quietToMins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferenceEntity() when $default != null:
return $default(_that.inAppEnabled,_that.pushEnabled,_that.taskRemindersEnabled,_that.dueSoonLeadMins,_that.quietFromMins,_that.quietToMins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool inAppEnabled,  bool pushEnabled,  bool taskRemindersEnabled,  int? dueSoonLeadMins,  int? quietFromMins,  int? quietToMins)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferenceEntity():
return $default(_that.inAppEnabled,_that.pushEnabled,_that.taskRemindersEnabled,_that.dueSoonLeadMins,_that.quietFromMins,_that.quietToMins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool inAppEnabled,  bool pushEnabled,  bool taskRemindersEnabled,  int? dueSoonLeadMins,  int? quietFromMins,  int? quietToMins)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferenceEntity() when $default != null:
return $default(_that.inAppEnabled,_that.pushEnabled,_that.taskRemindersEnabled,_that.dueSoonLeadMins,_that.quietFromMins,_that.quietToMins);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferenceEntity extends NotificationPreferenceEntity {
  const _NotificationPreferenceEntity({this.inAppEnabled = true, this.pushEnabled = true, this.taskRemindersEnabled = true, this.dueSoonLeadMins = 1440, this.quietFromMins, this.quietToMins}): super._();
  factory _NotificationPreferenceEntity.fromJson(Map<String, dynamic> json) => _$NotificationPreferenceEntityFromJson(json);

@override@JsonKey() final  bool inAppEnabled;
@override@JsonKey() final  bool pushEnabled;
@override@JsonKey() final  bool taskRemindersEnabled;
/// How long before a due date the "due soon" alert fires, in minutes.
/// Server default is 1440 (a day); the DTO caps it at 10080 (a week).
@override@JsonKey() final  int? dueSoonLeadMins;
/// Minutes past UTC midnight. Both null means "no quiet hours".
@override final  int? quietFromMins;
@override final  int? quietToMins;

/// Create a copy of NotificationPreferenceEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferenceEntityCopyWith<_NotificationPreferenceEntity> get copyWith => __$NotificationPreferenceEntityCopyWithImpl<_NotificationPreferenceEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferenceEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferenceEntity&&(identical(other.inAppEnabled, inAppEnabled) || other.inAppEnabled == inAppEnabled)&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.taskRemindersEnabled, taskRemindersEnabled) || other.taskRemindersEnabled == taskRemindersEnabled)&&(identical(other.dueSoonLeadMins, dueSoonLeadMins) || other.dueSoonLeadMins == dueSoonLeadMins)&&(identical(other.quietFromMins, quietFromMins) || other.quietFromMins == quietFromMins)&&(identical(other.quietToMins, quietToMins) || other.quietToMins == quietToMins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inAppEnabled,pushEnabled,taskRemindersEnabled,dueSoonLeadMins,quietFromMins,quietToMins);

@override
String toString() {
  return 'NotificationPreferenceEntity(inAppEnabled: $inAppEnabled, pushEnabled: $pushEnabled, taskRemindersEnabled: $taskRemindersEnabled, dueSoonLeadMins: $dueSoonLeadMins, quietFromMins: $quietFromMins, quietToMins: $quietToMins)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferenceEntityCopyWith<$Res> implements $NotificationPreferenceEntityCopyWith<$Res> {
  factory _$NotificationPreferenceEntityCopyWith(_NotificationPreferenceEntity value, $Res Function(_NotificationPreferenceEntity) _then) = __$NotificationPreferenceEntityCopyWithImpl;
@override @useResult
$Res call({
 bool inAppEnabled, bool pushEnabled, bool taskRemindersEnabled, int? dueSoonLeadMins, int? quietFromMins, int? quietToMins
});




}
/// @nodoc
class __$NotificationPreferenceEntityCopyWithImpl<$Res>
    implements _$NotificationPreferenceEntityCopyWith<$Res> {
  __$NotificationPreferenceEntityCopyWithImpl(this._self, this._then);

  final _NotificationPreferenceEntity _self;
  final $Res Function(_NotificationPreferenceEntity) _then;

/// Create a copy of NotificationPreferenceEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inAppEnabled = null,Object? pushEnabled = null,Object? taskRemindersEnabled = null,Object? dueSoonLeadMins = freezed,Object? quietFromMins = freezed,Object? quietToMins = freezed,}) {
  return _then(_NotificationPreferenceEntity(
inAppEnabled: null == inAppEnabled ? _self.inAppEnabled : inAppEnabled // ignore: cast_nullable_to_non_nullable
as bool,pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,taskRemindersEnabled: null == taskRemindersEnabled ? _self.taskRemindersEnabled : taskRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,dueSoonLeadMins: freezed == dueSoonLeadMins ? _self.dueSoonLeadMins : dueSoonLeadMins // ignore: cast_nullable_to_non_nullable
as int?,quietFromMins: freezed == quietFromMins ? _self.quietFromMins : quietFromMins // ignore: cast_nullable_to_non_nullable
as int?,quietToMins: freezed == quietToMins ? _self.quietToMins : quietToMins // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DeviceRegistrationEntity {

 String get id; String get platform; DateTime? get lastSeenAt;
/// Create a copy of DeviceRegistrationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceRegistrationEntityCopyWith<DeviceRegistrationEntity> get copyWith => _$DeviceRegistrationEntityCopyWithImpl<DeviceRegistrationEntity>(this as DeviceRegistrationEntity, _$identity);

  /// Serializes this DeviceRegistrationEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceRegistrationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,lastSeenAt);

@override
String toString() {
  return 'DeviceRegistrationEntity(id: $id, platform: $platform, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $DeviceRegistrationEntityCopyWith<$Res>  {
  factory $DeviceRegistrationEntityCopyWith(DeviceRegistrationEntity value, $Res Function(DeviceRegistrationEntity) _then) = _$DeviceRegistrationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String platform, DateTime? lastSeenAt
});




}
/// @nodoc
class _$DeviceRegistrationEntityCopyWithImpl<$Res>
    implements $DeviceRegistrationEntityCopyWith<$Res> {
  _$DeviceRegistrationEntityCopyWithImpl(this._self, this._then);

  final DeviceRegistrationEntity _self;
  final $Res Function(DeviceRegistrationEntity) _then;

/// Create a copy of DeviceRegistrationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? platform = null,Object? lastSeenAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceRegistrationEntity].
extension DeviceRegistrationEntityPatterns on DeviceRegistrationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceRegistrationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceRegistrationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceRegistrationEntity value)  $default,){
final _that = this;
switch (_that) {
case _DeviceRegistrationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceRegistrationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceRegistrationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String platform,  DateTime? lastSeenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceRegistrationEntity() when $default != null:
return $default(_that.id,_that.platform,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String platform,  DateTime? lastSeenAt)  $default,) {final _that = this;
switch (_that) {
case _DeviceRegistrationEntity():
return $default(_that.id,_that.platform,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String platform,  DateTime? lastSeenAt)?  $default,) {final _that = this;
switch (_that) {
case _DeviceRegistrationEntity() when $default != null:
return $default(_that.id,_that.platform,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceRegistrationEntity extends DeviceRegistrationEntity {
  const _DeviceRegistrationEntity({required this.id, this.platform = '', this.lastSeenAt}): super._();
  factory _DeviceRegistrationEntity.fromJson(Map<String, dynamic> json) => _$DeviceRegistrationEntityFromJson(json);

@override final  String id;
@override@JsonKey() final  String platform;
@override final  DateTime? lastSeenAt;

/// Create a copy of DeviceRegistrationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceRegistrationEntityCopyWith<_DeviceRegistrationEntity> get copyWith => __$DeviceRegistrationEntityCopyWithImpl<_DeviceRegistrationEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceRegistrationEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceRegistrationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,lastSeenAt);

@override
String toString() {
  return 'DeviceRegistrationEntity(id: $id, platform: $platform, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class _$DeviceRegistrationEntityCopyWith<$Res> implements $DeviceRegistrationEntityCopyWith<$Res> {
  factory _$DeviceRegistrationEntityCopyWith(_DeviceRegistrationEntity value, $Res Function(_DeviceRegistrationEntity) _then) = __$DeviceRegistrationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String platform, DateTime? lastSeenAt
});




}
/// @nodoc
class __$DeviceRegistrationEntityCopyWithImpl<$Res>
    implements _$DeviceRegistrationEntityCopyWith<$Res> {
  __$DeviceRegistrationEntityCopyWithImpl(this._self, this._then);

  final _DeviceRegistrationEntity _self;
  final $Res Function(_DeviceRegistrationEntity) _then;

/// Create a copy of DeviceRegistrationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? platform = null,Object? lastSeenAt = freezed,}) {
  return _then(_DeviceRegistrationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
