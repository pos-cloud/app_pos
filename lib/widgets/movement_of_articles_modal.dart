import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';

class MovementOfArticlesModal extends ConsumerWidget {
  const MovementOfArticlesModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener los movimientos de artículos desde el provider
    final movements = ref.watch(globalTransactionProvider).movementsOfArticles;

    return GestureDetector(
      onTap: () {
        // Cierra el modal si se toca fuera de él
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5), // Fondo oscuro
        body: SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.7, // Tamaño inicial
            minChildSize: 0.3, // Tamaño mínimo
            maxChildSize: 1.0, // Tamaño máximo
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Movimientos de Artículos',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (movements.isEmpty)
                      const Center(
                          child: Text('No hay movimientos de artículos.'))
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: movements.length,
                          itemBuilder: (context, index) {
                            final movement = movements[index];
                            return ListTile(
                              title: Text(movement.article.description),
                              subtitle: Text('Cantidad: ${movement.amount}'),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Acción de eliminación de movimientos
                          // ref
                          //     .read(globalTransactionProvider.notifier)
                          //     .deleteMovement();
                          Navigator.of(context)
                              .pop(); // Cierra el modal después de la acción
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
