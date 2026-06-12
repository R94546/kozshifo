// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VisitSummary _$VisitSummaryFromJson(Map<String, dynamic> json) =>
    _VisitSummary(
      id: json['id'] as String,
      visitNo: json['visit_no'] as String,
      status: json['status'] as String,
      openedAt: json['opened_at'] as String,
    );

Map<String, dynamic> _$VisitSummaryToJson(_VisitSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visit_no': instance.visitNo,
      'status': instance.status,
      'opened_at': instance.openedAt,
    };
