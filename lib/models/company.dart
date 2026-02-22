import 'package:app_pos/models/identification_type.dart';

class Company {
  final String? id;
  final String name;
  final String? fantasyName;
  final String type; // 'Cliente' o 'Proveedor'
  final IdentificationType? identificationType;
  final String? identificationValue;

  Company({
    this.id,
    required this.name,
    this.fantasyName,
    required this.type,
    this.identificationType,
    this.identificationValue,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      fantasyName: json['fantasyName'],
      type: json['type'] ?? 'Cliente',
      identificationType: json['identificationType'] != null
          ? (json['identificationType'] is Map
              ? IdentificationType.fromJson(json['identificationType'])
              : null)
          : null,
      identificationValue: json['identificationValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'fantasyName': fantasyName,
      'type': type,
      'identificationType': identificationType?.toJson(),
      'identificationValue': identificationValue,
    };
  }
}
