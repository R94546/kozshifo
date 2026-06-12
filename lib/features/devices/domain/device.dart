import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

/// Medical device registry entry (mirrors backend `DeviceOut`).
@freezed
abstract class Device with _$Device {
  const Device._();

  const factory Device({
    required String id,
    required String name,
    required String deviceType,
    String? model,
    String? manufacturer,
    required String serialNo,
    String? assetCode,
    required String connectionType,
    String? branchId,
    String? branchName,
    required String status,
    String? manufactureDate,
    Map<String, dynamic>? settings,
    String? euRep,
    String? address,
    int? usefulLifeYears,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  String get typeLabel => switch (deviceType) {
        'refractometer' => 'Авторефрактометр',
        'ab_ultrasound' => 'A/B УЗ-сканер',
        _ => 'Прибор',
      };
}
