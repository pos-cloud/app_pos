import 'dart:convert';
import 'package:app_pos/config.dart';
import 'package:app_pos/models/api_response.dart';
import 'package:app_pos/models/identification_type.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class IdentificationTypeService {
  final AuthService _authService = AuthService();

  Future<List<IdentificationType>> getIdentificationTypes() async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'code': 1,
      'name': 1,
    });
    final match = jsonEncode({
      'operationType': {'\$ne': 'D'},
    });
    final sort = jsonEncode({'name': 1});

    final url = Uri.parse('${Config.apiUrl}/identification-types').replace(
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
      throw Exception('Error al obtener tipos de identificación');
    }

    final apiResponse = ApiResponse<List<IdentificationType>>.fromJson(
      jsonDecode(response.body),
      (json) => (json as List)
          .map((e) => IdentificationType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (apiResponse.status == 200) {
      return apiResponse.result;
    }

    throw Exception(apiResponse.message);
  }
}
