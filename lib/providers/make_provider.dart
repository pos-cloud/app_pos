import 'package:app_pos/models/make.dart';
import 'package:app_pos/services/make_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MakeNotifier extends StateNotifier<List<Make>> {
  final MakeService _service;

  MakeNotifier(this._service) : super([]);

  Future<void> loadMakes() async {
    try {
      state = await _service.getMakes();
    } catch (_) {
      state = [];
    }
  }
}

final makeProvider = StateNotifierProvider<MakeNotifier, List<Make>>(
  (ref) => MakeNotifier(MakeService()),
);
