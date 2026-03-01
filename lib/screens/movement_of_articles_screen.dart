import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';

class MovementOfArticlesScreen extends ConsumerWidget {
  const MovementOfArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener los movimientos de artículos desde el provider
    final movements = ref.watch(globalTransactionProvider).movementsOfArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de Artículos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: movements.isEmpty
            ? const Center(child: Text('No hay movimientos de artículos.'))
            : ListView.builder(
                itemCount: movements.length,
                itemBuilder: (context, index) {
                  final movement = movements[index];

                  final unitPrice =
                      movement.unitPrice ?? movement.salePrice ?? 0.0;
                  final amount = movement.amount ?? 1.0;
                  final total = unitPrice * amount;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(movement.article.description),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cantidad: ${amount == amount.roundToDouble() ? amount.toInt() : amount.toStringAsFixed(2)}',
                          ),
                          Text(
                            'Precio unitario: \$${unitPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Llamar al método para eliminar el movimiento
                          ref
                              .read(globalTransactionProvider.notifier)
                              .deleteMovementOfArticle(index);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
