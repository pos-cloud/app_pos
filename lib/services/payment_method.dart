import 'dart:convert';
import 'package:app_pos/models/payment_method.dart';
import 'package:http/http.dart' as http;
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class PaymentMethodService {
  final AuthService _authService = AuthService();

  // Método para obtener los artículos
  Future<List<PaymentMethod>> getPaymentMethod() async {
    final token = await _authService.getToken();

    final project = jsonEncode({'name': 1, 'operationType': 1});
    final sort = jsonEncode({"name": 1});
    const limit = 100;

    // Construimos el filtro `match`
    final Map<String, dynamic> match = {
      "operationType": {"\$ne": "D"}
    };

    // Convertimos el filtro a JSON
    final matchJson = jsonEncode(match);

    final group = {
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    };

    final groupJson = jsonEncode(group);

    final url = Uri.parse('${Config.apiUrl}/payment-methods').replace(
      queryParameters: {
        'project': project,
        'match': matchJson,
        'sort': sort,
        'group': groupJson,
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

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final items = responseBody['result'][0]['items'];

      List<PaymentMethod> paymentMethod =
          items.map<PaymentMethod>((e) => PaymentMethod.fromJson(e)).toList();

      return paymentMethod;
    } else {
      throw Exception('Error al obtener metodos de pago');
    }
  }
}
