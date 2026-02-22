import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinalTransactionScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const FinalTransactionScreen({Key? key, required this.transactionId})
      : super(key: key);

  @override
  ConsumerState<FinalTransactionScreen> createState() =>
      _FinalTransactionScreenState();
}

class _FinalTransactionScreenState extends ConsumerState<FinalTransactionScreen> {
  final _emailService = EmailService();
  final _emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un correo')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await _emailService.sendTransactionEmail(
        transactionId: widget.transactionId,
        to: email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo enviado exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {

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
                      controller: _emailController,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: "Ingrese correo",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isSending ? null : _sendEmail,
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
                    ref.read(globalTransactionProvider.notifier).resetTransaction();
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
