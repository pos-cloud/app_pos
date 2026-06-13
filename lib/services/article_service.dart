import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/article.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class ArticleService {
  final AuthService _authService = AuthService();

  /// [makeIds]: si viene no vacío, solo artículos cuya `make` esté en esa lista
  /// (usuario con `makes` hidratadas en login).
  Future<List<Article>> getArticles({List<String>? makeIds}) async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'code': 1,
      'barcode': 1,
      'description': 1,
      'posDescription': 1,
      'salePrice': 1,
      'picture': 1,
      'operationType': 1,
      'type': 1,
      'make': 1,
      'category': 1,
      'm3': 1,
    });
    final sort = jsonEncode({"name": 1});
    const limit = 1000000;

    final matchMap = <String, dynamic>{
      "operationType": {"\$ne": "D"},
      "type": {"\$eq": "Final"},
    };
    if (makeIds != null && makeIds.isNotEmpty) {
      final makeOidList = makeIds
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .map((id) => <String, dynamic>{r'$oid': id})
          .toList();
      matchMap["make"] = {"\$in": makeOidList};
    }
    final match = jsonEncode(matchMap);

    final group = {
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    };

    final groupJson = jsonEncode(group);

    final url = Uri.parse('${Config.apiUrl}/articles').replace(
      queryParameters: {
        'project': project,
        'match': match,
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
