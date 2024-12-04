import 'package:app_pos/models/transaction.dart'; // Asegúrate de tener este modelo importado
import 'package:app_pos/models/movement_of_article.dart'; // Asegúrate de tener este modelo importado
import 'package:app_pos/models/movement_of_cash.dart'; // Asegúrate de tener este modelo importado

class GlobalTransaction {
  final Transaction? transaction;
  final List<MovementOfArticle> movementsOfArticles;
  final List<MovementOfCash> movementsOfCashes;

  GlobalTransaction({
    required this.transaction,
    required this.movementsOfArticles,
    required this.movementsOfCashes,
  });

  // Ajuste para crear un objeto vacío de Transaction
  GlobalTransaction reset() {
    return GlobalTransaction(
      transaction: null,
      movementsOfArticles: [],
      movementsOfCashes: [],
    );
  }

  GlobalTransaction copyWith({
    Transaction? transaction,
    List<MovementOfArticle>? movementsOfArticles,
    List<MovementOfCash>? movementsOfCashes,
  }) {
    return GlobalTransaction(
      transaction: transaction ?? this.transaction,
      movementsOfArticles: movementsOfArticles ?? this.movementsOfArticles,
      movementsOfCashes: movementsOfCashes ?? this.movementsOfCashes,
    );
  }
}
