import 'package:app_pos/models/transaction_type.dart';

class Transaction {
  final String id;
  final TransactionType type;
  final double? totalPrice;

  Transaction({
    required this.id,
    required this.type,
    required this.totalPrice,
  });

  // Método de fábrica para convertir un Map en un objeto Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      type: TransactionType.fromJson(json['type'] ?? {}),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  // Convierte el objeto Transaction en un Map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type.toJson(),
      'totalPrice': totalPrice,
    };
  }
}
