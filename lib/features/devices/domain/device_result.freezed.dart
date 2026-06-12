// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceResult {

 String get id; String get deviceId; String? get patientId; String? get visitId; String get resultType; Map<String, dynamic>? get payload; String? get filePath; String get measuredAt; String get source;
/// Create a copy of DeviceResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceResultCopyWith<DeviceResult> get copyWith => _$DeviceResultCopyWithImpl<DeviceResult>(this as DeviceResult, _$identity);

  /// Serializes this DeviceResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceResult&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.visitId, visitId) || other.visitId == visitId)&&(identical(other.resultType, resultType) || other.resultType == resultType)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,patientId,visitId,resultType,const DeepCollectionEquality().hash(payload),filePath,measuredAt,source);

@override
String toString() {
  return 'DeviceResult(id: $id, deviceId: $deviceId, patientId: $patientId, visitId: $visitId, resultType: $resultType, payload: $payload, filePath: $filePath, measuredAt: $measuredAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $DeviceResultCopyWith<$Res>  {
  factory $DeviceResultCopyWith(DeviceResult value, $Res Function(DeviceResult) _then) = _$DeviceResultCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String? patientId, String? visitId, String resultType, Map<String, dynamic>? payload, String? filePath, String measuredAt, String source
});




}
/// @nodoc
class _$DeviceResultCopyWithImpl<$Res>
    implements $DeviceResultCopyWith<$Res> {
  _$DeviceResultCopyWithImpl(this._self, this._then);

  final DeviceResult _self;
  final $Res Function(DeviceResult) _then;

/// Create a copy of DeviceResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? patientId = freezed,Object? visitId = freezed,Object? resultType = null,Object? payload = freezed,Object? filePath = freezed,Object? measuredAt = null,Object? source = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,patientId: freezed == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String?,visitId: freezed == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String?,resultType: null == resultType ? _self.resultType : resultType // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceResult].
extension DeviceResultPatterns on DeviceResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceResult value)  $default,){
final _that = this;
switch (_that) {
case _DeviceResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceResult value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String? patientId,  String? visitId,  String resultType,  Map<String, dynamic>? payload,  String? filePath,  String measuredAt,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceResult() when $default != null:
return $default(_that.id,_that.deviceId,_that.patientId,_that.visitId,_that.resultType,_that.payload,_that.filePath,_that.measuredAt,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String? patientId,  String? visitId,  String resultType,  Map<String, dynamic>? payload,  String? filePath,  String measuredAt,  String source)  $default,) {final _that = this;
switch (_that) {
case _DeviceResult():
return $default(_that.id,_that.deviceId,_that.patientId,_that.visitId,_that.resultType,_that.payload,_that.filePath,_that.measuredAt,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String? patientId,  String? visitId,  String resultType,  Map<String, dynamic>? payload,  String? filePath,  String measuredAt,  String source)?  $default,) {final _that = this;
switch (_that) {
case _DeviceResult() when $default != null:
return $default(_that.id,_that.deviceId,_that.patientId,_that.visitId,_that.resultType,_that.payload,_that.filePath,_that.measuredAt,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceResult extends DeviceResult {
  const _DeviceResult({required this.id, required this.deviceId, this.patientId, this.visitId, required this.resultType, final  Map<String, dynamic>? payload, this.filePath, required this.measuredAt, required this.source}): _payload = payload,super._();
  factory _DeviceResult.fromJson(Map<String, dynamic> json) => _$DeviceResultFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String? patientId;
@override final  String? visitId;
@override final  String resultType;
 final  Map<String, dynamic>? _payload;
@override Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? filePath;
@override final  String measuredAt;
@override final  String source;

/// Create a copy of DeviceResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceResultCopyWith<_DeviceResult> get copyWith => __$DeviceResultCopyWithImpl<_DeviceResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceResult&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.visitId, visitId) || other.visitId == visitId)&&(identical(other.resultType, resultType) || other.resultType == resultType)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,patientId,visitId,resultType,const DeepCollectionEquality().hash(_payload),filePath,measuredAt,source);

@override
String toString() {
  return 'DeviceResult(id: $id, deviceId: $deviceId, patientId: $patientId, visitId: $visitId, resultType: $resultType, payload: $payload, filePath: $filePath, measuredAt: $measuredAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$DeviceResultCopyWith<$Res> implements $DeviceResultCopyWith<$Res> {
  factory _$DeviceResultCopyWith(_DeviceResult value, $Res Function(_DeviceResult) _then) = __$DeviceResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String? patientId, String? visitId, String resultType, Map<String, dynamic>? payload, String? filePath, String measuredAt, String source
});




}
/// @nodoc
class __$DeviceResultCopyWithImpl<$Res>
    implements _$DeviceResultCopyWith<$Res> {
  __$DeviceResultCopyWithImpl(this._self, this._then);

  final _DeviceResult _self;
  final $Res Function(_DeviceResult) _then;

/// Create a copy of DeviceResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? patientId = freezed,Object? visitId = freezed,Object? resultType = null,Object? payload = freezed,Object? filePath = freezed,Object? measuredAt = null,Object? source = null,}) {
  return _then(_DeviceResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,patientId: freezed == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String?,visitId: freezed == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String?,resultType: null == resultType ? _self.resultType : resultType // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
