import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/price_list_service.dart';
import 'package:app_pos/models/price_list.dart';

class PriceListNotifier extends StateNotifier<List<PriceList>> {
  final PriceListService _priceListService;

  PriceListNotifier(this._priceListService) : super([]);

  Future<void> loadPriceLists() async {
    try {
      final priceLists = await _priceListService.getPriceLists();
      state = priceLists;
    } catch (_) {
      state = [];
    }
  }
}

final priceListProvider =
    StateNotifierProvider<PriceListNotifier, List<PriceList>>(
  (ref) => PriceListNotifier(PriceListService()),
);
