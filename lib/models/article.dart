import 'package:app_pos/models/category.dart';
import 'package:app_pos/models/make.dart';

/// Impuesto aplicado a un artículo (entrada del array `taxes`).
class ArticleTax {
  final String? taxId;
  final String taxName;
  final double percentage;
  final double taxBase;
  final double taxAmount;

  ArticleTax({
    this.taxId,
    this.taxName = '',
    this.percentage = 0,
    this.taxBase = 0,
    this.taxAmount = 0,
  });

  static double toDouble(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0.0);

  factory ArticleTax.fromJson(Map<String, dynamic> json) {
    final dynamic taxRef = json['tax'];
    String? taxId;
    String taxName = '';
    if (taxRef is Map) {
      taxId = (taxRef['_id'] ?? taxRef[r'$oid'] ?? taxRef['oid'])?.toString();
      taxName = taxRef['name']?.toString() ?? '';
    } else if (taxRef != null) {
      taxId = taxRef.toString();
    }
    return ArticleTax(
      taxId: taxId,
      taxName: taxName,
      percentage: toDouble(json['percentage']),
      taxBase: toDouble(json['taxBase']),
      taxAmount: toDouble(json['taxAmount']),
    );
  }

  ArticleTax copyWith({
    String? taxId,
    String? taxName,
    double? percentage,
    double? taxBase,
    double? taxAmount,
  }) {
    return ArticleTax(
      taxId: taxId ?? this.taxId,
      taxName: taxName ?? this.taxName,
      percentage: percentage ?? this.percentage,
      taxBase: taxBase ?? this.taxBase,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (taxId != null && taxId!.isNotEmpty) 'tax': taxId,
      'percentage': percentage,
      'taxBase': taxBase,
      'taxAmount': taxAmount,
    };
  }
}

class Article {
  final String? id;
  final String? code;
  final String? barcode;
  final double basePrice;
  final double costPrice;
  final double markupPercentage;
  final double markupPrice;
  final double salePrice;
  final String description;
  final String posDescription;
  final String picture;
  final String type;
  final Make? make;
  final Category? category;
  final double? m3;
  final List<ArticleTax> taxes;

  Article({
    this.id,
    this.code,
    this.barcode,
    this.basePrice = 0,
    this.costPrice = 0,
    this.markupPercentage = 0,
    this.markupPrice = 0,
    required this.salePrice,
    required this.description,
    required this.posDescription,
    required this.picture,
    this.type = 'Final',
    this.make,
    this.category,
    this.m3,
    this.taxes = const [],
  });

  static Make? _parseMakeOrCategoryRef(dynamic value) {
    if (value == null) return null;
    final id = (value is Map
            ? value['_id'] ?? value[r'$oid'] ?? value['oid']
            : value)
        ?.toString();
    if (id == null || id.isEmpty) return null;
    return Make(
      id: id,
      description: value is Map ? (value['description'] ?? '') : '',
      visibleSale: value is Map ? (value['visibleSale'] ?? false) : false,
      picture: value is Map ? (value['picture'] ?? '') : '',
    );
  }

  static Category? _parseCategoryRef(dynamic value) {
    if (value == null) return null;
    final id = (value is Map
            ? value['_id'] ?? value[r'$oid'] ?? value['oid']
            : value)
        ?.toString();
    if (id == null || id.isEmpty) return null;
    return Category(
      id: id,
      description: value is Map ? (value['description'] ?? '') : '',
    );
  }

