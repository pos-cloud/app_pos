import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinalTransactionScreen extends ConsumerWidget {
  final String transactionId;

  const FinalTransactionScreen({Key? key, required this.transactionId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();

    return PopScope(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              const Center(
                child: Text(
                  "Transacción Finalizada con éxito",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Ingrese correo",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            final email = emailController.text.trim();
                            if (email.isNotEmpty) {
                              try {
                                ref
                                    .read(globalTransactionProvider.notifier)
                                    .sendMail(transactionId, email);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Correo enviado exitosamente")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Error: ${e.toString()}")),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Por favor ingresa un correo")),
                              );
                            }
                          },
                        ),
                        border: const UnderlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Botón cuadrado
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(globalTransactionProvider.notifier)
                        .resetTransaction();
                    Navigator.pushReplacementNamed(context, '/main_screen');
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Nueva Transacción"),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
