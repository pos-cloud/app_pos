import 'package:app_pos/models/vat_condition.dart';
import 'package:app_pos/services/vat_condition_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VatConditionNotifier extends StateNotifier<List<VatCondition>> {
  final VatConditionService _service;

  VatConditionNotifier(this._service) : super([]);

  Future<void> loadVatConditions() async {
    try {
      state = await _service.getVatConditions();
    } catch (_) {
      state = [];
    }
  }
}

final vatConditionProvider =
    StateNotifierProvider<VatConditionNotifier, List<VatCondition>>(
  (ref) => VatConditionNotifier(VatConditionService()),
);
