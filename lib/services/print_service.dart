import 'dart:convert';
import 'dart:typed_data';

import 'package:app_pos/config.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class PrintService {
  final AuthService _authService = AuthService();

  Future<Uint8List> downloadTransactionPdf(String transactionId) async {
    final url = Uri.parse('${Config.apiUrl}/to-print/transaction');
    final token = await _authService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'transactionId': transactionId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al generar el PDF');
    }

    return response.bodyBytes;
  }
}
