import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/api_response.dart';
import 'package:app_pos/models/transaction_type.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class TransactionTypeService {
  final AuthService _authService = AuthService();

  // Método para obtener los tipos de transacciones
  Future<List<TransactionType>> getTransactionTypes() async {
    final token =
        await _authService.getToken(); // Obtenemos el token desde AuthService

    final project =
        jsonEncode({'name': 1, 'transactionMovement': 1, 'operationType': 1});
    final match = jsonEncode({
      'operationType': {'\$ne': 'D'}
    });
    final sort = jsonEncode({'name': -1});
    final group = jsonEncode({});
    const limit = 100;

    final url = Uri.parse('${Config.apiUrl}/transaction-types').replace(
      queryParameters: {
        'project': Uri.encodeQueryComponent(project),
        'match': Uri.encodeQueryComponent(match),
        'sort': Uri.encodeQueryComponent(sort),
        'group': Uri.encodeQueryComponent(group),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<List<TransactionType>>.fromJson(
        jsonDecode(response.body),
        (json) =>
            (json as List).map((e) => TransactionType.fromJson(e)).toList(),
      );

      if (apiResponse.status == 200) {
        return apiResponse.result;
      } else {
        throw Exception('Error: ${apiResponse.message}');
      }
    } else {
      throw Exception('Error al obtener tipos de transacciones');
    }
  }
}
