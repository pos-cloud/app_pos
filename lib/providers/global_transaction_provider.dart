// providers/global_transaction_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/transaction_service.dart';
import 'package:app_pos/models/global_transaction.dart';
import 'dart:math';

class GlobalTransactionNotifier extends StateNotifier<GlobalTransaction> {
  final TransactionService transactionService;

  GlobalTransactionNotifier(this.transactionService)
      : super(GlobalTransaction(
          transaction: {},
          movementsOfArticles: [],
          movementsOfCashes: [],
        ));

  // Método para agregar un artículo al movimiento de artículos
  void addArticleMovement(dynamic article) {
    state = state.copyWith(
      movementsOfArticles: [...state.movementsOfArticles, article],
    );
    updateTotalPrice();
  }

  void resetTransaction() {
    state = state.reset(); // Reiniciar el estado completo
  }

  void setRandomTotalPrice() {
    double randomPrice = Random().nextDouble() *
        1000; // Genera un precio aleatorio entre 0 y 1000
    state = state.copyWith(transaction: {'totalPrice': randomPrice});
  }

  // Método para agregar un movimiento de efectivo
  void addCashMovement(dynamic cashMovement) {
    state = state.copyWith(
      movementsOfCashes: [...state.movementsOfCashes, cashMovement],
    );
    updateTotalPrice();
  }

  // Método para actualizar el total de la transacción (por ejemplo, después de agregar un artículo o cash)
  void updateTotalPrice() {
    // Aquí se podría implementar la lógica para recalcular el total de la transacción
    // y actualizar el campo 'transaction' si es necesario.
    // Por ejemplo:
    final totalPrice = calculateTotalPrice();
    state = state.copyWith(
      transaction: {...state.transaction, 'totalPrice': totalPrice},
    );
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var article in state.movementsOfArticles) {
      // Asumimos que cada artículo tiene un precio
      totalPrice += article['price'];
    }
    for (var cash in state.movementsOfCashes) {
      // Lo mismo para los movimientos de efectivo
      totalPrice += cash['amount'];
    }
    return totalPrice;
  }

  // Método para hacer el fetch de la transacción (simulación del post)
  Future<void> syncTransaction() async {
    try {
      await transactionService.syncTransaction({
        'transaction': state.transaction,
        'movementsOfArticles': state.movementsOfArticles,
        'movementsOfCashes': state.movementsOfCashes,
      });

      // Reseteamos el estado después de un sync exitoso
      state = state.reset();
    } catch (e) {
      throw Exception('Failed to sync transaction');
    }
  }
}

final globalTransactionProvider =
    StateNotifierProvider<GlobalTransactionNotifier, GlobalTransaction>(
  (ref) => GlobalTransactionNotifier(TransactionService()),
);
