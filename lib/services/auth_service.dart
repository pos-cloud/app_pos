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
}
