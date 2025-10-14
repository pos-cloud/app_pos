class IdentificationType {
  final String? id;
  final String code;
  final String name;

  IdentificationType({
    this.id,
    required this.code,
    required this.name,
  });

  factory IdentificationType.fromJson(Map<String, dynamic> json) {
    return IdentificationType(
      id: json['_id'],
      code: json['code'] ?? '1',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'name': name,
    };
  }
}
