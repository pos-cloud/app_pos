import 'dart:convert';
import 'package:app_pos/config.dart';
import 'package:app_pos/models/api_response.dart';
import 'package:app_pos/models/vat_condition.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class VatConditionService {
  final AuthService _authService = AuthService();

  Future<List<VatCondition>> getVatConditions() async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'code': 1,
      'description': 1,
    });
    final match = jsonEncode({
      'operationType': {'\$ne': 'D'},
    });
    final sort = jsonEncode({'description': 1});

    final url = Uri.parse('${Config.apiUrl}/vat-conditions').replace(
      queryParameters: {
        'project': project,
        'match': match,
        'sort': sort,
        'limit': '1000',
      },
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener condiciones de IVA');
    }

    final apiResponse = ApiResponse<List<VatCondition>>.fromJson(
      jsonDecode(response.body),
      (json) => (json as List)
          .map((e) => VatCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (apiResponse.status == 200) {
      return apiResponse.result;
    }

    throw Exception(apiResponse.message);
  }
}
