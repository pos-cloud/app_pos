import 'dart:convert';
import 'package:app_pos/config.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class EmailService {
  final AuthService _authService = AuthService();

  Future<void> sendTransactionEmail({
    required String transactionId,
    required String to,
    String subject = 'Comprobante de venta',
    String body = '',
  }) async {
    final url = Uri.parse('${Config.apiUrl}/send-email');
    final token = await _authService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'transactionId': transactionId,
        'to': to,
        'subject': subject,
        'body': body,
      }),
    );

    if (response.statusCode != 200) {
      final errorMessage =
          json.decode(response.body)['message'] ?? response.body;
      throw Exception(
          'Error al enviar el correo: ${response.statusCode}. $errorMessage');
    }
  }
}