  static List<ArticleTax> _parseTaxes(dynamic value) {
    if (value is! List) return const [];
    final out = <ArticleTax>[];
    for (final e in value) {
      if (e is Map) {
        out.add(ArticleTax.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'];
    final id = rawId is Map
        ? (rawId[r'$oid'] ?? rawId['oid'] ?? rawId['_id'])?.toString()
        : rawId?.toString();

    return Article(
      id: id,
      code: json['code']?.toString(),
      barcode: json['barcode']?.toString(),
      basePrice: ArticleTax.toDouble(json['basePrice']),
      costPrice: ArticleTax.toDouble(json['costPrice']),
      markupPercentage: ArticleTax.toDouble(json['markupPercentage']),
      markupPrice: ArticleTax.toDouble(json['markupPrice']),
      salePrice: ArticleTax.toDouble(json['salePrice']),
      description: json['description'] ?? '',
      posDescription: json['posDescription'] ?? '',
      picture: json['picture'] ?? '',
      type: json['type']?.toString() ?? 'Final',
      make: _parseMakeOrCategoryRef(json['make']),
      category: _parseCategoryRef(json['category']),
      m3: json['m3'] is num ? (json['m3'] as num).toDouble() : null,
      taxes: _parseTaxes(json['taxes']),
    );
  }

  Article copyWith({
    String? id,
    String? code,
    String? barcode,
    double? basePrice,
    double? costPrice,
    double? markupPercentage,
    double? markupPrice,
    double? salePrice,
    String? description,
    String? posDescription,
    String? picture,
    String? type,
    Make? make,
    Category? category,
    double? m3,
    List<ArticleTax>? taxes,
    bool clearMake = false,
    bool clearCategory = false,
  }) {
    return Article(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      basePrice: basePrice ?? this.basePrice,
      costPrice: costPrice ?? this.costPrice,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      markupPrice: markupPrice ?? this.markupPrice,
      salePrice: salePrice ?? this.salePrice,
      description: description ?? this.description,
      posDescription: posDescription ?? this.posDescription,
      picture: picture ?? this.picture,
      type: type ?? this.type,
      make: clearMake ? null : (make ?? this.make),
      category: clearCategory ? null : (category ?? this.category),
      m3: m3 ?? this.m3,
      taxes: taxes ?? this.taxes,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'salePrice': salePrice,
      'description': description,
      'posDescription': posDescription,
      'picture': picture,
    };
    if (_hasValidId(id)) {
      map['_id'] = id;
    }
    return map;
  }

  /// Payload para `PUT /articles/:id` (api-v2). El body es el artículo directo.
  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{
      if (_hasValidId(id)) '_id': id,
      'code': code ?? '',
      'type': type.isNotEmpty ? type : 'Final',
      'description': description,
      'posDescription': posDescription,
      'basePrice': basePrice,
      'costPrice': costPrice,
      'markupPercentage': markupPercentage,
      'markupPrice': markupPrice,
      'salePrice': salePrice,
      'taxes': taxes.map((t) => t.toJson()).toList(),
    };
    if (barcode != null && barcode!.isNotEmpty) {
      map['barcode'] = barcode;
    } else {
      map['barcode'] = '';
    }
    if (category?.id != null && category!.id!.isNotEmpty) {
      map['category'] = category!.id;
    }
    if (make?.id != null && make!.id.isNotEmpty) {
      map['make'] = make!.id;
    } else {
      map['make'] = null;
    }
    if (m3 != null) {
      map['m3'] = m3;
    }
    return map;
  }

  static bool _hasValidId(String? v) => v != null && v.isNotEmpty;

  static double _round2(double value) => (value * 100).round() / 100;

  /// Precio de venta sin impuestos, extraído del precio final.
  /// Misma lógica que app-web: internos (alícuota 0) se restan primero y el IVA
  /// se descuenta con `salePrice / (percentage/100 + 1)`.
  double get unitPriceWithoutTaxes {
    if (taxes.isEmpty) return _round2(salePrice);

    var impInt = 0.0;
    var percentSum = 0.0;
    for (final tax in taxes) {
      if (tax.percentage == 0) {
        impInt += tax.taxAmount;
      } else {
        percentSum += tax.percentage;
      }
    }

    if (percentSum == 0) return _round2(salePrice - impInt);
    return _round2((salePrice - impInt) / (percentSum / 100 + 1));
  }

  /// Precio unitario a mostrar/cargar según si el tipo pide impuestos.
  double unitPriceFor({required bool requestTaxes}) {
    return requestTaxes ? salePrice : unitPriceWithoutTaxes;
  }
}
