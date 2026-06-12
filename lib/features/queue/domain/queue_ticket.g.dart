// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QueueTicket _$QueueTicketFromJson(Map<String, dynamic> json) => _QueueTicket(
  id: json['id'] as String,
  ticketNumber: json['ticket_number'] as String,
  patientId: json['patient_id'] as String,
  branchId: json['branch_id'] as String,
  visitId: json['visit_id'] as String?,
  serviceId: json['service_id'] as String?,
  room: json['room'] as String?,
  status: json['status'] as String,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  calledAt: json['called_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$QueueTicketToJson(_QueueTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_number': instance.ticketNumber,
      'patient_id': instance.patientId,
      'branch_id': instance.branchId,
      'visit_id': instance.visitId,
      'service_id': instance.serviceId,
      'room': instance.room,
      'status': instance.status,
      'priority': instance.priority,
      'called_at': instance.calledAt,
      'created_at': instance.createdAt,
    };
