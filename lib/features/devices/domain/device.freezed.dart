// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Device {

 String get id; String get name; String get deviceType; String? get model; String? get manufacturer; String get serialNo; String? get assetCode; String get connectionType; String? get branchId; String get status; String? get manufactureDate; Map<String, dynamic>? get settings; String? get euRep; String? get address; int? get usefulLifeYears;
/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCopyWith<Device> get copyWith => _$DeviceCopyWithImpl<Device>(this as Device, _$identity);

  /// Serializes this Device to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Device&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.model, model) || other.model == model)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.serialNo, serialNo) || other.serialNo == serialNo)&&(identical(other.assetCode, assetCode) || other.assetCode == assetCode)&&(identical(other.connectionType, connectionType) || other.connectionType == connectionType)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.status, status) || other.status == status)&&(identical(other.manufactureDate, manufactureDate) || other.manufactureDate == manufactureDate)&&const DeepCollectionEquality().equals(other.settings, settings)&&(identical(other.euRep, euRep) || other.euRep == euRep)&&(identical(other.address, address) || other.address == address)&&(identical(other.usefulLifeYears, usefulLifeYears) || other.usefulLifeYears == usefulLifeYears));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,deviceType,model,manufacturer,serialNo,assetCode,connectionType,branchId,status,manufactureDate,const DeepCollectionEquality().hash(settings),euRep,address,usefulLifeYears);

@override
String toString() {
  return 'Device(id: $id, name: $name, deviceType: $deviceType, model: $model, manufacturer: $manufacturer, serialNo: $serialNo, assetCode: $assetCode, connectionType: $connectionType, branchId: $branchId, status: $status, manufactureDate: $manufactureDate, settings: $settings, euRep: $euRep, address: $address, usefulLifeYears: $usefulLifeYears)';
}


}

/// @nodoc
abstract mixin class $DeviceCopyWith<$Res>  {
  factory $DeviceCopyWith(Device value, $Res Function(Device) _then) = _$DeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String deviceType, String? model, String? manufacturer, String serialNo, String? assetCode, String connectionType, String? branchId, String status, String? manufactureDate, Map<String, dynamic>? settings, String? euRep, String? address, int? usefulLifeYears
});




}
/// @nodoc
class _$DeviceCopyWithImpl<$Res>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._self, this._then);

  final Device _self;
  final $Res Function(Device) _then;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? deviceType = null,Object? model = freezed,Object? manufacturer = freezed,Object? serialNo = null,Object? assetCode = freezed,Object? connectionType = null,Object? branchId = freezed,Object? status = null,Object? manufactureDate = freezed,Object? settings = freezed,Object? euRep = freezed,Object? address = freezed,Object? usefulLifeYears = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,serialNo: null == serialNo ? _self.serialNo : serialNo // ignore: cast_nullable_to_non_nullable
