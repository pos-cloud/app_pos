// providers/global_transaction_provider.dart
import 'package:app_pos/models/article.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/models/movement_of_cash.dart';
import 'package:app_pos/models/payment_method.dart';
import 'package:app_pos/models/transaction.dart';
import 'package:app_pos/models/transaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/transaction_service.dart';
import 'package:app_pos/models/global_transaction.dart';

class GlobalTransactionNotifier extends StateNotifier<GlobalTransaction> {
  final TransactionService transactionService;

  GlobalTransactionNotifier(this.transactionService)
      : super(GlobalTransaction(
          transaction: null,
          movementsOfArticles: [],
          movementsOfCashes: [],
        ));

  void addArticleMovement(Article article) {
    final movement = MovementOfArticle(
      description: article.description,
      basePrice: article.salePrice,
      unitPrice: article.salePrice,
      salePrice: article.salePrice,
      amount: 1,
      article: article,
    );

    final updatedMovements = [...state.movementsOfArticles, movement];
    final updatedTotalPrice =
        (state.transaction?.totalPrice ?? 0.0) + article.salePrice;

    state = state.copyWith(
      movementsOfArticles: updatedMovements,
      transaction: state.transaction?.copyWith(totalPrice: updatedTotalPrice),
    );
  }

  void addMovementOfCash(PaymentMethod paymentMethod) {
    final movement = MovementOfCash(type: paymentMethod);

    final updateMovements = [...state.movementsOfCashes, movement];

    state = state.copyWith(movementsOfCashes: updateMovements);
  }

  void sendMail(String id, String email) {}

  void resetTransaction() {
    state = state.reset();
  }

  // Método para hacer el fetch de la transacción (simulación del post)
  Future<String> syncTransaction() async {
    try {
      final transactionId = await transactionService.syncTransaction({
        'transaction': state.transaction,
        'movementsOfArticles': state.movementsOfArticles,
        'movementsOfCashes': state.movementsOfCashes,
      });

      state = state.reset();

      return transactionId;
    } catch (e) {
      throw Exception('$e');
    }
  }

  void updateTransactionType(TransactionType? transactionType) {
    if (transactionType == null) {
      throw Exception('Transaction type cannot be null');
    }

    state = state.copyWith(
        transaction: Transaction(
            type: transactionType, totalPrice: 0.00, state: "Cerrado"),
        movementsOfArticles: [],
        movementsOfCashes: []);
  }
}

final globalTransactionProvider =
    StateNotifierProvider<GlobalTransactionNotifier, GlobalTransaction>(
  (ref) => GlobalTransactionNotifier(TransactionService()),
);
