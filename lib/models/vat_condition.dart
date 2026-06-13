class VatCondition {
  final String? id;
  final int code;
  final String description;

  VatCondition({
    this.id,
    required this.code,
    required this.description,
  });

  factory VatCondition.fromJson(Map<String, dynamic> json) {
    return VatCondition(
      id: json['_id']?.toString(),
      code: json['code'] is num ? (json['code'] as num).toInt() : 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'description': description,
    };
  }
}
