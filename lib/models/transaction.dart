import 'package:app_pos/models/transaction_type.dart';

class Transaction {
  final String id;
  final TransactionType type;

  Transaction({required this.id, required this.type});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      type: TransactionType.fromJson(json['type'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type.toJson(), // Conversión de TransactionType a JSON
    };
  }
}
