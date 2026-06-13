import 'package:app_pos/models/identification_type.dart';
import 'package:app_pos/services/identification_type_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IdentificationTypeNotifier extends StateNotifier<List<IdentificationType>> {
  final IdentificationTypeService _service;

  IdentificationTypeNotifier(this._service) : super([]);

  Future<void> loadIdentificationTypes() async {
    try {
      state = await _service.getIdentificationTypes();
    } catch (_) {
      state = [];
    }
  }
}

final identificationTypeProvider =
    StateNotifierProvider<IdentificationTypeNotifier, List<IdentificationType>>(
  (ref) => IdentificationTypeNotifier(IdentificationTypeService()),
);
