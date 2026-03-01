class PriceList {
  final String? id;
  final String name;
  final double percentage;
  final bool isDefault;

  PriceList({
    this.id,
    required this.name,
    this.percentage = 0,
    this.isDefault = false,
  });

  factory PriceList.fromJson(Map<String, dynamic> json) {
    return PriceList(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      isDefault: json['default'] ?? false,
    );
  }
}
