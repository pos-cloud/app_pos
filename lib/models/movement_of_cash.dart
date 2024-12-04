import 'package:app_pos/models/payment_method.dart';

class MovementOfCash {
  final String id;
  final String date;
  final int quota;
  final String expirationDate;
  final double discount;
  final double surcharge;
  final double commissionAmount;
  final double administrativeExpenseAmount;
  final double otherExpenseAmount;
  final double capital;
  final double interestPercentage;
  final double interestAmount;
  final double taxPercentage;
  final double taxAmount;
  final double amountPaid;
  final double amountDiscount;
  final String observation;
  final PaymentMethod type;

  MovementOfCash({
    required this.id,
    required this.date,
    required this.quota,
    required this.expirationDate,
    required this.discount,
    required this.surcharge,
    required this.commissionAmount,
    required this.administrativeExpenseAmount,
    required this.otherExpenseAmount,
    required this.capital,
    required this.interestPercentage,
    required this.interestAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.amountPaid,
    required this.amountDiscount,
    required this.observation,
    required this.type,
  });

  factory MovementOfCash.fromJson(Map<String, dynamic> json) {
    return MovementOfCash(
      id: json['_id'] ?? '',
      date: json['date'] ?? '', // Si no está presente, asigna una cadena vacía
      quota: json['quota'] ?? 1,
      expirationDate: json['expirationDate'] ??
          '', // Si no está presente, asigna una cadena vacía
      discount: (json['discount'] ?? 0.0).toDouble(),
      surcharge: (json['surcharge'] ?? 0.0).toDouble(),
      commissionAmount: (json['commissionAmount'] ?? 0.0).toDouble(),
      administrativeExpenseAmount:
          (json['administrativeExpenseAmount'] ?? 0.0).toDouble(),
      otherExpenseAmount: (json['otherExpenseAmount'] ?? 0.0).toDouble(),
      capital: (json['capital'] ?? 0.0).toDouble(),
      interestPercentage: (json['interestPercentage'] ?? 0.0).toDouble(),
      interestAmount: (json['interestAmount'] ?? 0.0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0.0).toDouble(),
      amountDiscount: (json['amountDiscount'] ?? 0.0).toDouble(),
      observation: json['observation'] ?? '',
      type: PaymentMethod.fromJson(json['type'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date,
      'quota': quota,
      'expirationDate': expirationDate,
      'discount': discount,
      'surcharge': surcharge,
      'commissionAmount': commissionAmount,
      'administrativeExpenseAmount': administrativeExpenseAmount,
      'otherExpenseAmount': otherExpenseAmount,
      'capital': capital,
      'interestPercentage': interestPercentage,
      'interestAmount': interestAmount,
      'taxPercentage': taxPercentage,
      'taxAmount': taxAmount,
      'amountPaid': amountPaid,
      'amountDiscount': amountDiscount,
      'observation': observation,
      'type': type.toJson(),
    };
  }
}
