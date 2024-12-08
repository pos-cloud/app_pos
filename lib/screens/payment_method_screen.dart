import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/screens/movement_cash_screen.dart';
import 'package:app_pos/widgets/finish_transaction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPrice =
        ref.watch(globalTransactionProvider).transaction?.totalPrice ?? 0;

    final paymentMethods = ref.watch(paymentMethodProvider);
    final movementsOfCashes =
        ref.watch(globalTransactionProvider).movementsOfCashes;

    double totalPaid = movementsOfCashes.fold(0, (sum, movement) {
      return sum +
          (movement.amountPaid ?? 0); // Si amountPaid es nulo, suma 0.0
    });

    final TextEditingController controller = TextEditingController(
      text: totalPrice.toStringAsFixed(0),
    );

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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8), // Espacio entre el texto y el ícono
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
                      color: Colors.black),
                ),
              ),
            )
          ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Total a Pagar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\$${totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Total a Pagar",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\$${totalPaid.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Total Pagado",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                prefixText: "\$",
                labelText: "Monto Recibido",
                border: UnderlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // Lista de botones de métodos de pago
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(controller.text) ?? 0.0;

                      ref
                          .read(globalTransactionProvider.notifier)
                          .addMovementOfCash(method, amount);
                    },
                    child: Text(method.name),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: const FinishTransactionButton(),
    );
  }
}
