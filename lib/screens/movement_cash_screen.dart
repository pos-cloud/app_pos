import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovementOfCashScreen extends ConsumerWidget {
  const MovementOfCashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos los movimientos de efectivo desde el provider
    final movementsOfCashes =
        ref.watch(globalTransactionProvider).movementsOfCashes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalle del pago",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: movementsOfCashes.isEmpty
            ? const Center(
                child: Text(
                  'No hay movimientos.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: movementsOfCashes.length,
                itemBuilder: (context, index) {
                  final movement = movementsOfCashes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${movement.amountPaid?.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            movement.type.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          // Llamar a una función del provider para eliminar el movimiento
                          ref
                              .read(globalTransactionProvider.notifier)
                              .deleteMovementOfCash(movement);
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
