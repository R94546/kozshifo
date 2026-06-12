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
      flowStatus: json['flow_status'] as String? ?? 'registered',
      openedAt: json['opened_at'] as String,
      branchId: json['branch_id'] as String?,
    );

Map<String, dynamic> _$VisitSummaryToJson(_VisitSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visit_no': instance.visitNo,
      'status': instance.status,
      'flow_status': instance.flowStatus,
      'opened_at': instance.openedAt,
      'branch_id': instance.branchId,
    };
