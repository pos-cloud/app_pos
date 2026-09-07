import 'package:app_pos/models/company.dart';

/// StockMovement: Entrada, Salida, Inventario, Transferencia
class TransactionType {
  final String id;
  final String name;
  final String transactionMovement;
  final String? stockMovement; // 'Entrada', 'Salida', 'Inventario', 'Transferencia'
  final String? requestCompany;
  /// Cliente/proveedor predeterminado del tipo de transacción.
  final Company? company;
  final bool requestPaymentMethods;
  final bool requestArticles;
  final bool requestTaxes;
  final bool? allowPriceList;
  /// Si el tipo admite el descuento configurado en el cliente/grupo.
  final bool allowCompanyDiscount;
  final String? finishState;

  TransactionType({
    required this.id,
    required this.name,
    required this.transactionMovement,
    this.stockMovement,
    this.requestCompany,
    this.company,
    this.requestPaymentMethods = false,
    this.requestArticles = false,
    this.requestTaxes = true,
    this.allowPriceList,
    this.allowCompanyDiscount = true,
    this.finishState,
  });

  /// Estado inicial al crear: `finishState` del tipo o `Cerrado` por defecto.
  String get initialState {
    final finish = finishState?.trim();
    if (finish != null && finish.isNotEmpty) return finish;
    return 'Cerrado';
  }

  bool get requestsCompany {
    final value = requestCompany?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get hasDefaultCompany {
    final id = company?.id?.trim();
    return id != null && id.isNotEmpty;
  }

  /// El tipo pide cliente y no trae uno predeterminado: hay que seleccionarlo.
  bool get requiresCompanySelection => requestsCompany && !hasDefaultCompany;

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      transactionMovement: json['transactionMovement'] ?? '',
      stockMovement: json['stockMovement']?.toString(),
      requestCompany: json['requestCompany']?.toString(),
      company: _parseCompany(json['company']),
      requestPaymentMethods: json['requestPaymentMethods'] ?? false,
      requestArticles: json['requestArticles'] ?? false,
      requestTaxes: json['requestTaxes'] ?? true,
      allowPriceList: json['allowPriceList'] is bool ? json['allowPriceList'] as bool : null,
      allowCompanyDiscount: json['allowCompanyDiscount'] is bool
          ? json['allowCompanyDiscount'] as bool
          : true,
      finishState: json['finishState']?.toString(),
    );
  }

  static Company? _parseCompany(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final id = value.trim();
      if (id.isEmpty) return null;
      return Company(id: id, name: '', type: Company.clientType);
    }
    if (value is Map) {
      if (value.containsKey(r'$oid')) {
        final id = value[r'$oid']?.toString().trim();
        if (id == null || id.isEmpty) return null;
        return Company(id: id, name: '', type: Company.clientType);
      }
      final map = Map<String, dynamic>.from(value);
      final id = map['_id'] ?? map['id'];
      if (id == null || id.toString().trim().isEmpty) return null;
      return Company.fromJson(map);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'transactionMovement': transactionMovement,
      'stockMovement': stockMovement,
      'requestCompany': requestCompany,
      'company': company?.toJson(),
      'requestPaymentMethods': requestPaymentMethods,
      'requestArticles': requestArticles,
      'requestTaxes': requestTaxes,
      'allowPriceList': allowPriceList ?? false,
      'allowCompanyDiscount': allowCompanyDiscount,
      'finishState': finishState,
    };
  }
}
