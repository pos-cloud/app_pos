import 'package:app_pos/models/employee.dart';
import 'package:app_pos/models/make.dart';
import 'package:app_pos/models/permission.dart';

/// Usuario devuelto en login (`result.user`).
class User {
  final String id;
  final String name;
  final String? email;
  final String state;
  final String token;
  final Permission? permission;
  final Employee? employee;
  final List<Make> makes;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.state,
    required this.token,
    this.permission,
    this.employee,
    this.makes = const [],
  });

  /// Nombre del rol/permiso para UI (ej. menú lateral).
  String get permissionName => permission?.name.trim() ?? '';

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic permissionRaw = json['permission'] ?? json['permissions'];
    Permission? permission;
    if (permissionRaw is Map && permissionRaw.isNotEmpty) {
      permission = Permission.fromJson(
        Map<String, dynamic>.from(permissionRaw),
      );
    }

    Employee? employee;
    final rawEmployee = json['employee'];
    if (rawEmployee is Map) {
      employee = Employee.fromJson(Map<String, dynamic>.from(rawEmployee));
    }

    final dynamic makesRaw = json['makes'];
    final List<Make> makes = [];
    if (makesRaw is List) {
      for (final e in makesRaw) {
        final parsed = _parseMakeFromUserMakesEntry(e);
        if (parsed != null) {
          makes.add(parsed);
        }
      }
    }

    return User(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      state: json['state']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      permission: permission,
      employee: employee,
      makes: makes,
    );
  }
}

/// Login puede mandar `makes` como array de strings (ids) o como documentos Make.
Make? _parseMakeFromUserMakesEntry(dynamic e) {
  if (e == null) return null;
  if (e is String) {
    final id = e.trim();
    if (id.isEmpty) return null;
    return Make(
      id: id,
      description: '',
      visibleSale: false,
      picture: '',
    );
  }
  if (e is Map) {
    final m = Map<String, dynamic>.from(e);
    final oid = m[r'$oid'] ?? m['oid'];
    if (oid != null) {
      final id = oid.toString().trim();
      if (id.isEmpty) return null;
      return Make(
        id: id,
        description: m['description']?.toString() ?? '',
        visibleSale: m['visibleSale'] == true,
        picture: m['picture']?.toString() ?? '',
      );
    }
    return Make.fromJson(m);
  }
  return null;
}
