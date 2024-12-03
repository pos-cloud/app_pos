// models/transaction_movement.dart

/// Enum para representar los movimientos de transacción.
enum TransactionMovement {
  sale('Venta'),
  purchase('Compra'),
  stock('Stock'),
  production('Producción'),
  money('Fondos');

  final String name;

  const TransactionMovement(this.name);
}
