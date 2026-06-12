// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminBranch _$AdminBranchFromJson(Map<String, dynamic> json) => _AdminBranch(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$AdminBranchToJson(_AdminBranch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'address': instance.address,
      'phone': instance.phone,
      'is_active': instance.isActive,
    };
