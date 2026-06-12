/// Minimal view of a backend `RoleOut` for the admin screen: the role name
/// (used for assignment via `role_names`) plus how many permissions it grants.
/// Role/permission *editing* is out of scope here — display & assignment only,
/// so no Freezed/codegen is needed.
class AdminRole {
  const AdminRole({
    required this.name,
    required this.permissionCount,
    this.description,
  });

  final String name;
  final int permissionCount;
  final String? description;

  factory AdminRole.fromJson(Map<String, dynamic> json) => AdminRole(
        name: json['name'] as String,
        permissionCount: (json['permissions'] as List<dynamic>? ?? const []).length,
        description: json['description'] as String?,
      );
}
