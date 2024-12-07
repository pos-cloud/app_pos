import 'package:app_pos/models/payment_method.dart';
import 'package:app_pos/services/payment_method.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodNotifier extends StateNotifier<List<PaymentMethod>> {
  final PaymentMethodService _paymentMethodService;

  PaymentMethodNotifier(this._paymentMethodService) : super([]);

  Future<void> loadMethodPayment() async {
    try {
      final paymentMethod = await _paymentMethodService.getPaymentMethod();
      state = paymentMethod;
    } catch (e) {
      print('Error al cargar metodos dep ago: $e');
      state = [];
    }
  }
}

final paymentMethodProvider =
    StateNotifierProvider<PaymentMethodNotifier, List<PaymentMethod>>(
  (ref) => PaymentMethodNotifier(PaymentMethodService()),
);
