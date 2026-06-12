import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_summary.freezed.dart';
part 'visit_summary.g.dart';

/// Lightweight projection of a visit for pickers/lists (subset of `VisitOut`).
@freezed
abstract class VisitSummary with _$VisitSummary {
  const VisitSummary._();

  const factory VisitSummary({
    required String id,
    required String visitNo,
    required String status,
    required String openedAt,
  }) = _VisitSummary;

  factory VisitSummary.fromJson(Map<String, dynamic> json) => _$VisitSummaryFromJson(json);

  String get label => '$visitNo · ${openedAt.split('T').first}';
}
