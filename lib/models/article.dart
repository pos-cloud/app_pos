import 'make.dart';
import 'category.dart';

class Article {
  final String type;
  final int order;
  final bool containsVariants;
  final String code;
  final String description;
  final String posDescription;
  final String observation;
  final List<dynamic>
      notes; // Puedes crear un modelo específico si lo necesitas
  final List<dynamic>
      tags; // Similar a `notes`, se puede ajustar si tiene estructura definida
  final double basePrice;
  final double costPrice;
  final double markupPercentage;
  final double markupPrice;
  final double salePrice;
  final Make make;
  final Category category;
  final String barcode;
  final String wooId;
  final String meliId;
  final String printIn;
  final bool posKitchen;
  final bool allowPurchase;
  final bool allowSale;
  final bool allowStock;
  final bool allowSaleWithoutStock;
  final bool allowMeasure;
  final bool ecommerceEnabled;
  final bool favourite;
  final bool isWeigth;
  final bool forShipping;
  final String picture;

  Article({
    required this.type,
    required this.order,
    required this.containsVariants,
    required this.code,
    required this.description,
    required this.posDescription,
    required this.observation,
    required this.notes,
    required this.tags,
    required this.basePrice,
    required this.costPrice,
    required this.markupPercentage,
    required this.markupPrice,
    required this.salePrice,
    required this.make,
    required this.category,
    required this.barcode,
    required this.wooId,
    required this.meliId,
    required this.printIn,
    required this.posKitchen,
    required this.allowPurchase,
    required this.allowSale,
    required this.allowStock,
    required this.allowSaleWithoutStock,
    required this.allowMeasure,
    required this.ecommerceEnabled,
    required this.favourite,
    required this.isWeigth,
    required this.forShipping,
    required this.picture,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      type: json['type'] ?? '',
      order: json['order'] ?? 0,
      containsVariants: json['containsVariants'] ?? false,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      posDescription: json['posDescription'] ?? '',
      observation: json['observation'] ?? '',
      notes: json['notes'] ?? [],
      tags: json['tags'] ?? [],
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      markupPercentage: (json['markupPercentage'] ?? 0).toDouble(),
      markupPrice: (json['markupPrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      make: Make.fromJson(json['make'] ?? {}),
      category: Category.fromJson(json['category'] ?? {}),
      barcode: json['barcode'] ?? '',
      wooId: json['wooId'] ?? '',
      meliId: json['meliId'] ?? '',
      printIn: json['printIn'] ?? '',
      posKitchen: json['posKitchen'] ?? false,
      allowPurchase: json['allowPurchase'] ?? false,
      allowSale: json['allowSale'] ?? false,
      allowStock: json['allowStock'] ?? false,
      allowSaleWithoutStock: json['allowSaleWithoutStock'] ?? false,
      allowMeasure: json['allowMeasure'] ?? false,
      ecommerceEnabled: json['ecommerceEnabled'] ?? false,
      favourite: json['favourite'] ?? false,
      isWeigth: json['isWeigth'] ?? false,
      forShipping: json['forShipping'] ?? false,
      picture: json['picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'order': order,
      'containsVariants': containsVariants,
      'code': code,
      'description': description,
      'posDescription': posDescription,
      'observation': observation,
      'notes': notes,
      'tags': tags,
      'basePrice': basePrice,
      'costPrice': costPrice,
      'markupPercentage': markupPercentage,
      'markupPrice': markupPrice,
      'salePrice': salePrice,
      'make': make.toJson(),
      'category': category.toJson(),
      'barcode': barcode,
      'wooId': wooId,
      'meliId': meliId,
      'printIn': printIn,
      'posKitchen': posKitchen,
      'allowPurchase': allowPurchase,
      'allowSale': allowSale,
      'allowStock': allowStock,
      'allowSaleWithoutStock': allowSaleWithoutStock,
      'allowMeasure': allowMeasure,
      'ecommerceEnabled': ecommerceEnabled,
      'favourite': favourite,
      'isWeigth': isWeigth,
      'forShipping': forShipping,
      'picture': picture,
    };
  }
}
