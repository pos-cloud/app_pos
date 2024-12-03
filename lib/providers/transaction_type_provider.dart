import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/transaction_type_service.dart';
import 'package:app_pos/models/transaction_type.dart';

class TransactionTypeNotifier extends StateNotifier<List<TransactionType>> {
  final TransactionTypeService _transactionTypeService;

  TransactionTypeNotifier(this._transactionTypeService) : super([]);

  Future<void> loadTransactionTypes() async {
    try {
      final transactionTypes =
          await _transactionTypeService.getTransactionTypes();
      state = transactionTypes;
    } catch (e) {
      state = [];
    }
  }
}

final transactionTypeProvider =
    StateNotifierProvider<TransactionTypeNotifier, List<TransactionType>>(
  (ref) => TransactionTypeNotifier(TransactionTypeService()),
);
