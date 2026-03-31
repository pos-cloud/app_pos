/// Tipo de empleado (dominio backend).
class EmployeeType {
  final String id;
  final String name;

  EmployeeType({required this.id, required this.name});

  factory EmployeeType.fromJson(Map<String, dynamic> json) {
    return EmployeeType(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
