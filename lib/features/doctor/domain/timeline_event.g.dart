// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) =>
    _TimelineEvent(
      ts: json['ts'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String?,
      visitId: json['visit_id'] as String?,
      refId: json['ref_id'] as String?,
    );

Map<String, dynamic> _$TimelineEventToJson(_TimelineEvent instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'kind': instance.kind,
      'title': instance.title,
      'detail': instance.detail,
      'visit_id': instance.visitId,
      'ref_id': instance.refId,
    };
