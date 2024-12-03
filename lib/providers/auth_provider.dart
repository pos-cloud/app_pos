import 'package:app_pos/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/api_service.dart';

class AuthNotifier extends StateNotifier<bool> {
  final ApiService _apiService;
  final AuthService _authService;

  AuthNotifier(this._apiService, this._authService) : super(false);

  // Intentar el login
  Future<bool> login(String negocio, String usuario, String password) async {
    try {
      final token = await _apiService.login(negocio, usuario, password);
      if (token != null) {
        // Guardar el token usando AuthService
        await _authService.saveToken(token);

        state = true; // Usuario autenticado
        return true;
      }
    } catch (e) {
      print('Error al hacer login: $e');
    }
    state = false; // Usuario no autenticado
    return false;
  }
}

// Provider de AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(
    ApiService(),
    AuthService(), // Aseguramos que se pase el servicio de almacenamiento
  ),
);
