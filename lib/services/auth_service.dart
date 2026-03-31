import 'dart:convert';
import 'dart:io';
import 'package:app_pos/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'auth_user';

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

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _storage.write(key: _userKey, value: jsonEncode(userJson));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
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

  Future<({String? token, Map<String, dynamic>? user, String? errorMessage})>
      login(
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
      final result = responseBody is Map ? responseBody['result'] : null;
      final tokenData = (result is Map) ? result['token'] : null;
      String? token;
      if (tokenData is Map) {
        token = tokenData['token'] as String?;
      } else if (tokenData is String) {
        token = tokenData;
      }

      Map<String, dynamic>? user;
      if (result is Map) {
        final dynamic maybeUser = result['user'] ?? result['usuario'];
        if (maybeUser is Map) {
          user = Map<String, dynamic>.from(maybeUser);
        } else if (result.containsKey('_id') || result.containsKey('name')) {
          // A veces el "result" es el usuario directamente
          user = Map<String, dynamic>.from(result);
        }
      }

      return (token: token, user: user, errorMessage: null);
    } else {
      String? errorMessage;
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? 'Error al iniciar sesión';
      } catch (_) {
        errorMessage = 'Error al iniciar sesión';
      }
      return (token: null, user: null, errorMessage: errorMessage);
    }
  }
}
