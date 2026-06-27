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

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0.0);

  factory ArticleTax.fromJson(Map<String, dynamic> json) {
    final dynamic taxRef = json['tax'];
    String? taxId;
    String taxName = '';
    if (taxRef is Map) {
      taxId = (taxRef['_id'] ?? taxRef['\$oid'] ?? taxRef['oid'])?.toString();
      taxName = taxRef['name']?.toString() ?? '';
    } else if (taxRef != null) {
      taxId = taxRef.toString();
    }
    return ArticleTax(
      taxId: taxId,
      taxName: taxName,
      percentage: _toDouble(json['percentage']),
      taxBase: _toDouble(json['taxBase']),
      taxAmount: _toDouble(json['taxAmount']),
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
    final id = (value is Map ? value['_id'] ?? value['\$oid'] ?? value['oid'] : value)?.toString();
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
    final id = (value is Map ? value['_id'] ?? value['\$oid'] ?? value['oid'] : value)?.toString();
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
    return Article(
      id: json['_id']?.toString(),
      code: json['code']?.toString(),
      barcode: json['barcode']?.toString(),
      salePrice: json['salePrice']?.toDouble() ?? 0.0,
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
    double? salePrice,
    String? description,
    String? posDescription,
    String? picture,
    String? type,
    Make? make,
    Category? category,
    double? m3,
    List<ArticleTax>? taxes,
  }) {
    return Article(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      salePrice: salePrice ?? this.salePrice,
      description: description ?? this.description,
      posDescription: posDescription ?? this.posDescription,
      picture: picture ?? this.picture,
      type: type ?? this.type,
      make: make ?? this.make,
      category: category ?? this.category,
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

  /// Payload para `PUT /article?id=<id>` (clave `article`). El backend valida
  /// que `code`, `type`, `description`, `salePrice` y `category` estén presentes.
  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{
      if (_hasValidId(id)) '_id': id,
      'code': code ?? '',
      'type': type.isNotEmpty ? type : 'Final',
      'description': description,
      'posDescription': posDescription,
      'salePrice': salePrice,
    };
    if (barcode != null && barcode!.isNotEmpty) {
      map['barcode'] = barcode;
    }
    if (category?.id != null && category!.id!.isNotEmpty) {
      map['category'] = category!.id;
    }
    if (make?.id != null && make!.id.isNotEmpty) {
      map['make'] = make!.id;
    }
    if (m3 != null) {
      map['m3'] = m3;
    }
    map['taxes'] = taxes.map((t) => t.toJson()).toList();
    return map;
  }

  static bool _hasValidId(String? v) => v != null && v.isNotEmpty;
}
