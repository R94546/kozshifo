// Admin (Owner Control Center) models: snake_case parsing; the backend sends
// user roles as [{id, name}, …] RoleRef objects — we keep only the names.
import 'package:flutter_test/flutter_test.dart';
import 'package:kozshifo/features/admin/domain/admin_branch.dart';
import 'package:kozshifo/features/admin/domain/admin_role.dart';
import 'package:kozshifo/features/admin/domain/staff_user.dart';

void main() {
  const userJson = <String, dynamic>{
    'id': 'u-1',
    'email': 'doctor@kozshifo.uz',
    'full_name': 'Иванова Дилноза',
    'phone': '+998901234567',
    'is_active': true,
    'is_superuser': false,
    'branch_id': 'br-1',
    'roles': [
      {'id': 'r-1', 'name': 'doctor'},
      {'id': 'r-2', 'name': 'diagnost'},
    ],
  };

  test('StaffUser parses snake_case; role refs collapse to names', () {
    final u = StaffUser.fromJson(userJson);
    expect(u.fullName, 'Иванова Дилноза');
    expect(u.email, 'doctor@kozshifo.uz');
    expect(u.phone, '+998901234567');
    expect(u.branchId, 'br-1');
    expect(u.isActive, isTrue);
    expect(u.isSuperuser, isFalse);
    expect(u.roles, ['doctor', 'diagnost']);
  });

  test('StaffUser round-trips through its own toJson (roles as strings)', () {
    final u = StaffUser.fromJson(userJson);
    expect(StaffUser.fromJson(u.toJson()), u);
  });

  test('StaffUser defaults: is_active=true, is_superuser=false, roles=[]', () {
    final u = StaffUser.fromJson(const {
      'id': 'u-2',
      'email': 'new@kozshifo.uz',
      'full_name': 'Новый Сотрудник',
    });
    expect(u.isActive, isTrue);
    expect(u.isSuperuser, isFalse);
    expect(u.roles, isEmpty);
    expect(u.branchId, isNull);
    expect(u.phone, isNull);
  });

  const branchJson = <String, dynamic>{
    'id': 'br-1',
    'name': 'Главный филиал',
    'code': 'MAIN',
    'address': 'г. Ташкент, ул. Шифокорлар 1',
    'phone': '+998712001020',
    'is_active': true,
  };

  test('AdminBranch round-trips snake_case JSON', () {
    final b = AdminBranch.fromJson(branchJson);
    expect(b.name, 'Главный филиал');
    expect(b.code, 'MAIN');
    expect(b.address, 'г. Ташкент, ул. Шифокорлар 1');
    expect(b.phone, '+998712001020');
    expect(b.isActive, isTrue);
    expect(AdminBranch.fromJson(b.toJson()), b);
  });

  test('AdminBranch optional fields and is_active default', () {
    final b = AdminBranch.fromJson(const {
      'id': 'br-2',
      'name': 'Филиал Самарканд',
      'code': 'SAM',
    });
    expect(b.address, isNull);
    expect(b.phone, isNull);
    expect(b.isActive, isTrue);
  });

  test('AdminRole parses minimally: name + permission count', () {
    final r = AdminRole.fromJson(const {
      'id': 'r-1',
      'name': 'doctor',
      'description': 'Врач-офтальмолог',
      'is_system': true,
      'permissions': [
        {'id': 'p-1', 'code': 'patients.read', 'module': 'patients', 'description': null},
        {'id': 'p-2', 'code': 'exams.update', 'module': 'exams', 'description': null},
      ],
    });
    expect(r.name, 'doctor');
    expect(r.permissionCount, 2);
    expect(r.description, 'Врач-офтальмолог');
  });
}
