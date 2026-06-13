import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/services/company_service.dart';
import 'package:app_pos/models/company.dart';

class CompanyNotifier extends StateNotifier<List<Company>> {
  final CompanyService _companyService;
  List<Company> _allCompanies = [];

  CompanyNotifier(this._companyService) : super([]);

  Future<void> loadCompanies({String? employeeId}) async {
    try {
      final companies = await _companyService.getCompanies(employeeId: employeeId);
      _allCompanies = companies;
      state = companies;
    } catch (e) {
      _allCompanies = [];
      state = [];
    }
  }

  Future<Company> updateCompany(Company company) async {
    final updated = await _companyService.updateCompany(company);
    _allCompanies = _allCompanies
        .map((c) => c.id == updated.id ? updated : c)
        .toList();
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
    return updated;
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
