// models/global_transaction.dart
class GlobalTransaction {
  final Map<String, dynamic> transaction;
  final List<dynamic> movementsOfArticles;
  final List<dynamic> movementsOfCashes;

  GlobalTransaction({
    required this.transaction,
    required this.movementsOfArticles,
    required this.movementsOfCashes,
  });

  // Método para restablecer el estado (por ejemplo, después de enviar la transacción)
  GlobalTransaction reset() {
    return GlobalTransaction(
      transaction: {'totalPrice': 200.20},
      movementsOfArticles: [],
      movementsOfCashes: [],
    );
  }

  // Método para actualizar una parte del estado (por ejemplo, agregar un artículo)
  GlobalTransaction copyWith({
    Map<String, dynamic>? transaction,
    List<dynamic>? movementsOfArticles,
    List<dynamic>? movementsOfCashes,
  }) {
    return GlobalTransaction(
      transaction: transaction ?? this.transaction,
      movementsOfArticles: movementsOfArticles ?? this.movementsOfArticles,
      movementsOfCashes: movementsOfCashes ?? this.movementsOfCashes,
    );
  }
}
