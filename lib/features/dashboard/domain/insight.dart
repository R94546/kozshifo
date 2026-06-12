import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';
part 'insight.g.dart';

/// One «что требует внимания» finding of the self-improvement engine
/// (mirrors backend `InsightOut`). Empty insights list = good morning.
@freezed
abstract class Insight with _$Insight {
  const Insight._();

  const factory Insight({
    required String code,
    required String severity, // info | warning | critical
    required String title,
    required String detail,
    String? value,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) => _$InsightFromJson(json);

  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';
}
