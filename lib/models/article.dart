import 'package:app_pos/models/category.dart';
import 'package:app_pos/models/make.dart';

class Article {
  final String? id;
  final String? code;
  final String? barcode;
  final double salePrice;
  final String description;
  final String posDescription;
  final String picture;
  final Make? make;
  final Category? category;

  Article({
    this.id,
    this.code,
    this.barcode,
    required this.salePrice,
    required this.description,
    required this.posDescription,
    required this.picture,
    this.make,
    this.category,
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

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id']?.toString(),
      code: json['code']?.toString(),
      barcode: json['barcode']?.toString(),
      salePrice: json['salePrice']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      posDescription: json['posDescription'] ?? '',
      picture: json['picture'] ?? '',
      make: _parseMakeOrCategoryRef(json['make']),
      category: _parseCategoryRef(json['category']),
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

  static bool _hasValidId(String? v) => v != null && v.isNotEmpty;
}
