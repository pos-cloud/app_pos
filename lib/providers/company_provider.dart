import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/company_service.dart';
import 'package:app_pos/models/company.dart';

class CompanyNotifier extends StateNotifier<List<Company>> {
  final CompanyService _companyService;

  CompanyNotifier(this._companyService) : super([]);

  Future<void> loadCompanies() async {
    try {
      final companies = await _companyService.getCompanies();
      state = companies;
    } catch (e) {
      state = [];
    }
  }

  Future<void> searchCompanies(String query) async {
    try {
      // Llamamos a `getCompanies` con el filtro opcional
      state = [];
      final companies = await _companyService.getCompanies(searchQuery: query);
      state = companies;
    } catch (e) {
      print('Error al cargar searchCompanies: $e');
      state = []; // Manejo de errores: dejamos la lista vacía
    }
  }
}

final companyProvider = StateNotifierProvider<CompanyNotifier, List<Company>>(
  (ref) => CompanyNotifier(CompanyService()),
);
