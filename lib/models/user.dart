class User {
  final String id;
  final String name;
  final String state;
  final String token;
  final Map<String, dynamic> permissions;

  User({
    required this.id,
    required this.name,
    required this.state,
    required this.token,
    required this.permissions,
  });

  // Método para crear un usuario desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      state: json['state'],
      token: json['token'],
      permissions: json['permission'] ?? {},
    );
  }
}
