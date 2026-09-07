import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/movement_of_articles_screen.dart';
import 'package:app_pos/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Misma franja superior: con cobro va a métodos de pago; solo artículos muestra total y abre detalle.
class SelectPaymentMethodButton extends ConsumerWidget {
  const SelectPaymentMethodButton({
    Key? key,
    this.paymentFlow = true,
  }) : super(key: key);

  /// `true`: texto "Cobrar" y navega a [PaymentMethodScreen].
  /// `false`: texto "Total" y navega a [MovementOfArticlesScreen] (sin flujo de cobro).
  final bool paymentFlow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(globalTransactionProvider).transaction;
    final totalPrice = transaction?.totalPrice ?? 0.0;
    final hasDiscount = transaction?.hasCompanyDiscount ?? false;
    final discountPercent = transaction?.discountPercent ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      width: double.infinity,
      child: SizedBox(
        height: hasDiscount ? 88 : 70,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => paymentFlow
                    ? const PaymentMethodScreen()
                    : const MovementOfArticlesScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                paymentFlow ? 'Cobrar' : 'Total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalPrice.asMoney,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 2),
                Text(
                  'Desc. ${discountPercent.asPercent}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
