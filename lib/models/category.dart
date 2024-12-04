class Category {
  final String id;
  final int order;
  final String description;
  final String picture;
  final bool visibleInvoice;
  final bool visibleOnSale;
  final bool visibleOnPurchase;
  final bool favourite;
  final Category? parent; // Puede ser null para las categorías raíz
  final String observation;
  final String tiendaNubeId;
  final bool showMenu;

  Category({
    required this.id,
    required this.order,
    required this.description,
    required this.picture,
    required this.visibleInvoice,
    required this.visibleOnSale,
    required this.visibleOnPurchase,
    required this.favourite,
    this.parent,
    required this.observation,
    required this.tiendaNubeId,
    required this.showMenu,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      order: json['order'] ?? 0,
      description: json['description'] ?? '',
      picture: json['picture'] ?? '',
      visibleInvoice: json['visibleInvoice'] ?? false,
      visibleOnSale: json['visibleOnSale'] ?? false,
      visibleOnPurchase: json['visibleOnPurchase'] ?? false,
      favourite: json['favourite'] ?? false,
      parent: json['parent'] != null
          ? Category.fromJson(json['parent'])
          : null, // Recursión para anidar categorías
      observation: json['observation'] ?? '',
      tiendaNubeId: json['tiendaNubeId'] ?? '',
      showMenu: json['showMenu'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order': order,
      'description': description,
      'picture': picture,
      'visibleInvoice': visibleInvoice,
      'visibleOnSale': visibleOnSale,
      'visibleOnPurchase': visibleOnPurchase,
      'favourite': favourite,
      'parent': parent?.toJson(), // Conversión recursiva
      'observation': observation,
      'tiendaNubeId': tiendaNubeId,
      'showMenu': showMenu,
    };
  }
}
