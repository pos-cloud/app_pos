import 'package:app_pos/models/identification_type.dart';

class CompanyGroup {
  final String? id;
  final String description;
  final double discount;

  CompanyGroup({
    this.id,
    this.description = '',
    this.discount = 0,
  });

  factory CompanyGroup.fromJson(Map<String, dynamic> json) {
    return CompanyGroup(
      id: json['_id']?.toString(),
      description: json['description']?.toString() ?? '',
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'discount': discount,
    };
  }
}

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
  final double discount;
  final CompanyGroup? group;

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
    this.discount = 0,
    this.group,
  });

  /// Descuento propio del cliente (porcentaje).
  double get companyDiscount => discount > 0 ? discount : 0;

  /// Descuento del grupo al que pertenece el cliente.
  double get groupDiscount =>
      (group?.discount ?? 0) > 0 ? group!.discount : 0;

  /// Suma de descuento cliente + grupo, igual que en app-web.
  double get totalDiscount => companyDiscount + groupDiscount;

  bool get hasDiscount => totalDiscount > 0;

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
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : 0,
      group: _parseGroup(json['group']),
    );
  }

  static String? _parseRefId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['_id']?.toString();
    return null;
  }

  static CompanyGroup? _parseGroup(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final id = value.trim();
      if (id.isEmpty) return null;
      return CompanyGroup(id: id);
    }
    if (value is Map) {
      return CompanyGroup.fromJson(Map<String, dynamic>.from(value));
    }
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
    double? discount,
    CompanyGroup? group,
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
      discount: discount ?? this.discount,
      group: group ?? this.group,
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
      'discount': discount,
      'group': group?.toJson(),
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
