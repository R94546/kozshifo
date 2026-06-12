import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

/// One entry of the automatic patient timeline (mirrors backend `TimelineEvent`).
@freezed
abstract class TimelineEvent with _$TimelineEvent {
  const TimelineEvent._();

  const factory TimelineEvent({
    required String ts,
    required String kind,
    required String title,
    String? detail,
    String? visitId,
    String? refId,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);

  String get dateLabel => ts.split('T').first;
}
