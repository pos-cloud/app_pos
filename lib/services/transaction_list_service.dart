import 'dart:convert';
import 'package:app_pos/config.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/models/transaction_list_item.dart';
import 'package:app_pos/services/auth_service.dart';
import 'package:http/http.dart' as http;

class TransactionListService {
  final AuthService _authService = AuthService();

  static const _transactionRefKeys = [
    'type',
    'company',
    'employeeOpening',
    'employeeClosing',
    'cashBox',
    'deliveryAddress',
    'shipmentMethod',
    'transport',
    'priceList',
    'account',
    'branchOrigin',
    'branchDestination',
    'table',
    'currency',
    'depositOrigin',
    'depositDestination',
    'creationUser',
    'updateUser',
  ];

  /// Reglas de filtrado:
  /// - Si se pasa [employeeId] (permiso `filterTransaction` activo y empleado
  ///   asignado), se traen solo las transacciones cerradas por ese empleado.
  /// - Si no, se traen todas las del estado pedido limitadas a los tipos de
  ///   transacción que el usuario puede operar ([transactionTypeIds]). Si la
  ///   lista viene vacía, no se filtra por tipo (trae todas).
  Future<List<TransactionListItem>> getSalesTransactions({
    String? employeeId,
    List<String>? transactionTypeIds,
    required String state,
  }) async {
    final token = await _authService.getToken();

    final project = jsonEncode({
      '_id': 1,
      'startDate': 1,
      'origin': 1,
      'letter': 1,
      'number': 1,
      'orderNumber': 1,
      'state': 1,
      'totalPrice': 1,
      'balance': 1,
      'type._id': 1,
      'type.name': 1,
      'company.name': 1,
      'employeeClosing._id': 1,
      'employeeClosing.name': 1,
      'deliveryAddress.name': 1,
      'deliveryAddress.number': 1,
      'deliveryAddress.city': 1,
      'shipmentMethod.name': 1,
    });

    final matchMap = <String, dynamic>{
      'operationType': {'\$ne': 'D'},
      'state': state,
    };

    final employee = employeeId?.trim() ?? '';
    if (employee.isNotEmpty) {
      matchMap['employeeClosing._id'] = {'\$oid': employee};
    } else {
      final typeIds = (transactionTypeIds ?? [])
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList();
      if (typeIds.isNotEmpty) {
        matchMap['type._id'] = {
          '\$in': typeIds.map((id) => {'\$oid': id}).toList(),
        };
      }
    }

    final sort = jsonEncode({'startDate': -1});
    final match = jsonEncode(matchMap);

    final url = Uri.parse('${Config.apiUrl}/transactions').replace(
      queryParameters: {
        'project': project,
        'match': match,
        'sort': sort,
        'limit': '500',
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
      throw Exception('Error al obtener ventas');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseBody['status'] != 200) {
      throw Exception(
        responseBody['message']?.toString() ?? 'Error al obtener ventas',
      );
    }

    final result = responseBody['result'];
    if (result is! List) return [];

    return result
        .map(
          (item) => TransactionListItem.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${Config.apiUrl}/transactions/$transactionId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener el pedido');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseBody['status'] != 200) {
      throw Exception(
        responseBody['message']?.toString() ?? 'Error al obtener el pedido',
      );
    }

    final result = responseBody['result'];
    if (result is! Map<String, dynamic>) {
      throw Exception('Pedido no encontrado');
    }

    return result;
  }

  Future<List<MovementOfArticle>> getMovementsOfArticlesByTransaction(
    String transactionId,
  ) async {
    final token = await _authService.getToken();
    final url = Uri.parse(
      '${Config.apiUrl}/movements-of-articles/by-transaction/$transactionId',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener los artículos del pedido');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseBody['status'] != 200) {
      throw Exception(
        responseBody['message']?.toString() ??
            'Error al obtener los artículos del pedido',
      );
    }

    final result = responseBody['result'];
    if (result is! List) return [];

    return result
        .map(
          (item) => MovementOfArticle.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> markTransactionAsDelivered(
    Map<String, dynamic> transaction,
  ) async {
    final id = transaction['_id']?.toString();
    if (id == null || id.isEmpty) {
      throw Exception('El pedido no tiene identificador');
    }

    final body = _prepareTransactionUpdate(transaction, state: 'Entregado');
    final token = await _authService.getToken();
    final url = Uri.parse('${Config.apiUrl}/transactions/$id');

    final response = await http.put(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && responseBody['status'] == 200) {
      final result = responseBody['result'];
      if (result is Map<String, dynamic>) return result;
      return body;
    }

    throw Exception(
      responseBody['message']?.toString() ?? 'Error al marcar como entregado',
    );
  }

  Map<String, dynamic> _prepareTransactionUpdate(
    Map<String, dynamic> transaction, {
    required String state,
  }) {
    final body = Map<String, dynamic>.from(transaction);
    body['state'] = state;
    body['_id'] = body['_id']?.toString();

    for (final key in _transactionRefKeys) {
      final value = body[key];
      if (value is Map && value['_id'] != null) {
        body[key] = value['_id'].toString();
      }
    }

    return body;
  }
}
