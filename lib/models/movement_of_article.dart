import 'make.dart';
import 'category.dart';
import 'article.dart';

class MovementOfArticle {
  final String id;
  final String code;
  final String description;
  final String observation;
  final double basePrice;
  final double costPrice;
  final double unitPrice;
  final double markupPercentage;
  final double markupPriceWithoutVAT;
  final double markupPrice;
  final double discountRate;
  final double discountAmount;
  final double transactionDiscountAmount;
  final double salePrice;
  final double roundingAmount;
  final int quotation;
  final Make make;
  final Category category;
  final String barcode;
  final double amount;
  final double quantityForStock;
  final String notes;
  final int printed;
  final int read;
  final Article article;

  MovementOfArticle({
    required this.id,
    required this.code,
    required this.description,
    required this.observation,
    required this.basePrice,
    required this.costPrice,
    required this.unitPrice,
    required this.markupPercentage,
    required this.markupPriceWithoutVAT,
    required this.markupPrice,
    required this.discountRate,
    required this.discountAmount,
    required this.transactionDiscountAmount,
    required this.salePrice,
    required this.roundingAmount,
    required this.quotation,
    required this.make,
    required this.category,
    required this.barcode,
    required this.amount,
    required this.quantityForStock,
    required this.notes,
    required this.printed,
    required this.read,
    required this.article,
  });

  factory MovementOfArticle.fromJson(Map<String, dynamic> json) {
    return MovementOfArticle(
      id: json['_id'] ?? '',
      code: json['code'] ?? '1',
      description: json['description'] ?? '',
      observation: json['observation'] ?? '',
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      costPrice: (json['costPrice'] ?? 0.0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      markupPercentage: (json['markupPercentage'] ?? 0.0).toDouble(),
      markupPriceWithoutVAT: (json['markupPriceWithoutVAT'] ?? 0.0).toDouble(),
      markupPrice: (json['markupPrice'] ?? 0.0).toDouble(),
      discountRate: (json['discountRate'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      transactionDiscountAmount:
          (json['transactionDiscountAmount'] ?? 0.0).toDouble(),
      salePrice: (json['salePrice'] ?? 0.0).toDouble(),
      roundingAmount: (json['roundingAmount'] ?? 0.0).toDouble(),
      quotation: json['quotation'] ?? 1,
      make: Make.fromJson(json['make'] ?? {}),
      category: Category.fromJson(json['category'] ?? {}),
      barcode: json['barcode'] ?? '',
      amount: (json['amount'] ?? 1).toDouble(),
      quantityForStock: (json['quantityForStock'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      printed: json['printed'] ?? 0,
      read: json['read'] ?? 0,
      article: Article.fromJson(json['article'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'description': description,
      'observation': observation,
      'basePrice': basePrice,
      'costPrice': costPrice,
      'unitPrice': unitPrice,
      'markupPercentage': markupPercentage,
      'markupPriceWithoutVAT': markupPriceWithoutVAT,
      'markupPrice': markupPrice,
      'discountRate': discountRate,
      'discountAmount': discountAmount,
      'transactionDiscountAmount': transactionDiscountAmount,
      'salePrice': salePrice,
      'roundingAmount': roundingAmount,
      'quotation': quotation,
      'make': make.toJson(),
      'category': category.toJson(),
      'barcode': barcode,
      'amount': amount,
      'quantityForStock': quantityForStock,
      'notes': notes,
      'printed': printed,
      'read': read,
      'article': article.toJson(),
    };
  }
}
