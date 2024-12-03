// providers/transaction_movement_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/models/transaction_movement.dart';

/// Provider para gestionar el movimiento de transacción seleccionado.
final transactionMovementProvider =
    StateProvider<TransactionMovement>((ref) => TransactionMovement.sale);
