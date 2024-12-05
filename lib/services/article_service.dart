import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/api_response.dart';
import 'package:app_pos/models/article.dart'; // Asegúrate de que el modelo 'Article' esté importado
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class ArticleService {
  final AuthService _authService = AuthService();

  // Método para obtener los artículos
  Future<List<Article>> getArticles() async {
    final token =
        await _authService.getToken(); // Obtenemos el token desde AuthService

    print(token);
    final project = jsonEncode({
      'code': 1,
      'description': 1,
      'posDescription': 1,
      'salePrice': 1,
      'picture': 1
    }); // Ejemplo de campos que queremos recuperar
    final match = jsonEncode({});
    final sort = jsonEncode(
        {}); // Ordenar por nombre (puedes modificar esto según necesites)
    final group = jsonEncode({});
    const limit = 100;

    final url = Uri.parse('${Config.apiUrl}/articles').replace(
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

    print(response);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<List<Article>>.fromJson(
        jsonDecode(response.body),
        (json) => (json as List).map((e) => Article.fromJson(e)).toList(),
      );

      print(apiResponse.result);
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
