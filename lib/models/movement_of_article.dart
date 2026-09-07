import 'make.dart';
import 'category.dart';
import 'article.dart';

class MovementOfArticle {
  final String? id;
  final String? code;
  final String? description;
  final String? observation;
  final double? basePrice;
  final double? costPrice;
  final double? unitPrice;
  final double? markupPercentage;
  final double? markupPriceWithoutVAT;
  final double? markupPrice;
  final double? discountRate;
  final double? discountAmount;
  final double? transactionDiscountAmount;
  /// Total de la línea: [unitPrice] × [amount] (no es el precio de una unidad).
  final double? salePrice;
  final double? roundingAmount;
  final int? quotation;
  final Make? make;
  final Category? category;
  final String? barcode;
  final double? amount;
  final double? quantityForStock;
  final String? notes;
  final int? printed;
  final int? read;
  final Article article;

  MovementOfArticle({
    this.id,
    this.code,
    this.description,
    this.observation,
    this.basePrice,
    this.costPrice,
    this.unitPrice,
    this.markupPercentage,
    this.markupPriceWithoutVAT,
    this.markupPrice,
    this.discountRate,
    this.discountAmount,
    this.transactionDiscountAmount,
    this.salePrice,
    this.roundingAmount,
    this.quotation,
    this.make,
    this.category,
    this.barcode,
    this.amount,
    this.quantityForStock,
    this.notes,
    this.printed,
    this.read,
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
      'make': make?.toJson(),
      'category': category?.toJson(),
      'barcode': barcode,
      'amount': amount,
      'quantityForStock': quantityForStock,
      'notes': notes,
      'printed': printed,
      'read': read,
      'article': article.toJson(),
    };
  }

  /// Metros cúbicos de la línea: solo si el artículo tiene [Article.m3].
  double get lineM3 {
    final m3 = article.m3;
    if (m3 == null || m3 <= 0) return 0;
    return m3 * effectiveAmount;
  }

  /// Precio por **una** unidad (no confundir con [salePrice], que es el total de línea).
  double get effectiveUnitPrice => unitPrice ?? article.salePrice;

  double get effectiveAmount => amount ?? 1;

  /// Importe total de la línea: precio unitario × cantidad ([salePrice] debe reflejar eso).
  double get lineTotal => effectiveUnitPrice * effectiveAmount;

  /// Descuento de transacción (cliente) por unidad.
  double get effectiveTransactionDiscount => transactionDiscountAmount ?? 0;

  /// Precio unitario ya descontado el % del cliente.
  double get discountedUnitPrice =>
      effectiveUnitPrice - effectiveTransactionDiscount;

  /// Total de línea neto (después del descuento del cliente).
  double get discountedLineTotal =>
      discountedUnitPrice * effectiveAmount;

  MovementOfArticle copyWith({
    String? id,
    String? code,
    String? description,
    String? observation,
    double? basePrice,
    double? costPrice,
    double? unitPrice,
    double? markupPercentage,
    double? markupPriceWithoutVAT,
    double? markupPrice,
    double? discountRate,
    double? discountAmount,
    double? transactionDiscountAmount,
    double? salePrice,
    double? roundingAmount,
    int? quotation,
    Make? make,
    Category? category,
    String? barcode,
    double? amount,
    double? quantityForStock,
    String? notes,
    int? printed,
    int? read,
    Article? article,
  }) {
    return MovementOfArticle(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      observation: observation ?? this.observation,
      basePrice: basePrice ?? this.basePrice,
      costPrice: costPrice ?? this.costPrice,
      unitPrice: unitPrice ?? this.unitPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      markupPriceWithoutVAT:
          markupPriceWithoutVAT ?? this.markupPriceWithoutVAT,
      markupPrice: markupPrice ?? this.markupPrice,
      discountRate: discountRate ?? this.discountRate,
      discountAmount: discountAmount ?? this.discountAmount,
      transactionDiscountAmount:
          transactionDiscountAmount ?? this.transactionDiscountAmount,
      salePrice: salePrice ?? this.salePrice,
      roundingAmount: roundingAmount ?? this.roundingAmount,
      quotation: quotation ?? this.quotation,
      make: make ?? this.make,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      amount: amount ?? this.amount,
      quantityForStock: quantityForStock ?? this.quantityForStock,
      notes: notes ?? this.notes,
      printed: printed ?? this.printed,
      read: read ?? this.read,
      article: article ?? this.article,
    );
  }
}
