import 'package:app_pos/models/identification_type.dart';

class Company {
  static const String clientType = 'Cliente';

  final String? id;
  final String name;
  final String? fantasyName;
  final String type;
  final IdentificationType? identificationType;
  final String? identificationValue;
  final String? employee;
  final String? vatCondition;
  final String? phones;
  final String? emails;
  final String? address;
  final String? city;
  final bool allowCurrentAccount;
  final double? creditLimit;

  Company({
    this.id,
    required this.name,
    this.fantasyName,
    required this.type,
    this.identificationType,
    this.identificationValue,
    this.employee,
    this.vatCondition,
    this.phones,
    this.emails,
    this.address,
    this.city,
    this.allowCurrentAccount = false,
    this.creditLimit,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      fantasyName: json['fantasyName'],
      type: json['type'] ?? 'Cliente',
      identificationType: _parseIdentificationType(json['identificationType']),
      identificationValue: json['identificationValue'],
      employee: json['employee']?.toString(),
      vatCondition: _parseRefId(json['vatCondition']),
      phones: json['phones'],
      emails: json['emails'],
      address: json['address'],
      city: json['city'],
      allowCurrentAccount: json['allowCurrentAccount'] ?? false,
      creditLimit: json['creditLimit'] != null
          ? (json['creditLimit'] as num).toDouble()
          : null,
    );
  }

  static String? _parseRefId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['_id']?.toString();
    return null;
  }

  static IdentificationType? _parseIdentificationType(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return IdentificationType(id: value, code: '1', name: '');
    }
    if (value is Map) {
      return IdentificationType.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  Company copyWith({
    String? id,
    String? name,
    String? fantasyName,
    String? type,
    IdentificationType? identificationType,
    String? identificationValue,
    String? employee,
    String? vatCondition,
    String? phones,
    String? emails,
    String? address,
    String? city,
    bool? allowCurrentAccount,
    double? creditLimit,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      fantasyName: fantasyName ?? this.fantasyName,
      type: type ?? this.type,
      identificationType: identificationType ?? this.identificationType,
      identificationValue: identificationValue ?? this.identificationValue,
      employee: employee ?? this.employee,
      vatCondition: vatCondition ?? this.vatCondition,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      address: address ?? this.address,
      city: city ?? this.city,
      allowCurrentAccount: allowCurrentAccount ?? this.allowCurrentAccount,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'fantasyName': fantasyName,
      'type': clientType,
      'identificationType': identificationType?.toJson(),
      'identificationValue': identificationValue,
      'employee': employee,
      'vatCondition': vatCondition,
      'phones': phones,
      'emails': emails,
      'address': address,
      'city': city,
      'allowCurrentAccount': allowCurrentAccount,
      'creditLimit': creditLimit,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      '_id': id,
      'name': name,
      'type': clientType,
      'vatCondition': vatCondition,
      'identificationType': identificationType?.id,
      'allowCurrentAccount': allowCurrentAccount,
      if (fantasyName != null && fantasyName!.isNotEmpty)
        'fantasyName': fantasyName,
      if (identificationValue != null && identificationValue!.isNotEmpty)
        'identificationValue': identificationValue,
      if (phones != null && phones!.isNotEmpty) 'phones': phones,
      if (emails != null && emails!.isNotEmpty) 'emails': emails,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (employee != null && employee!.isNotEmpty) 'employee': employee,
      if (creditLimit != null) 'creditLimit': creditLimit,
    };
  }
}
