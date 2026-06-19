import 'package:app_pos/models/transaction_list_item.dart';
import 'package:app_pos/services/transaction_list_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesTransactionsNotifier
    extends StateNotifier<List<TransactionListItem>> {
  final TransactionListService _service;
  List<TransactionListItem> _allTransactions = [];

  SalesTransactionsNotifier(this._service) : super([]);

  Future<void> loadTransactions({
    String? employeeId,
    List<String>? transactionTypeIds,
    required String transactionState,
  }) async {
    try {
      final transactions = await _service.getSalesTransactions(
        employeeId: employeeId,
        transactionTypeIds: transactionTypeIds,
        state: transactionState,
      );
      _allTransactions = transactions;
      this.state = transactions;
    } catch (_) {
      _allTransactions = [];
      this.state = [];
      rethrow;
    }
  }

  void clearTransactions() {
    _allTransactions = [];
    this.state = [];
  }

  void searchTransactions(String query) {
    if (query.trim().isEmpty) {
      this.state = List.from(_allTransactions);
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    this.state = _allTransactions.where((transaction) {
      final number = transaction.displayNumber.toLowerCase();
      final company = (transaction.companyName ?? '').toLowerCase();
      final city = (transaction.deliveryCity ?? '').toLowerCase();
      final address = (transaction.deliveryAddress ?? '').toLowerCase();
      final employee = (transaction.employeeClosingName ?? '').toLowerCase();
      final shipment = (transaction.shipmentMethodName ?? '').toLowerCase();
      final typeName = (transaction.typeName ?? '').toLowerCase();
      return number.contains(lowerQuery) ||
          company.contains(lowerQuery) ||
          city.contains(lowerQuery) ||
          address.contains(lowerQuery) ||
          employee.contains(lowerQuery) ||
          shipment.contains(lowerQuery) ||
          typeName.contains(lowerQuery);
    }).toList();
  }
}

final salesTransactionsProvider = StateNotifierProvider<
    SalesTransactionsNotifier, List<TransactionListItem>>(
  (ref) => SalesTransactionsNotifier(TransactionListService()),
);
