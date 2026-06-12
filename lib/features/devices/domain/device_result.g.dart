// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceResult _$DeviceResultFromJson(Map<String, dynamic> json) =>
    _DeviceResult(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      patientId: json['patient_id'] as String?,
      visitId: json['visit_id'] as String?,
      resultType: json['result_type'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      filePath: json['file_path'] as String?,
      measuredAt: json['measured_at'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$DeviceResultToJson(_DeviceResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'patient_id': instance.patientId,
      'visit_id': instance.visitId,
      'result_type': instance.resultType,
      'payload': instance.payload,
      'file_path': instance.filePath,
      'measured_at': instance.measuredAt,
      'source': instance.source,
    };
