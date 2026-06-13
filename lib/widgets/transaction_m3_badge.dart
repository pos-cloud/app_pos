import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Total de m³ acumulado en la venta actual (solo artículos con [Article.m3]).
class TransactionM3Badge extends ConsumerWidget {
  const TransactionM3Badge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalM3 = ref.watch(globalTransactionProvider).movementsOfArticles.fold(
          0.0,
          (sum, movement) => sum + movement.lineM3,
        );

    if (totalM3 <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black, width: 0.8),
      ),
      child: Text(
        '${totalM3.asQuantity} m³',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
