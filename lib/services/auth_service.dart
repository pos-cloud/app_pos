import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String apiUrl = 'https://d-api-v1.poscloud.ar/api/login';

  // Guardar el token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Leer el token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Eliminar el token (cuando el usuario cierre sesión)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Guardar el nombre del negocio
  Future<void> saveBusiness(String business) async {
    await _storage.write(key: 'business_name', value: business);
  }

  // Leer el nombre del negocio
  Future<String?> getBusiness() async {
    return await _storage.read(key: 'business_name');
  }

  // Eliminar el nombre del negocio (si es necesario)
  Future<void> deleteBusiness() async {
    await _storage.delete(key: 'business_name');
  }

  Future<String?> login(
      String database, String username, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "database": database,
        "user": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['user']['token'];
      return token;
    } else {
      return null;
    }
  }
}
