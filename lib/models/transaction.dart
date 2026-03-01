import 'package:app_pos/models/transaction_type.dart';
import 'package:app_pos/models/company.dart';
import 'package:app_pos/models/price_list.dart';

class Transaction {
  final TransactionType type;
  final String state;
  final double? totalPrice;
  final Company? company;
  final PriceList? priceList;

  Transaction({
    required this.type,
    required this.state,
    required this.totalPrice,
    this.company,
    this.priceList,
  });

  // Método de fábrica para convertir un Map en un objeto Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: TransactionType.fromJson(json['type'] ?? {}),
      state: json['state'] ?? "Cerrado",
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
      priceList:
          json['priceList'] != null
              ? PriceList.fromJson(json['priceList'] as Map<String, dynamic>)
              : null,
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
    PriceList? priceList,
    bool clearPriceList = false,
  }) {
    return Transaction(
      type: type ?? this.type,
      state: state ?? "Cerrado",
      totalPrice: totalPrice ?? this.totalPrice,
      company: company ?? this.company,
      priceList: clearPriceList ? null : (priceList ?? this.priceList),
    );
  }
}
