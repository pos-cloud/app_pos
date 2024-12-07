import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectPaymentMethodButton extends ConsumerWidget {
  const SelectPaymentMethodButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPrice =
        ref.watch(globalTransactionProvider).transaction?.totalPrice ?? 0.0;

    // Calculamos el 15% de la altura de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight * 0.12; // 15% de la altura de la pantalla

    return Container(
      padding:
          const EdgeInsets.all(8.0), // Un poco de espacio alrededor del botón
      width: double.infinity, // Ocupa todo el ancho
      height: buttonHeight, // 15% de la altura de la pantalla
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentMethodScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          elevation: 8, // Sombra para el botón
          padding: const EdgeInsets.symmetric(
              horizontal: 16), // Espaciado dentro del botón
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra el contenido verticalmente
          children: [
            const Text(
              "Cobrar", // Texto principal
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4), // Espacio entre los textos
            Text(
              "\$${totalPrice.toStringAsFixed(2)}", // Muestra el total con dos decimales
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
