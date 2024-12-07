import 'dart:convert';
import 'package:app_pos/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/api_response.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  Future<List<Category>> getCategories() async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      'order': 1,
      'description': 1,
      'picture': 1,
    });
    final match = jsonEncode({});
    final sort = jsonEncode({});
    final group = jsonEncode({});
    const limit = 1000;

    final url = Uri.parse('${Config.apiUrl}/categories').replace(
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
      final apiResponse = ApiResponse<List<Category>>.fromJson(
        jsonDecode(response.body),
        (json) => (json as List).map((e) => Category.fromJson(e)).toList(),
      );

      if (apiResponse.status == 200) {
        return apiResponse.result;
      } else {
        throw Exception('Error: ${apiResponse.message}');
      }
    } else {
      throw Exception('Error al obtener artículos');
    }
  }
}
