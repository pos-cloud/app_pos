/// Impuesto disponible (ej. IVA 21%, 10,5%). `classification` suele ser
/// "Impuesto" para los que se aplican a un artículo.
class Tax {
  final String id;
  final String code;
  final String name;
  final String taxBase;
  final double percentage;
  final String classification;
  final String type;

  Tax({
    required this.id,
    required this.code,
    required this.name,
    required this.taxBase,
    required this.percentage,
    required this.classification,
    required this.type,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      taxBase: json['taxBase']?.toString() ?? '',
      percentage:
          json['percentage'] is num ? (json['percentage'] as num).toDouble() : 0.0,
      classification: json['classification']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