as String,assetCode: freezed == assetCode ? _self.assetCode : assetCode // ignore: cast_nullable_to_non_nullable
as String?,connectionType: null == connectionType ? _self.connectionType : connectionType // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,manufactureDate: freezed == manufactureDate ? _self.manufactureDate : manufactureDate // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,euRep: freezed == euRep ? _self.euRep : euRep // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,usefulLifeYears: freezed == usefulLifeYears ? _self.usefulLifeYears : usefulLifeYears // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Device].
extension DevicePatterns on Device {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Device value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Device() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Device value)  $default,){
final _that = this;
switch (_that) {
case _Device():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Device value)?  $default,){
final _that = this;
switch (_that) {
case _Device() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String deviceType,  String? model,  String? manufacturer,  String serialNo,  String? assetCode,  String connectionType,  String? branchId,  String status,  String? manufactureDate,  Map<String, dynamic>? settings,  String? euRep,  String? address,  int? usefulLifeYears)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Device() when $default != null:
return $default(_that.id,_that.name,_that.deviceType,_that.model,_that.manufacturer,_that.serialNo,_that.assetCode,_that.connectionType,_that.branchId,_that.status,_that.manufactureDate,_that.settings,_that.euRep,_that.address,_that.usefulLifeYears);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String deviceType,  String? model,  String? manufacturer,  String serialNo,  String? assetCode,  String connectionType,  String? branchId,  String status,  String? manufactureDate,  Map<String, dynamic>? settings,  String? euRep,  String? address,  int? usefulLifeYears)  $default,) {final _that = this;
switch (_that) {
case _Device():
return $default(_that.id,_that.name,_that.deviceType,_that.model,_that.manufacturer,_that.serialNo,_that.assetCode,_that.connectionType,_that.branchId,_that.status,_that.manufactureDate,_that.settings,_that.euRep,_that.address,_that.usefulLifeYears);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String deviceType,  String? model,  String? manufacturer,  String serialNo,  String? assetCode,  String connectionType,  String? branchId,  String status,  String? manufactureDate,  Map<String, dynamic>? settings,  String? euRep,  String? address,  int? usefulLifeYears)?  $default,) {final _that = this;
switch (_that) {
case _Device() when $default != null:
return $default(_that.id,_that.name,_that.deviceType,_that.model,_that.manufacturer,_that.serialNo,_that.assetCode,_that.connectionType,_that.branchId,_that.status,_that.manufactureDate,_that.settings,_that.euRep,_that.address,_that.usefulLifeYears);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Device extends Device {
  const _Device({required this.id, required this.name, required this.deviceType, this.model, this.manufacturer, required this.serialNo, this.assetCode, required this.connectionType, this.branchId, required this.status, this.manufactureDate, final  Map<String, dynamic>? settings, this.euRep, this.address, this.usefulLifeYears}): _settings = settings,super._();
  factory _Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

@override final  String id;
@override final  String name;
@override final  String deviceType;
@override final  String? model;
@override final  String? manufacturer;
@override final  String serialNo;
@override final  String? assetCode;
@override final  String connectionType;
@override final  String? branchId;
@override final  String status;
@override final  String? manufactureDate;
 final  Map<String, dynamic>? _settings;
@override Map<String, dynamic>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? euRep;
@override final  String? address;
@override final  int? usefulLifeYears;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceCopyWith<_Device> get copyWith => __$DeviceCopyWithImpl<_Device>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Device&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.model, model) || other.model == model)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.serialNo, serialNo) || other.serialNo == serialNo)&&(identical(other.assetCode, assetCode) || other.assetCode == assetCode)&&(identical(other.connectionType, connectionType) || other.connectionType == connectionType)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.status, status) || other.status == status)&&(identical(other.manufactureDate, manufactureDate) || other.manufactureDate == manufactureDate)&&const DeepCollectionEquality().equals(other._settings, _settings)&&(identical(other.euRep, euRep) || other.euRep == euRep)&&(identical(other.address, address) || other.address == address)&&(identical(other.usefulLifeYears, usefulLifeYears) || other.usefulLifeYears == usefulLifeYears));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,deviceType,model,manufacturer,serialNo,assetCode,connectionType,branchId,status,manufactureDate,const DeepCollectionEquality().hash(_settings),euRep,address,usefulLifeYears);

@override
String toString() {
  return 'Device(id: $id, name: $name, deviceType: $deviceType, model: $model, manufacturer: $manufacturer, serialNo: $serialNo, assetCode: $assetCode, connectionType: $connectionType, branchId: $branchId, status: $status, manufactureDate: $manufactureDate, settings: $settings, euRep: $euRep, address: $address, usefulLifeYears: $usefulLifeYears)';
}


}

/// @nodoc
abstract mixin class _$DeviceCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$DeviceCopyWith(_Device value, $Res Function(_Device) _then) = __$DeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String deviceType, String? model, String? manufacturer, String serialNo, String? assetCode, String connectionType, String? branchId, String status, String? manufactureDate, Map<String, dynamic>? settings, String? euRep, String? address, int? usefulLifeYears
});




}
/// @nodoc
class __$DeviceCopyWithImpl<$Res>
    implements _$DeviceCopyWith<$Res> {
  __$DeviceCopyWithImpl(this._self, this._then);

  final _Device _self;
  final $Res Function(_Device) _then;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? deviceType = null,Object? model = freezed,Object? manufacturer = freezed,Object? serialNo = null,Object? assetCode = freezed,Object? connectionType = null,Object? branchId = freezed,Object? status = null,Object? manufactureDate = freezed,Object? settings = freezed,Object? euRep = freezed,Object? address = freezed,Object? usefulLifeYears = freezed,}) {
  return _then(_Device(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,serialNo: null == serialNo ? _self.serialNo : serialNo // ignore: cast_nullable_to_non_nullable
as String,assetCode: freezed == assetCode ? _self.assetCode : assetCode // ignore: cast_nullable_to_non_nullable
as String?,connectionType: null == connectionType ? _self.connectionType : connectionType // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,manufactureDate: freezed == manufactureDate ? _self.manufactureDate : manufactureDate // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,euRep: freezed == euRep ? _self.euRep : euRep // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,usefulLifeYears: freezed == usefulLifeYears ? _self.usefulLifeYears : usefulLifeYears // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
