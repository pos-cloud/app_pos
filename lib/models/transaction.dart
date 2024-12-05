import 'package:app_pos/models/transaction_type.dart';

class Transaction {
  final TransactionType type;
  final double? totalPrice;

  Transaction({
    required this.type,
    required this.totalPrice,
  });

  // Método de fábrica para convertir un Map en un objeto Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: TransactionType.fromJson(json['type'] ?? {}),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  // Convierte el objeto Transaction en un Map
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'totalPrice': totalPrice,
    };
  }

  Transaction copyWith({
    TransactionType? type,
    double? totalPrice,
  }) {
    return Transaction(
      type: type ?? this.type,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
