import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/tax.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class TaxService {
  final AuthService _authService = AuthService();

  /// Impuestos aplicables a un artículo (clasificación "Impuesto", ej. IVA).
  Future<List<Tax>> getTaxes() async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'code': 1,
      'name': 1,
      'percentage': 1,
      'taxBase': 1,
      'classification': 1,
      'type': 1,
    });
    final match = jsonEncode({
      'operationType': {'\$ne': 'D'},
      'classification': 'Impuesto',
    });
    final sort = jsonEncode({'percentage': 1});

    final url = Uri.parse('${Config.apiUrl}/v2/taxes').replace(
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
      throw Exception('Error al obtener impuestos');
    }

    final responseBody = jsonDecode(response.body);
    final rawTaxes = responseBody is Map ? responseBody['taxes'] : null;
    if (rawTaxes is! List) return [];

    return rawTaxes
        .map<Tax>((e) => Tax.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
