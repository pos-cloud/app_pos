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
  Future<String>? _syncInFlight;

  GlobalTransactionNotifier(this.transactionService)
      : super(GlobalTransaction(
          transaction: null,
          movementsOfArticles: [],
          movementsOfCashes: [],
        ));

  static double _round2(double value) => (value * 100).round() / 100;

  static double _grossFromArticleMovements(List<MovementOfArticle> movements) {
    return movements.fold<double>(
      0,
      (sum, m) => sum + m.lineTotal,
    );
  }

  /// Descuento del cliente/grupo si el tipo de transacción lo permite.
  static double _discountPercentFor(Company? company, TransactionType type) {
    if (!type.allowCompanyDiscount || company == null) return 0;
    final percent = company.totalDiscount;
    if (percent <= 0) return 0;
    return percent > 100 ? 100 : percent;
  }

  static double _discountAmountFor(double gross, double discountPercent) {
    if (discountPercent <= 0 || gross <= 0) return 0;
    return _round2(gross * discountPercent / 100);
  }

  static double _netTotal(double gross, double discountPercent) {
    return _round2(gross - _discountAmountFor(gross, discountPercent));
  }

  List<MovementOfArticle> _withTransactionDiscount(
    List<MovementOfArticle> movements,
    double discountPercent,
  ) {
    return movements
        .map((m) {
          final unit = m.effectiveUnitPrice;
          final perUnit = discountPercent > 0
              ? _round2(unit * discountPercent / 100)
              : 0.0;
          return m.copyWith(transactionDiscountAmount: perUnit);
        })
        .toList();
  }

  Transaction? _transactionWithArticleTotals(
    List<MovementOfArticle> movements, {
    Company? company,
    double? discountPercent,
  }) {
    final current = state.transaction;
    if (current == null) return null;

    final percent = discountPercent ?? current.discountPercent;

    if (!current.type.requestArticles) {
      return current.copyWith(
        company: company ?? current.company,
        discountPercent: percent,
        discountAmount: 0,
      );
    }

    final gross = _grossFromArticleMovements(movements);
    return current.copyWith(
      company: company ?? current.company,
      discountPercent: percent,
      discountAmount: _discountAmountFor(gross, percent),
      totalPrice: _netTotal(gross, percent),
    );
  }

  void addMovementOfArticle(Article article) {
    const qty = 1.0;
    final requestTaxes = state.transaction?.type.requestTaxes ?? true;
    final unit = article.unitPriceFor(requestTaxes: requestTaxes);
    final discountPercent = state.transaction?.discountPercent ?? 0;
    final transactionDiscountAmount = discountPercent > 0
        ? _round2(unit * discountPercent / 100)
        : 0.0;
    final movement = MovementOfArticle(
      description: article.description,
      basePrice: requestTaxes ? article.basePrice : unit,
      unitPrice: unit,
      salePrice: unit * qty,
      amount: qty,
      article: article,
      make: article.make,
      category: article.category,
      transactionDiscountAmount: transactionDiscountAmount,
    );

    final updatedMovements = [...state.movementsOfArticles, movement];

    state = state.copyWith(
      movementsOfArticles: updatedMovements,
      transaction: _transactionWithArticleTotals(updatedMovements),
    );
  }

  void updateMovementOfArticle(int index, MovementOfArticle updated) {
    if (index < 0 || index >= state.movementsOfArticles.length) {
      return;
    }
    final discountPercent = state.transaction?.discountPercent ?? 0;
    final unit = updated.effectiveUnitPrice;
    final withDiscount = updated.copyWith(
      transactionDiscountAmount: discountPercent > 0
          ? _round2(unit * discountPercent / 100)
          : 0.0,
    );
    final list = List<MovementOfArticle>.from(state.movementsOfArticles);
    list[index] = withDiscount;
    state = state.copyWith(
      movementsOfArticles: list,
      transaction: _transactionWithArticleTotals(list),
    );
  }

  void deleteMovementOfArticle(int index) {
    final updatedMovements =
        List<MovementOfArticle>.from(state.movementsOfArticles);
    updatedMovements.removeAt(index);

    state = state.copyWith(
      movementsOfArticles: updatedMovements,
      transaction: _transactionWithArticleTotals(updatedMovements),
    );
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
    if (_syncInFlight != null) {
      return _syncInFlight!;
    }

    _syncInFlight = _performSync();
    try {
      return await _syncInFlight!;
    } finally {
      _syncInFlight = null;
    }
  }

  Future<String> _performSync() async {
    try {
      _ensureCompanyReady();
      final payload = TransactionCreateMapper.toCreatePayload(state);
      final transactionId =
          await transactionService.syncTransaction(payload);

      state = state.reset();

      return transactionId;
    } catch (e) {
      throw Exception('$e');
    }
  }

  void _ensureCompanyReady() {
    final t = state.transaction;
    if (t == null) return;

    if (!t.hasAssignedCompany && t.type.hasDefaultCompany) {
      final company = t.type.company!;
      final percent = _discountPercentFor(company, t.type);
      final movements = _withTransactionDiscount(
        state.movementsOfArticles,
        percent,
      );
      state = state.copyWith(
        movementsOfArticles: movements,
        transaction: _transactionWithArticleTotals(
          movements,
          company: company,
          discountPercent: percent,
        ),
      );
    }

    final current = state.transaction!;
    if (current.type.requiresCompanySelection && !current.hasAssignedCompany) {
      throw Exception(
        'Debés seleccionar un cliente para este tipo de transacción',
      );
    }
  }

  void updateTransactionType(TransactionType? transactionType) {
    if (transactionType == null) {
      throw Exception('Transaction type cannot be null');
    }

    final company = transactionType.company;
    final discountPercent = _discountPercentFor(company, transactionType);

    state = state.copyWith(
        transaction: Transaction(
            type: transactionType,
            totalPrice: 0.00,
            state: transactionType.initialState,
            company: company,
            discountPercent: discountPercent,
            discountAmount: 0),
        movementsOfArticles: [],
        movementsOfCashes: []);
  }

  void updateCompany(Company company) {
    if (state.transaction == null) {
      throw Exception('No active transaction');
    }

    final type = state.transaction!.type;
    final discountPercent = _discountPercentFor(company, type);
    final movements = _withTransactionDiscount(
      state.movementsOfArticles,
      discountPercent,
    );

    state = state.copyWith(
      movementsOfArticles: movements,
      transaction: _transactionWithArticleTotals(
        movements,
        company: company,
        discountPercent: discountPercent,
      ),
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
