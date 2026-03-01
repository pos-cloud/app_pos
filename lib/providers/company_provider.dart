import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/company_service.dart';
import 'package:app_pos/models/company.dart';

class CompanyNotifier extends StateNotifier<List<Company>> {
  final CompanyService _companyService;
  List<Company> _allCompanies = [];

  CompanyNotifier(this._companyService) : super([]);

  Future<void> loadCompanies() async {
    try {
      final companies = await _companyService.getCompanies();
      _allCompanies = companies;
      state = companies;
    } catch (e) {
      _allCompanies = [];
      state = [];
    }
  }

  void searchCompanies(String query) {
    if (query.trim().isEmpty) {
      state = List.from(_allCompanies);
      return;
    }
    final lowerQuery = query.toLowerCase().trim();
    state = _allCompanies.where((company) {
      final name = company.name.toLowerCase();
      final fantasyName = (company.fantasyName ?? '').toLowerCase();
      final identificationValue =
          (company.identificationValue ?? '').toLowerCase();
      return name.contains(lowerQuery) ||
          fantasyName.contains(lowerQuery) ||
          identificationValue.contains(lowerQuery);
    }).toList();
  }
}

final companyProvider = StateNotifierProvider<CompanyNotifier, List<Company>>(
  (ref) => CompanyNotifier(CompanyService()),
);
