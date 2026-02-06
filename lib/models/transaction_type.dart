class TransactionType {
  final String id;
  final String name;
  final String transactionMovement;
  final String? requestCompany; // null, 'Cliente', 'Proveedor'
  final bool requestPaymentMethods;
  final bool requestArticles;

  TransactionType({
    required this.id,
    required this.name,
    required this.transactionMovement,
    this.requestCompany,
    this.requestPaymentMethods = false,
    this.requestArticles = false,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      transactionMovement: json['transactionMovement'] ?? '',
      requestCompany: json['requestCompany'],
      requestPaymentMethods: json['requestPaymentMethods'] ?? false,
      requestArticles: json['requestArticles'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'transactionMovement': transactionMovement,
      'requestCompany': requestCompany,
      'requestPaymentMethods': requestPaymentMethods,
      'requestArticles': requestArticles,
    };
  }
}
