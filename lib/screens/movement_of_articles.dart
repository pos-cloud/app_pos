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

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(movement.article.description),
                      subtitle: Text('Cantidad: ${movement.amount}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
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
