import 'package:app_pos/models/global_transaction.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/models/movement_of_cash.dart';
import 'package:app_pos/models/transaction.dart';

/// Construye el payload para POST /transactions/create.
class TransactionCreateMapper {
  static bool _hasId(String? v) => v != null && v.isNotEmpty;

  static Map<String, dynamic> toCreatePayload(GlobalTransaction state) {
    final transaction = state.transaction;
    if (transaction == null) {
      throw Exception('No hay transacción activa');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final movementsOfArticles = transaction.type.requestArticles
        ? state.movementsOfArticles
            .map((m) => _mapMovementOfArticle(m, transaction))
            .toList()
        : <Map<String, dynamic>>[];

    return {
      'transaction': _mapTransaction(transaction, now),
      'movementsOfArticles': movementsOfArticles,
      'movementsOfCashes': state.movementsOfCashes
          .map((m) => _mapMovementOfCash(m))
          .toList(),
    };
  }

  static Map<String, dynamic> _mapTransaction(Transaction t, String now) {
    final typeId = _hasId(t.type.id) ? t.type.id : null;
    if (typeId == null) {
      throw Exception(
          'El tipo de transacción no tiene un id válido. Revisá que se carguen correctamente los tipos.');
    }

    final total = t.totalPrice ?? 0;
    // Sin impuestos: todo el total va a exento.
    final exempt = t.type.requestTaxes ? 0.0 : total;

    final map = <String, dynamic>{
      'type': typeId,
      'totalPrice': total,
      'basePrice': total,
      'state': t.type.initialState,
      'origin': 0,
      'letter': '',
      'number': 0,
      'date': now,
      'startDate': now,
      'endDate': now,
      'expirationDate': now,
      'VATPeriod': '',
      'exempt': exempt,
      'quotation': 1,
      'balance': total,
      'madein': 'app',
      'businessRules': [],
      'balanceAccount': 0,
    };

    if (t.company != null && _hasId(t.company!.id)) {
      map['company'] = t.company!.id;
    }

    if (t.priceList != null && _hasId(t.priceList!.id)) {
      map['priceList'] = t.priceList!.id;
    }

    return map;
  }

  static Map<String, dynamic> _mapMovementOfArticle(
      MovementOfArticle m, Transaction t) {
    final articleId = m.article.id;
    if (!_hasId(articleId)) {
      throw Exception(
          'El artículo "${m.article.description}" no tiene _id.');
    }

    final stockMovement = t.type.stockMovement ?? 'Salida';

    final amount = m.amount ?? 1;
    final fallbackUnit =
        t.type.requestTaxes ? m.article.salePrice : m.article.basePrice;
    final unitPrice = m.unitPrice ?? fallbackUnit;
    final lineTotal = m.salePrice ?? (unitPrice * amount);

    final map = <String, dynamic>{
      'article': articleId,
      'amount': amount,
      'salePrice': lineTotal,
      'description': m.description ?? m.article.description,
      'basePrice': m.basePrice ?? m.article.basePrice,
      'unitPrice': unitPrice,
      'name': m.article.description,
      'code': m.code ?? '1',
      'codeSAT': '',
      'observation': m.observation ?? '',
      'costPrice': m.costPrice ?? 0,
      'markupPercentage': m.markupPercentage ?? 0,
      'markupPriceWithoutVAT': m.markupPriceWithoutVAT ?? 0,
      'markupPrice': m.markupPrice ?? 0,
      'discountRate': m.discountRate ?? 0,
      'discountAmount': m.discountAmount ?? 0,
      'transactionDiscountAmount': m.transactionDiscountAmount ?? 0,
      'roundingAmount': m.roundingAmount ?? 0,
      'quantityForStock': m.quantityForStock ?? 0,
      'notes': m.notes ?? '',
      'printed': m.printed ?? 0,
      'read': m.read ?? 0,
      'otherFields': [],
      'taxes': [],
      'isOptional': false,
      'printIn': 'ticket',
      'status': 'Alta',
      'op': 1,
      'measure': 'unidad',
      'quantityMeasure': 1,
      'modifyStock': true,
    };

    map['stockMovement'] = stockMovement;

    if (m.make != null && _hasId(m.make!.id)) {
      map['make'] = m.make!.id;
    }

    final categoryId = m.category?.id ?? m.article.category?.id;
    if (_hasId(categoryId)) {
      map['category'] = categoryId;
    }

    return map;
  }

  static Map<String, dynamic> _mapMovementOfCash(MovementOfCash m) {
    final typeId = m.type.id;
    if (!_hasId(typeId)) {
      throw Exception(
          'El método de pago "${m.type.name}" no tiene un id válido.');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    return {
      'type': typeId,
      'amountPaid': m.amountPaid ?? 0,
      'amountDiscount': m.amountDiscount ?? 0,
      'status': 'Autorizado',
      'date': now,
      'expirationDate': now,
      'quota': m.quota ?? 1,
      'discount': m.discount ?? 0,
      'surcharge': m.surcharge ?? 0,
      'commissionAmount': m.commissionAmount ?? 0,
      'administrativeExpenseAmount': m.administrativeExpenseAmount ?? 0,
      'otherExpenseAmount': m.otherExpenseAmount ?? 0,
      'capital': m.capital ?? 0,
      'interestPercentage': m.interestPercentage ?? 0,
      'interestAmount': m.interestAmount ?? 0,
      'taxPercentage': m.taxPercentage ?? 0,
      'taxAmount': m.taxAmount ?? 0,
    };
  }
}
