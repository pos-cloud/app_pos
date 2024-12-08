import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';

class DeleteTransactionDialog extends ConsumerWidget {
  const DeleteTransactionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text("Confirmar acción"),
      content:
          const Text("¿Estás seguro de que deseas eliminar la transacción?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cierra el modal
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            // Limpia la transacción
            ref.read(globalTransactionProvider.notifier).resetTransaction();

            // Cierra el modal
            Navigator.of(context).pop();
          },
          child: const Text("Sí"),
        ),
      ],
    );
  }
}
