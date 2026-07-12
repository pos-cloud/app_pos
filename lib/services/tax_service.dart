import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/tax.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class TaxService {
  final AuthService _authService = AuthService();

  /// Impuestos disponibles (mismo criterio que app-web: no eliminados).
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
    });
    final sort = jsonEncode({'name': 1});
    final group = jsonEncode({
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    });

    final url = Uri.parse('${Config.apiUrl}/taxes').replace(
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
      throw Exception('Error al obtener impuestos');
    }

    final responseBody = jsonDecode(response.body);
    final taxes = _parseTaxes(responseBody);

    // Preferimos clasificación "Impuesto" (IVA, etc.); si no hay, devolvemos todos.
    final impuestos =
        taxes.where((t) => t.classification == 'Impuesto').toList();
    return impuestos.isNotEmpty ? impuestos : taxes;
  }

  List<Tax> _parseTaxes(dynamic responseBody) {
    if (responseBody is! Map) return [];

    // api-v2 Responser: { status, result: [ { items: [...] } ] } o { result: [...] }
    final result = responseBody['result'];
    if (result is List && result.isNotEmpty) {
      final first = result.first;
      if (first is Map && first['items'] is List) {
        return (first['items'] as List)
            .whereType<Map>()
            .map((e) => Tax.fromJson(Map<String, dynamic>.from(e)))
            .where((t) => t.id.isNotEmpty)
            .toList();
      }
      return result
          .whereType<Map>()
          .map((e) => Tax.fromJson(Map<String, dynamic>.from(e)))
          .where((t) => t.id.isNotEmpty)
          .toList();
    }

    // Legacy: { taxes: [...] }
    final rawTaxes = responseBody['taxes'];
    if (rawTaxes is List) {
      return rawTaxes
          .whereType<Map>()
          .map((e) => Tax.fromJson(Map<String, dynamic>.from(e)))
          .where((t) => t.id.isNotEmpty)
          .toList();
    }

    return [];
  }
}
