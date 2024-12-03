class TransactionType {
  final String id;
  final String name;
  final String transactionMovement;

  TransactionType({
    required this.id,
    required this.name,
    required this.transactionMovement,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      transactionMovement: json['transactionMovement'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'transactionMovement': transactionMovement,
    };
  }
}
