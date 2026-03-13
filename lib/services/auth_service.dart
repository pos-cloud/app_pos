import 'dart:convert';
import 'dart:io';
import 'package:app_pos/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

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

  Future<({String? token, String? errorMessage})> login(
      String database, String username, String password) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/auth/login')
          .replace(queryParameters: {'database': database}),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": username,
        "password": password,
        "platform": Platform.isAndroid ? "android" : "ios",
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final tokenData = responseBody['result']['token'];
      String? token;
      if (tokenData is Map) {
        token = tokenData['token'] as String?;
      } else if (tokenData is String) {
        token = tokenData;
      }
      return (token: token, errorMessage: null);
    } else {
      String? errorMessage;
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? 'Error al iniciar sesión';
      } catch (_) {
        errorMessage = 'Error al iniciar sesión';
      }
      return (token: null, errorMessage: errorMessage);
    }
  }
}
