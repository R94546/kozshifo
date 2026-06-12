// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Device _$DeviceFromJson(Map<String, dynamic> json) => _Device(
  id: json['id'] as String,
  name: json['name'] as String,
  deviceType: json['device_type'] as String,
  model: json['model'] as String?,
  manufacturer: json['manufacturer'] as String?,
  serialNo: json['serial_no'] as String,
  assetCode: json['asset_code'] as String?,
  connectionType: json['connection_type'] as String,
  branchId: json['branch_id'] as String?,
  branchName: json['branch_name'] as String?,
  status: json['status'] as String,
  manufactureDate: json['manufacture_date'] as String?,
  settings: json['settings'] as Map<String, dynamic>?,
  euRep: json['eu_rep'] as String?,
  address: json['address'] as String?,
  usefulLifeYears: (json['useful_life_years'] as num?)?.toInt(),
);

Map<String, dynamic> _$DeviceToJson(_Device instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'device_type': instance.deviceType,
  'model': instance.model,
  'manufacturer': instance.manufacturer,
  'serial_no': instance.serialNo,
  'asset_code': instance.assetCode,
  'connection_type': instance.connectionType,
  'branch_id': instance.branchId,
  'branch_name': instance.branchName,
  'status': instance.status,
  'manufacture_date': instance.manufactureDate,
  'settings': instance.settings,
  'eu_rep': instance.euRep,
  'address': instance.address,
  'useful_life_years': instance.usefulLifeYears,
};
