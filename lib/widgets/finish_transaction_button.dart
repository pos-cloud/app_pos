import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/finish_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishTransactionButton extends ConsumerWidget {
  const FinishTransactionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalTransaction = ref.watch(globalTransactionProvider);

    // Solo mostrar el botón si hay artículos y métodos de pago
    final hasArticles = globalTransaction.movementsOfArticles.isNotEmpty;
    final hasPaymentMethods = globalTransaction.movementsOfCashes.isNotEmpty;

    if (!hasArticles || !hasPaymentMethods) {
      return const SizedBox.shrink(); // No mostrar el botón
    }

    return FloatingActionButton(
      onPressed: () async {
        try {
          // final notifier = ref.read(globalTransactionProvider.notifier);
          // final transactionId = await notifier.syncTransaction();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const FinalTransactionScreen(transactionId: ''),
            ),
            (route) => false, // Esto elimina todas las rutas anteriores
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al sincronizar: $e')),
          );
        }
      },
      tooltip: 'Finalizar transacción',
      child: const Icon(Icons.check),
    );
  }
}
