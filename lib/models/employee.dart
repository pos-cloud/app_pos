import 'package:app_pos/models/employee_type.dart';

class Employee {
  final String id;
  final String name;
  final String phone;

  /// API puede enviar `adress` (typo del backend) o `address`.
  final String address;
  final EmployeeType type;

  Employee({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.type,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'];
    final EmployeeType type;
    if (typeRaw is Map) {
      type = EmployeeType.fromJson(Map<String, dynamic>.from(typeRaw));
    } else if (typeRaw is String && typeRaw.trim().isNotEmpty) {
      type = EmployeeType(id: typeRaw.trim(), name: '');
    } else {
      type = EmployeeType(id: '', name: '');
    }

    return Employee(
      id: json['_id']?.toString() ?? json[r'$oid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: (json['address'] ?? json['adress'])?.toString() ?? '',
      type: type,
    );
  }
}
