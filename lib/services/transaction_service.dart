import 'dart:convert';
import 'package:app_pos/config.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  final AuthService _authService = AuthService();

  // Método para sincronizar la transacción
  Future<void> syncTransaction(Map<String, dynamic> transaction) async {
    // Define la URL de la API donde se enviarán los datos
    final url = Uri.parse('${Config.apiUrl}/transactions/create');

    // Obtén el token de autenticación (suponiendo que getToken ya gestiona este proceso)
    final token = await _authService.getToken();

    // Realiza la solicitud POST a la API con los datos y el token
    final response = await http.post(
      url,
      headers: {
        'Authorization': '$token', // Asegúrate de que sea 'Bearer $token'
        'Content-Type': 'application/json',
      },
      body: json
          .encode(transaction), // Enviar los datos de la transacción como JSON
    );

    // Verifica si la solicitud fue exitosa
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to sync transaction. Status code: ${response.statusCode}');
    }
  }
}
