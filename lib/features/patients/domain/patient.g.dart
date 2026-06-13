// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Patient _$PatientFromJson(Map<String, dynamic> json) => _Patient(
  id: json['id'] as String,
  mrn: json['mrn'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  middleName: json['middle_name'] as String?,
  fullName: json['full_name'] as String,
  birthDate: json['birth_date'] as String?,
  gender: json['gender'] as String?,
  phone: json['phone'] as String?,
  phone2: json['phone2'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  passport: json['passport'] as String?,
  pinfl: json['pinfl'] as String?,
  leadSource: json['lead_source'] as String?,
  workplace: json['workplace'] as String?,
  profession: json['profession'] as String?,
  dispensaryHere: json['dispensary_here'] as String?,
  dispensaryOther: json['dispensary_other'] as String?,
  notes: json['notes'] as String?,
  branchId: json['branch_id'] as String?,
);

Map<String, dynamic> _$PatientToJson(_Patient instance) => <String, dynamic>{
  'id': instance.id,
  'mrn': instance.mrn,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
  'full_name': instance.fullName,
  'birth_date': instance.birthDate,
  'gender': instance.gender,
  'phone': instance.phone,
  'phone2': instance.phone2,
  'email': instance.email,
  'address': instance.address,
  'passport': instance.passport,
  'pinfl': instance.pinfl,
  'lead_source': instance.leadSource,
  'workplace': instance.workplace,
  'profession': instance.profession,
  'dispensary_here': instance.dispensaryHere,
  'dispensary_other': instance.dispensaryOther,
  'notes': instance.notes,
  'branch_id': instance.branchId,
};
