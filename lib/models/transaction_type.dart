/// StockMovement: Entrada, Salida, Inventario, Transferencia
class TransactionType {
  final String id;
  final String name;
  final String transactionMovement;
  final String? stockMovement; // 'Entrada', 'Salida', 'Inventario', 'Transferencia'
  final String? requestCompany;
  final bool requestPaymentMethods;
  final bool requestArticles;

  TransactionType({
    required this.id,
    required this.name,
    required this.transactionMovement,
    this.stockMovement,
    this.requestCompany,
    this.requestPaymentMethods = false,
    this.requestArticles = false,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      transactionMovement: json['transactionMovement'] ?? '',
      stockMovement: json['stockMovement']?.toString(),
      requestCompany: json['requestCompany']?.toString(),
      requestPaymentMethods: json['requestPaymentMethods'] ?? false,
      requestArticles: json['requestArticles'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'transactionMovement': transactionMovement,
      'stockMovement': stockMovement,
      'requestCompany': requestCompany,
      'requestPaymentMethods': requestPaymentMethods,
      'requestArticles': requestArticles,
    };
  }
}
