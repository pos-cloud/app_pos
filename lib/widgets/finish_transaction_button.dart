import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/finish_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishTransactionButton extends ConsumerWidget {
  const FinishTransactionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalTransaction = ref.watch(globalTransactionProvider);

    final hasArticles = globalTransaction.movementsOfArticles.isNotEmpty;
    final hasPaymentMethods = globalTransaction.movementsOfCashes.isNotEmpty;
    final totalPrice =
        globalTransaction.transaction?.totalPrice ?? 0.0;
    final totalPaid = globalTransaction.movementsOfCashes.fold<double>(
      0,
      (sum, m) => sum + (m.amountPaid ?? 0),
    );

    final isCovered = totalPaid >= totalPrice - 0.01;
    final canFinalize = hasArticles && hasPaymentMethods && isCovered;

    if (!hasArticles || !hasPaymentMethods || !canFinalize) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () async {
        try {
          final notifier = ref.read(globalTransactionProvider.notifier);
          final transactionId = await notifier.syncTransaction();

          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => FinalTransactionScreen(transactionId: transactionId),
            ),
            (route) => false, // Esto elimina todas las rutas anteriores
          );
        } catch (e) {
          if (!context.mounted) return;
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
