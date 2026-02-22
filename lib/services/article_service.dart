import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/article.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class ArticleService {
  final AuthService _authService = AuthService();

  // Método para obtener los artículos
  Future<List<Article>> getArticles({String? searchQuery}) async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'code': 1,
      'description': 1,
      'posDescription': 1,
      'salePrice': 1,
      'picture': 1,
      'operationType': 1,
      'type': 1,
      'make': 1,
      'category': 1,
    });
    final sort = jsonEncode({"name": 1});
    const limit = 100;

    // Construimos el filtro `match`
    final Map<String, dynamic> match = {
      "operationType": {"\$ne": "D"},
      "type": {"\$eq": "Final"}
    };

    // Si hay una búsqueda, la agregamos al filtro
    if (searchQuery != null && searchQuery.isNotEmpty) {
      match["description"] = {
        "\$regex": searchQuery,
        "\$options": "i" // Insensible a mayúsculas y minúsculas
      };
    }

    // Convertimos el filtro a JSON
    final matchJson = jsonEncode(match);

    final group = {
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    };

    final groupJson = jsonEncode(group);

    final url = Uri.parse('${Config.apiUrl}/articles').replace(
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

      List<Article> articles =
          items.map<Article>((e) => Article.fromJson(e)).toList();

      return articles;
    } else {
      throw Exception('Error al obtener artículos');
    }
  }
}
