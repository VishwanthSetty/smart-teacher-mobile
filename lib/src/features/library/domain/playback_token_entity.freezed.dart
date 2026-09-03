// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_token_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackTokenEntity {

 String get videoId; String get manifestUrl; String? get posterUrl; int? get durationSecs; int get expiresInSecs;
/// Create a copy of PlaybackTokenEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackTokenEntityCopyWith<PlaybackTokenEntity> get copyWith => _$PlaybackTokenEntityCopyWithImpl<PlaybackTokenEntity>(this as PlaybackTokenEntity, _$identity);

  /// Serializes this PlaybackTokenEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackTokenEntity&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.manifestUrl, manifestUrl) || other.manifestUrl == manifestUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.expiresInSecs, expiresInSecs) || other.expiresInSecs == expiresInSecs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,manifestUrl,posterUrl,durationSecs,expiresInSecs);

@override
String toString() {
  return 'PlaybackTokenEntity(videoId: $videoId, manifestUrl: $manifestUrl, posterUrl: $posterUrl, durationSecs: $durationSecs, expiresInSecs: $expiresInSecs)';
}


}

/// @nodoc
abstract mixin class $PlaybackTokenEntityCopyWith<$Res>  {
  factory $PlaybackTokenEntityCopyWith(PlaybackTokenEntity value, $Res Function(PlaybackTokenEntity) _then) = _$PlaybackTokenEntityCopyWithImpl;
@useResult
$Res call({
 String videoId, String manifestUrl, String? posterUrl, int? durationSecs, int expiresInSecs
});




}
/// @nodoc
class _$PlaybackTokenEntityCopyWithImpl<$Res>
    implements $PlaybackTokenEntityCopyWith<$Res> {
  _$PlaybackTokenEntityCopyWithImpl(this._self, this._then);

  final PlaybackTokenEntity _self;
  final $Res Function(PlaybackTokenEntity) _then;

/// Create a copy of PlaybackTokenEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? manifestUrl = null,Object? posterUrl = freezed,Object? durationSecs = freezed,Object? expiresInSecs = null,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,manifestUrl: null == manifestUrl ? _self.manifestUrl : manifestUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,expiresInSecs: null == expiresInSecs ? _self.expiresInSecs : expiresInSecs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackTokenEntity].
extension PlaybackTokenEntityPatterns on PlaybackTokenEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackTokenEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackTokenEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackTokenEntity value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackTokenEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackTokenEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackTokenEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String manifestUrl,  String? posterUrl,  int? durationSecs,  int expiresInSecs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackTokenEntity() when $default != null:
return $default(_that.videoId,_that.manifestUrl,_that.posterUrl,_that.durationSecs,_that.expiresInSecs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String manifestUrl,  String? posterUrl,  int? durationSecs,  int expiresInSecs)  $default,) {final _that = this;
switch (_that) {
case _PlaybackTokenEntity():
return $default(_that.videoId,_that.manifestUrl,_that.posterUrl,_that.durationSecs,_that.expiresInSecs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String manifestUrl,  String? posterUrl,  int? durationSecs,  int expiresInSecs)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackTokenEntity() when $default != null:
return $default(_that.videoId,_that.manifestUrl,_that.posterUrl,_that.durationSecs,_that.expiresInSecs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackTokenEntity extends PlaybackTokenEntity {
  const _PlaybackTokenEntity({required this.videoId, required this.manifestUrl, required this.posterUrl, required this.durationSecs, required this.expiresInSecs}): super._();
  factory _PlaybackTokenEntity.fromJson(Map<String, dynamic> json) => _$PlaybackTokenEntityFromJson(json);

@override final  String videoId;
@override final  String manifestUrl;
@override final  String? posterUrl;
@override final  int? durationSecs;
@override final  int expiresInSecs;

/// Create a copy of PlaybackTokenEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackTokenEntityCopyWith<_PlaybackTokenEntity> get copyWith => __$PlaybackTokenEntityCopyWithImpl<_PlaybackTokenEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackTokenEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackTokenEntity&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.manifestUrl, manifestUrl) || other.manifestUrl == manifestUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.durationSecs, durationSecs) || other.durationSecs == durationSecs)&&(identical(other.expiresInSecs, expiresInSecs) || other.expiresInSecs == expiresInSecs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,manifestUrl,posterUrl,durationSecs,expiresInSecs);

@override
String toString() {
  return 'PlaybackTokenEntity(videoId: $videoId, manifestUrl: $manifestUrl, posterUrl: $posterUrl, durationSecs: $durationSecs, expiresInSecs: $expiresInSecs)';
}


}

/// @nodoc
abstract mixin class _$PlaybackTokenEntityCopyWith<$Res> implements $PlaybackTokenEntityCopyWith<$Res> {
  factory _$PlaybackTokenEntityCopyWith(_PlaybackTokenEntity value, $Res Function(_PlaybackTokenEntity) _then) = __$PlaybackTokenEntityCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String manifestUrl, String? posterUrl, int? durationSecs, int expiresInSecs
});




}
/// @nodoc
class __$PlaybackTokenEntityCopyWithImpl<$Res>
    implements _$PlaybackTokenEntityCopyWith<$Res> {
  __$PlaybackTokenEntityCopyWithImpl(this._self, this._then);

  final _PlaybackTokenEntity _self;
  final $Res Function(_PlaybackTokenEntity) _then;

/// Create a copy of PlaybackTokenEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? manifestUrl = null,Object? posterUrl = freezed,Object? durationSecs = freezed,Object? expiresInSecs = null,}) {
  return _then(_PlaybackTokenEntity(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,manifestUrl: null == manifestUrl ? _self.manifestUrl : manifestUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,durationSecs: freezed == durationSecs ? _self.durationSecs : durationSecs // ignore: cast_nullable_to_non_nullable
as int?,expiresInSecs: null == expiresInSecs ? _self.expiresInSecs : expiresInSecs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
