import 'package:app_pos/models/transaction_type.dart';
import 'package:app_pos/models/company.dart';

class Transaction {
  final TransactionType type;
  final String state;
  final double? totalPrice;
  final Company? company;

  Transaction({
    required this.type,
    required this.state,
    required this.totalPrice,
    this.company,
  });

  // Método de fábrica para convertir un Map en un objeto Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: TransactionType.fromJson(json['type'] ?? {}),
      state: json['state'] ?? "Cerrado",
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }

  // Convierte el objeto Transaction en un Map
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'totalPrice': totalPrice,
      'company': company?.toJson(),
    };
  }

  Transaction copyWith({
    TransactionType? type,
    double? totalPrice,
    String? state,
    Company? company,
  }) {
    return Transaction(
      type: type ?? this.type,
      state: state ?? "Cerrado",
      totalPrice: totalPrice ?? this.totalPrice,
      company: company ?? this.company,
    );
  }
}
