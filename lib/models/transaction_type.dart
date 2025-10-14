class TransactionType {
  final String id;
  final String name;
  final String transactionMovement;
  final String? requestCompany; // null, 'Cliente', 'Proveedor'

  TransactionType({
    required this.id,
    required this.name,
    required this.transactionMovement,
    this.requestCompany,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      transactionMovement: json['transactionMovement'] ?? '',
      requestCompany: json['requestCompany'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'transactionMovement': transactionMovement,
      'requestCompany': requestCompany,
    };
  }
}
