import 'package:app_pos/models/tax.dart';
import 'package:app_pos/services/tax_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxNotifier extends StateNotifier<List<Tax>> {
  final TaxService _service;

  TaxNotifier(this._service) : super([]);

  Future<void> loadTaxes() async {
    try {
      state = await _service.getTaxes();
    } catch (_) {
      state = [];
    }
  }
}

final taxProvider = StateNotifierProvider<TaxNotifier, List<Tax>>(
  (ref) => TaxNotifier(TaxService()),
);
