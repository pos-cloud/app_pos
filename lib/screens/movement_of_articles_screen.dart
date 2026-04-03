import 'package:app_pos/widgets/edit_movement_of_article_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';

class MovementOfArticlesScreen extends ConsumerWidget {
  const MovementOfArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final global = ref.watch(globalTransactionProvider);
    final movements = global.movementsOfArticles;
    final transactionTotal = global.transaction?.totalPrice ?? 0.0;

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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: movements.isEmpty
                  ? const Center(child: Text('No hay movimientos de artículos.'))
                  : ListView.builder(
                      itemCount: movements.length,
                      itemBuilder: (context, index) {
                        final movement = movements[index];
                        final unitPrice = movement.effectiveUnitPrice;
                        final amount = movement.effectiveAmount;
                        final lineTotal = movement.lineTotal;
                        final notes = movement.notes?.trim();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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
                                  'Total línea: \$${lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (notes != null && notes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Obs.: $notes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Editar',
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (ctx) =>
                                          EditMovementOfArticleDialog(
                                        movement: movement,
                                        index: index,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Eliminar',
                                  onPressed: () {
                                    ref
                                        .read(globalTransactionProvider.notifier)
                                        .deleteMovementOfArticle(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (movements.isNotEmpty)
            Material(
              elevation: 8,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '\$${transactionTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
