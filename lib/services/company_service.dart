import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_pos/models/company.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:app_pos/config.dart';

class CompanyService {
  final AuthService _authService = AuthService();

  /// Si [employeeId] viene, filtra por `company.employee` (`$oid` en la query).
  Future<List<Company>> getCompanies({String? employeeId}) async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'name': 1,
      'fantasyName': 1,
      'type': 1,
      'operationType': 1,
      'identificationType.name': 1,
      'identificationValue': 1,
      'phones': 1,
      'emails': 1,
      'address': 1,
      'city': 1,
      'vatCondition': 1,
      'allowCurrentAccount': 1,
      'creditLimit': 1,
      'employee': 1,
    });
    final sort = jsonEncode({"name": 1});
    const limit = 1000000;

    final matchMap = <String, dynamic>{
      "operationType": {"\$ne": "D"},
      "type": "Cliente",
    };
    final id = employeeId?.trim();
    if (id != null && id.isNotEmpty) {
      matchMap['employee'] = <String, dynamic>{r'$oid': id};
    }
    final match = jsonEncode(matchMap);

    final group = {
      '_id': null,
      'count': {'\$sum': 1},
      'items': {'\$push': '\$\$ROOT'},
    };

    final groupJson = jsonEncode(group);

    final url = Uri.parse('${Config.apiUrl}/companies').replace(
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

      List<Company> companies =
          items.map<Company>((e) => Company.fromJson(e)).toList();

      return companies;
    } else {
      throw Exception('Error al obtener clientes');
    }
  }
}
