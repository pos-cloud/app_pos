class Article {
  final double salePrice;
  final String description;
  final String posDescription;
  final String picture;

  Article({
    required this.salePrice,
    required this.description,
    required this.posDescription,
    required this.picture,
  });

  // Método fromJson para extraer solo los campos necesarios
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      salePrice: json['salePrice']?.toDouble() ?? 0.0, // Precio de venta
      description: json['description'] ?? '', // Descripción
      posDescription: json['posDescription'] ?? '', // Descripción
      picture: json['picture'] ?? '', // Imagen del producto
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salePrice': salePrice,
      'description': description,
      'posDescription': posDescription,
      'picture': picture,
    };
  }
}
