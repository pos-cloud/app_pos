import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/screens/finish_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtén el totalPrice desde el provider
    final totalPrice =
        ref.watch(globalTransactionProvider).transaction?.totalPrice ?? 0.0;

    // Obtén la lista de métodos de pago
    final paymentMethods = ref.watch(paymentMethodProvider);

    final TextEditingController controller = TextEditingController(
      text: totalPrice.toStringAsFixed(2), // Inicializar con totalPrice
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Métodos de Pago", style: TextStyle(fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.splitscreen),
            onPressed: () {
              print("Botón Dividir presionado");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Total a pagar (fijo y grande)
            Text(
              "\$${totalPrice.toStringAsFixed(2)}", // Muestra el total con dos decimales
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Total a Pagar", // Texto pequeño debajo
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            // Input para total recibido con el simbolo $
            TextFormField(
              controller: controller, // Asignamos el controlador
              decoration: const InputDecoration(
                prefixText: "\$",
                labelText: "Monto Recibido", // Label flotante dentro del input
                border: UnderlineInputBorder(), // Línea abajo para el subrayado
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
                      final notifier =
                          ref.read(globalTransactionProvider.notifier);
                      ref
                          .read(globalTransactionProvider.notifier)
                          .addMovementOfCash(method);

                      try {
                        //final transactionId = await notifier.syncTransaction();

                        // Navegamos a la pantalla de transacción finalizada y eliminamos las rutas previas
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FinalTransactionScreen(transactionId: ''),
                          ),
                          (route) =>
                              false, // Esto elimina todas las rutas anteriores
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al sincronizar: $e')),
                        );
                      }
                    },
                    child: Text(method.name),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
