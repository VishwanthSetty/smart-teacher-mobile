// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_download_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentDownloadEntity {

 String get url; int get expiresInSecs; String get fileName;
/// Create a copy of DocumentDownloadEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentDownloadEntityCopyWith<DocumentDownloadEntity> get copyWith => _$DocumentDownloadEntityCopyWithImpl<DocumentDownloadEntity>(this as DocumentDownloadEntity, _$identity);

  /// Serializes this DocumentDownloadEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentDownloadEntity&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresInSecs, expiresInSecs) || other.expiresInSecs == expiresInSecs)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,expiresInSecs,fileName);

@override
String toString() {
  return 'DocumentDownloadEntity(url: $url, expiresInSecs: $expiresInSecs, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $DocumentDownloadEntityCopyWith<$Res>  {
  factory $DocumentDownloadEntityCopyWith(DocumentDownloadEntity value, $Res Function(DocumentDownloadEntity) _then) = _$DocumentDownloadEntityCopyWithImpl;
@useResult
$Res call({
 String url, int expiresInSecs, String fileName
});




}
/// @nodoc
class _$DocumentDownloadEntityCopyWithImpl<$Res>
    implements $DocumentDownloadEntityCopyWith<$Res> {
  _$DocumentDownloadEntityCopyWithImpl(this._self, this._then);

  final DocumentDownloadEntity _self;
  final $Res Function(DocumentDownloadEntity) _then;

/// Create a copy of DocumentDownloadEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresInSecs = null,Object? fileName = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresInSecs: null == expiresInSecs ? _self.expiresInSecs : expiresInSecs // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentDownloadEntity].
extension DocumentDownloadEntityPatterns on DocumentDownloadEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentDownloadEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentDownloadEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentDownloadEntity value)  $default,){
final _that = this;
switch (_that) {
case _DocumentDownloadEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentDownloadEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentDownloadEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int expiresInSecs,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentDownloadEntity() when $default != null:
return $default(_that.url,_that.expiresInSecs,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int expiresInSecs,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _DocumentDownloadEntity():
return $default(_that.url,_that.expiresInSecs,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int expiresInSecs,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _DocumentDownloadEntity() when $default != null:
return $default(_that.url,_that.expiresInSecs,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentDownloadEntity implements DocumentDownloadEntity {
  const _DocumentDownloadEntity({required this.url, required this.expiresInSecs, required this.fileName});
  factory _DocumentDownloadEntity.fromJson(Map<String, dynamic> json) => _$DocumentDownloadEntityFromJson(json);

@override final  String url;
@override final  int expiresInSecs;
@override final  String fileName;

/// Create a copy of DocumentDownloadEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentDownloadEntityCopyWith<_DocumentDownloadEntity> get copyWith => __$DocumentDownloadEntityCopyWithImpl<_DocumentDownloadEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentDownloadEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDownloadEntity&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresInSecs, expiresInSecs) || other.expiresInSecs == expiresInSecs)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,expiresInSecs,fileName);

@override
String toString() {
  return 'DocumentDownloadEntity(url: $url, expiresInSecs: $expiresInSecs, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$DocumentDownloadEntityCopyWith<$Res> implements $DocumentDownloadEntityCopyWith<$Res> {
  factory _$DocumentDownloadEntityCopyWith(_DocumentDownloadEntity value, $Res Function(_DocumentDownloadEntity) _then) = __$DocumentDownloadEntityCopyWithImpl;
@override @useResult
$Res call({
 String url, int expiresInSecs, String fileName
});




}
/// @nodoc
class __$DocumentDownloadEntityCopyWithImpl<$Res>
    implements _$DocumentDownloadEntityCopyWith<$Res> {
  __$DocumentDownloadEntityCopyWithImpl(this._self, this._then);

  final _DocumentDownloadEntity _self;
  final $Res Function(_DocumentDownloadEntity) _then;

/// Create a copy of DocumentDownloadEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresInSecs = null,Object? fileName = null,}) {
  return _then(_DocumentDownloadEntity(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresInSecs: null == expiresInSecs ? _self.expiresInSecs : expiresInSecs // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
