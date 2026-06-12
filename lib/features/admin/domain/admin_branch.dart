import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_branch.freezed.dart';
part 'admin_branch.g.dart';

/// Clinic branch (mirrors backend `BranchOut`). Note: `code` is immutable
/// after creation — `BranchUpdate` deliberately has no code field.
@freezed
abstract class AdminBranch with _$AdminBranch {
  const factory AdminBranch({
    required String id,
    required String name,
    required String code,
    String? address,
    String? phone,
    @Default(true) bool isActive,
  }) = _AdminBranch;

  factory AdminBranch.fromJson(Map<String, dynamic> json) =>
      _$AdminBranchFromJson(json);
}
