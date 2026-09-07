import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/providers/auth_provider.dart';
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
    final transaction = global.transaction;
    final transactionTotal = transaction?.totalPrice ?? 0.0;
    final discountPercent = transaction?.discountPercent ?? 0;
    final discountAmount = transaction?.discountAmount ?? 0;
    final hasDiscount = discountPercent > 0 && discountAmount > 0;
    final canEditPrice =
        ref.watch(authUserProvider)?.permission?.collections.movementsOfArticles.edit ==
            true;

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
                        final discountedUnit = movement.discountedUnitPrice;
                        final discountedTotal = movement.discountedLineTotal;
                        final hasLineDiscount =
                            movement.effectiveTransactionDiscount > 0;
                        final notes = movement.notes?.trim();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            onTap: () {
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => EditMovementOfArticleDialog(
                                  movement: movement,
                                  index: index,
                                  canEditPrice: canEditPrice,
                                ),
                              );
                            },
                            title: Text(movement.article.description),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cantidad: ${amount.asQuantity}',
                                ),
                                if (hasLineDiscount) ...[
                                  Text(
                                    'Precio unitario: ${unitPrice.asMoney}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    'Con desc.: ${discountedUnit.asMoney}',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Total línea: ${discountedTotal.asMoney}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'Precio unitario: ${unitPrice.asMoney}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Total línea: ${lineTotal.asMoney}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar',
                              onPressed: () {
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
          ),
          if (movements.isNotEmpty)
            Material(
              elevation: 8,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    children: [
                      if (hasDiscount) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey.shade700),
                            ),
                            Text(
                              (transactionTotal + discountAmount).asMoney,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Descuento ${discountPercent.asPercent}',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '-${discountAmount.asMoney}',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          Text(
                            transactionTotal.asMoney,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
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
