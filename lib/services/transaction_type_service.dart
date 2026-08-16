import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/api_response.dart';
import 'package:app_pos/models/transaction_type.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class TransactionTypeService {
  final AuthService _authService = AuthService();

  /// [transactionTypeIds]: si viene no vacío, solo tipos cuyo `_id` esté en la lista
  /// (`permission.transactionTypes` en login), con `\$oid` para Mongo.
  Future<List<TransactionType>> getTransactionTypes({
    List<String>? transactionTypeIds,
  }) async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'name': 1,
      'transactionMovement': 1,
      'stockMovement': 1,
      'operationType': 1,
      'requestCompany': 1,
      'company': 1,
      'requestPaymentMethods': 1,
      'requestArticles': 1,
      'requestTaxes': 1,
      'allowPriceList': 1,
      'finishState': 1,
    });
    final matchMap = <String, dynamic>{
      'operationType': {'\$ne': 'D'},
    };
    if (transactionTypeIds != null && transactionTypeIds.isNotEmpty) {
      final oidList = transactionTypeIds
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .map((id) => <String, dynamic>{r'$oid': id})
          .toList();
      matchMap['_id'] = {'\$in': oidList};
    }
    final match = jsonEncode(matchMap);
    final sort = jsonEncode({'name': -1});
    final group = jsonEncode({});
    const limit = 100;

    final url = Uri.parse('${Config.apiUrl}/transaction-types').replace(
      queryParameters: {
        'project': project,
        'match': match,
        'sort': sort,
        'group': group,
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
      final apiResponse = ApiResponse<List<TransactionType>>.fromJson(
        jsonDecode(response.body),
        (json) =>
            (json as List).map((e) => TransactionType.fromJson(e)).toList(),
      );

      if (apiResponse.status == 200) {
        return apiResponse.result;
      } else {
        throw Exception('Error: ${apiResponse.message}');
      }
    } else {
      throw Exception('Error al obtener tipos de transacciones');
    }
  }
}
