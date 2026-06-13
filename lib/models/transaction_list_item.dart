class TransactionListItem {
  final String? id;
  final int? origin;
  final String? letter;
  final int? number;
  final int? orderNumber;
  final String state;
  final double totalPrice;
  final double balance;
  final DateTime? startDate;
  final String? companyName;
  final String? employeeClosingName;
  final String? deliveryCity;
  final String? deliveryAddress;
  final String? shipmentMethodName;
  final String? typeName;

  TransactionListItem({
    this.id,
    this.origin,
    this.letter,
    this.number,
    this.orderNumber,
    required this.state,
    required this.totalPrice,
    required this.balance,
    this.startDate,
    this.companyName,
    this.employeeClosingName,
    this.deliveryCity,
    this.deliveryAddress,
    this.shipmentMethodName,
    this.typeName,
  });

  factory TransactionListItem.fromJson(Map<String, dynamic> json) {
    return TransactionListItem(
      id: json['_id']?.toString(),
      origin: json['origin'] is num ? (json['origin'] as num).toInt() : null,
      letter: json['letter']?.toString(),
      number: json['number'] is num ? (json['number'] as num).toInt() : null,
      orderNumber:
          json['orderNumber'] is num ? (json['orderNumber'] as num).toInt() : null,
      state: json['state']?.toString() ?? '',
      totalPrice: json['totalPrice'] is num
          ? (json['totalPrice'] as num).toDouble()
          : 0,
      balance:
          json['balance'] is num ? (json['balance'] as num).toDouble() : 0,
      startDate: _parseDate(json['startDate']),
      companyName: _readNestedName(json['company'], 'name'),
      employeeClosingName:
          _readNestedName(json['employeeClosing'], 'name'),
      deliveryCity: _readNestedName(json['deliveryAddress'], 'city'),
      deliveryAddress: _formatDeliveryAddress(json['deliveryAddress']),
      shipmentMethodName:
          _readNestedName(json['shipmentMethod'], 'name'),
      typeName: _readTypeName(json),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is Map) {
      final raw = value[r'$date'] ?? value['date'];
      if (raw != null) return DateTime.tryParse(raw.toString());
    }
    return null;
  }

  static String? _readTypeName(Map<String, dynamic> json) {
    final fromType = _readNestedName(json['type'], 'name');
    if (fromType != null) return fromType;

    final flat = json['type.name']?.toString().trim();
    if (flat != null && flat.isNotEmpty) return flat;

    return null;
  }

  static String? _readNestedName(dynamic value, String key) {
    if (value is Map) {
      final nested = value[key];
      if (nested != null && nested.toString().isNotEmpty) {
        return nested.toString();
      }
    }
    return null;
  }

  static String? _formatDeliveryAddress(dynamic value) {
    if (value is! Map) return null;
    final name = value['name']?.toString().trim() ?? '';
    final number = value['number']?.toString().trim() ?? '';
    final parts = <String>[];
    if (name.isNotEmpty) parts.add(name);
    if (number.isNotEmpty) parts.add(number);
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  String get displayNumber {
    if (orderNumber != null && orderNumber! > 0) {
      return orderNumber.toString();
    }
    if (number != null && number! > 0) {
      return number.toString();
    }
    return id ?? '';
  }

  /// Identificador de la transacción: `0001-B-00000001` o nro. de pedido.
  String get displayIdentifier {
    if (number != null && number! > 0) {
      final originPart = (origin ?? 0).toString().padLeft(4, '0');
      final numberPart = number.toString().padLeft(8, '0');
      final letterPart = letter?.trim() ?? '';
      if (letterPart.isNotEmpty) {
        return '$originPart-$letterPart-$numberPart';
      }
      return '$originPart-$numberPart';
    }
    if (orderNumber != null && orderNumber! > 0) {
      return orderNumber.toString();
    }
    return displayNumber;
  }

  /// Título del listado: `{tipo} #{número}`.
  String get displayTitle {
    final label = typeName?.trim();
    final number = displayNumber;
    if (label != null && label.isNotEmpty) {
      return number.isNotEmpty ? '$label #$number' : label;
    }
    return number.isNotEmpty ? '#$number' : displayIdentifier;
  }
}
