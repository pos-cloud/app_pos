import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/price_list.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class PriceListService {
  final AuthService _authService = AuthService();

  Future<List<PriceList>> getPriceLists() async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'name': 1,
      'percentage': 1,
      'default': 1,
    });
    final sort = jsonEncode({"name": 1});
    const limit = 1000;

    final match = jsonEncode({"operationType": {"\$ne": "D"}});

    final group = {
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    };
    final groupJson = jsonEncode(group);

    final url = Uri.parse('${Config.apiUrl}/price-lists').replace(
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
      return items
          .map<PriceList>((e) => PriceList.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener listas de precios');
    }
  }
}
