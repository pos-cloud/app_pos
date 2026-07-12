import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/make.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class MakeService {
  final AuthService _authService = AuthService();

  Future<List<Make>> getMakes() async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'description': 1,
      'visibleSale': 1,
      'picture': 1,
    });
    final match = jsonEncode({
      'operationType': {'\$ne': 'D'},
    });
    final sort = jsonEncode({'description': 1});
    final group = jsonEncode({
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    });

    final url = Uri.parse('${Config.apiUrl}/makes').replace(
      queryParameters: {
        'project': project,
        'match': match,
        'sort': sort,
        'group': group,
        'limit': '10000',
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
      throw Exception('Error al obtener marcas');
    }

    final responseBody = jsonDecode(response.body);
    final result = responseBody is Map ? responseBody['result'] : null;
    if (result is! List || result.isEmpty) return [];

    final first = result.first;
    final items = first is Map ? first['items'] : null;
    if (items is! List) return [];

    return items
        .map<Make>((e) => Make.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.id.isNotEmpty)
        .toList();
  }
}
