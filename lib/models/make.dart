class Make {
  final String id;
  final String description;
  final bool visibleSale;
  final String picture;

  Make({
    required this.id,
    required this.description,
    required this.visibleSale,
    required this.picture,
  });

  factory Make.fromJson(Map<String, dynamic> json) {
    return Make(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      visibleSale: json['visibleSale'] ?? false,
      picture: json['picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'visibleSale': visibleSale,
      'picture': picture,
    };
  }
}
