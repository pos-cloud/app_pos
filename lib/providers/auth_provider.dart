import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<bool> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(false);

  Future<({bool success, String? errorMessage})> login(
      String negocio, String usuario, String password) async {
    try {
      final result =
          await _authService.login(negocio, usuario, password);
      if (result.token != null) {
        await _authService.saveToken(result.token!);
        state = true;
        return (success: true, errorMessage: null);
      }
      state = false;
      return (success: false, errorMessage: result.errorMessage);
    } catch (e) {
      state = false;
      return (success: false, errorMessage: 'Error de conexión');
    }
  }

  Future<void> logout(WidgetRef ref) async {
    try {
      // Eliminar el token guardado
      await _authService.deleteToken();

      // Reiniciar cualquier estado relacionado
      _resetAppState(ref);

      // Cambiar el estado a no autenticado
      state = false;
    } catch (_) {}
  }

  void _resetAppState(WidgetRef ref) {
    ref.invalidate(globalTransactionProvider);
    ref.invalidate(articlesProvider);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(AuthService()),
);
