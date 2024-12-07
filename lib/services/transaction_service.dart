import 'dart:convert';
import 'package:app_pos/config.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  final AuthService _authService = AuthService();

  Future<String> syncTransaction(Map<String, dynamic> transaction) async {
    final url = Uri.parse('${Config.apiUrl}/transactions/create');

    final token = await _authService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: json.encode(transaction),
    );

    if (response.statusCode != 200) {
      // Incluye el cuerpo de la respuesta en el mensaje de error
      final errorMessage =
          json.decode(response.body)['message'] ?? response.body;
      throw Exception(
          'Failed to sync transaction. Status code: ${response.statusCode}. Error: $errorMessage');
    }

    final responseData = json.decode(response.body);

    if (!responseData.containsKey('transactionId')) {
      throw Exception(
          'La respuesta no contiene un transactionId: $responseData');
    }

    // Devolvemos el ID
    return responseData['transactionId'] as String;
  }
}
