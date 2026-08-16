import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/sales_transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void _showFullScreenLoading(BuildContext context) {
  showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: 'Finalizando transacción',
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Finalizando transacción...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> finalizeCurrentTransaction(BuildContext context, WidgetRef ref) async {
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  _showFullScreenLoading(context);

  try {
    final notifier = ref.read(globalTransactionProvider.notifier);
    final transactionId = await notifier.syncTransaction();

    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => SalesTransactionDetailScreen(
          transactionId: transactionId,
          returnToMainOnBack: true,
        ),
      ),
      (route) => false,
    );
  } catch (e) {
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar: $e')),
      );
    }
  }
}

class FinishTransactionButton extends ConsumerStatefulWidget {
  const FinishTransactionButton({Key? key}) : super(key: key);

  @override
  ConsumerState<FinishTransactionButton> createState() =>
      _FinishTransactionButtonState();
}

class _FinishTransactionButtonState extends ConsumerState<FinishTransactionButton> {
  bool _isFinalizing = false;

  Future<bool> _confirmFinalize() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar transacción'),
        content: const Text(
          '¿Estás seguro de que querés finalizar la transacción? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _onPressed() async {
    if (_isFinalizing) return;

    final confirmed = await _confirmFinalize();
    if (!confirmed || !mounted) return;

    setState(() => _isFinalizing = true);
    try {
      await finalizeCurrentTransaction(context, ref);
    } finally {
      if (mounted) setState(() => _isFinalizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final hasRequiredCompany =
        !type.requiresCompanySelection || transaction.hasAssignedCompany;

    final bool canFinalize;
    if (!hasRequiredCompany) {
      canFinalize = false;
    } else if (requestPaymentMethods) {
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
      onPressed: _isFinalizing ? null : _onPressed,
      tooltip: 'Finalizar transacción',
      child: _isFinalizing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check),
    );
  }
}
