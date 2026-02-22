import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/screens/movement_cash_screen.dart';
import 'package:app_pos/widgets/finish_transaction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmountToRemaining(double remaining) {
    _amountController.text = remaining.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice =
        ref.watch(globalTransactionProvider).transaction?.totalPrice ?? 0.0;
    final movementsOfCashes =
        ref.watch(globalTransactionProvider).movementsOfCashes;
    final paymentMethods = ref.watch(paymentMethodProvider);

    final totalPaid = movementsOfCashes.fold<double>(
      0,
      (sum, m) => sum + (m.amountPaid ?? 0),
    );
    final remaining = (totalPrice - totalPaid).clamp(0.0, double.infinity);
    final canAddMore = remaining > 0;

    if (canAddMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateAmountToRemaining(remaining);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovementOfCashScreen(),
                  ),
                );
              },
              child: const Text(
                "Métodos de Pago",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovementOfCashScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  movementsOfCashes.length.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "\$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Total a Pagar",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Text(
                      "\$${totalPaid.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Total Pagado",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                prefixText: "\$",
                labelText: "Monto Recibido",
                border: UnderlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: canAddMore
                          ? () {
                              final amount =
                                  double.tryParse(_amountController.text) ?? 0;
                              if (amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ingresá un monto válido'),
                                  ),
                                );
                                return;
                              }
                              if (amount > remaining + 0.01) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'El monto no puede superar \$${remaining.toStringAsFixed(2)}',
                                    ),
                                  ),
                                );
                                return;
                              }
                              ref
                                  .read(globalTransactionProvider.notifier)
                                  .addMovementOfCash(method, amount);
                              _amountController.clear();
                            }
                          : null,
                      child: Text(method.name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const FinishTransactionButton(),
    );
  }
}
