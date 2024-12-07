class Category {
  final String? id;
  final int? order;
  final String? description;
  final String? picture;
  final bool? visibleInvoice;
  final bool? visibleOnSale;
  final bool? visibleOnPurchase;
  final bool? favourite;
  final String? observation;
  final bool? showMenu;

  Category({
    this.id,
    this.order,
    this.description,
    this.picture,
    this.visibleInvoice,
    this.visibleOnSale,
    this.visibleOnPurchase,
    this.favourite,
    this.observation,
    this.showMenu,
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
      observation: json['observation'] ?? '',
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
      'observation': observation,
      'showMenu': showMenu,
    };
  }
}
