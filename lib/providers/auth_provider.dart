import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<bool> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(false);

  Future<bool> login(String negocio, String usuario, String password) async {
    try {
      final token = await _authService.login(negocio, usuario, password);
      if (token != null) {
        await _authService.saveToken(token);

        state = true;
        return true;
      }
    } catch (e) {
      print('Error al hacer login: $e');
    }
    state = false;
    return false;
  }

  Future<void> logout(WidgetRef ref) async {
    try {
      // Eliminar el token guardado
      await _authService.deleteToken();

      // Reiniciar cualquier estado relacionado
      _resetAppState(ref);

      // Cambiar el estado a no autenticado
      state = false;
    } catch (e) {
      print('Error al hacer logout: $e');
    }
  }

  void _resetAppState(WidgetRef ref) {
    ref.invalidate(globalTransactionProvider);
    ref.invalidate(articlesProvider);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(AuthService()),
);
