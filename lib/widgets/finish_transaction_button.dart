import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/finish_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> finalizeCurrentTransaction(BuildContext context, WidgetRef ref) async {
  try {
    final notifier = ref.read(globalTransactionProvider.notifier);
    final transactionId = await notifier.syncTransaction();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => FinalTransactionScreen(transactionId: transactionId),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al finalizar: $e')),
    );
  }
}

class FinishTransactionButton extends ConsumerWidget {
  const FinishTransactionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalTransaction = ref.watch(globalTransactionProvider);
    final transaction = globalTransaction.transaction;
    if (transaction == null) return const SizedBox.shrink();

    final type = transaction.type;
    final requestPaymentMethods = type.requestPaymentMethods;
    final requestArticles = type.requestArticles;

    final hasArticles = globalTransaction.movementsOfArticles.isNotEmpty;
    final hasPaymentMethods = globalTransaction.movementsOfCashes.isNotEmpty;
    final totalPrice = transaction.totalPrice ?? 0.0;
    final totalPaid = globalTransaction.movementsOfCashes.fold<double>(
      0,
      (sum, m) => sum + (m.amountPaid ?? 0),
    );

    final isCovered = totalPaid >= totalPrice - 0.01;

    final bool canFinalize;
    if (requestPaymentMethods) {
      canFinalize = requestArticles
          ? hasArticles && hasPaymentMethods && isCovered
          : hasPaymentMethods && (totalPrice <= 0 || isCovered);
    } else {
      canFinalize = !requestArticles || hasArticles;
    }

    if (!canFinalize) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => finalizeCurrentTransaction(context, ref),
      tooltip: 'Finalizar transacción',
      child: const Icon(Icons.check),
    );
  }
}
