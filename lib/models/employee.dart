import 'package:app_pos/models/employee_type.dart';

/// Empleado asociado al usuario (login).
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
    return Employee(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: (json['address'] ?? json['adress'])?.toString() ?? '',
      type: typeRaw is Map<String, dynamic>
          ? EmployeeType.fromJson(typeRaw)
          : EmployeeType(id: '', name: ''),
    );
  }
}
