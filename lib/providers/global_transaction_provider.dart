import 'package:app_pos/mappers/transaction_create_mapper.dart';
import 'package:app_pos/models/article.dart';
import 'package:app_pos/models/company.dart';
import 'package:app_pos/models/global_transaction.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/models/movement_of_cash.dart';
import 'package:app_pos/models/payment_method.dart';
import 'package:app_pos/models/price_list.dart';
import 'package:app_pos/models/transaction.dart';
import 'package:app_pos/models/transaction_type.dart';
import 'package:app_pos/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalTransactionNotifier extends StateNotifier<GlobalTransaction> {
  final TransactionService transactionService;

  GlobalTransactionNotifier(this.transactionService)
      : super(GlobalTransaction(
          transaction: null,
          movementsOfArticles: [],
          movementsOfCashes: [],
        ));

  void addMovementOfArticle(Article article) {
    final movement = MovementOfArticle(
      description: article.description,
      basePrice: article.salePrice,
      unitPrice: article.salePrice,
      salePrice: article.salePrice,
      amount: 1,
      article: article,
      make: article.make,
      category: article.category,
    );

    final updatedMovements = [...state.movementsOfArticles, movement];
    final updatedTotalPrice =
        (state.transaction?.totalPrice ?? 0.0) + article.salePrice;

    state = state.copyWith(
      movementsOfArticles: updatedMovements,
      transaction: state.transaction?.copyWith(totalPrice: updatedTotalPrice),
    );
  }

  void deleteMovementOfArticle(int index) {
    final updatedMovements =
        List<MovementOfArticle>.from(state.movementsOfArticles);
    updatedMovements.removeAt(index);

    state = state.copyWith(movementsOfArticles: updatedMovements);
  }

  void addMovementOfCash(PaymentMethod paymentMethod, double amount) {
    final movement = MovementOfCash(type: paymentMethod, amountPaid: amount);

    final updateMovements = [...state.movementsOfCashes, movement];

    // Cuando el tipo solo pide método de pago (sin artículos), actualizar totalPrice
    final t = state.transaction;
    final updatedTotalPrice = (t?.type.requestArticles ?? true)
        ? (t?.totalPrice ?? 0.0)
        : (t?.totalPrice ?? 0.0) + amount;

    state = state.copyWith(
      movementsOfCashes: updateMovements,
      transaction: (t != null && !t.type.requestArticles)
          ? t.copyWith(totalPrice: updatedTotalPrice)
          : null,
    );
  }

  void deleteMovementOfCash(MovementOfCash movement) {
    final updatedMovements = List<MovementOfCash>.from(state.movementsOfCashes);
    updatedMovements.remove(movement);
    final t = state.transaction;
    // Cuando solo pide método de pago, recalcular totalPrice como suma de los pagos restantes
    final Transaction? updatedTransaction =
        (t != null && !t.type.requestArticles)
            ? t.copyWith(
                totalPrice: updatedMovements.fold<double>(
                  0,
                  (sum, m) => sum + (m.amountPaid ?? 0),
                ),
              )
            : null;
    state = state.copyWith(
      movementsOfCashes: updatedMovements,
      transaction: updatedTransaction ?? t,
    );
  }

  void resetTransaction() {
    state = state.reset();
  }

  Future<String> syncTransaction() async {
    try {
      final payload = TransactionCreateMapper.toCreatePayload(state);
      final transactionId =
          await transactionService.syncTransaction(payload);

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

  void updateCompany(Company company) {
    if (state.transaction == null) {
      throw Exception('No active transaction');
    }

    state = state.copyWith(
      transaction: state.transaction!.copyWith(company: company),
    );
  }

  void updatePriceList(PriceList? priceList) {
    if (state.transaction == null) {
      throw Exception('No active transaction');
    }

    state = state.copyWith(
      transaction: state.transaction!.copyWith(
        priceList: priceList,
        clearPriceList: priceList == null,
      ),
    );
  }
}

final globalTransactionProvider =
    StateNotifierProvider<GlobalTransactionNotifier, GlobalTransaction>(
  (ref) => GlobalTransactionNotifier(TransactionService()),
);
