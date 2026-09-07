import 'dart:async';
import 'package:app_pos/models/company.dart';
import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/providers/company_provider.dart';
import 'package:app_pos/screens/edit_client_screen.dart';
import 'package:app_pos/widgets/company_discount_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  static const path = '/clients';

  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  late final _Debouncer _debouncer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _debouncer = _Debouncer(milliseconds: 500);
    Future.microtask(_loadClients);
  }

  Future<void> _loadClients() async {
    final user = ref.read(authUserProvider);
    final permission = user?.permission;
    final employeeId = user?.employee?.id ?? '';

    // Mismo criterio que ventas: filtra por empleado solo si el permiso lo
    // indica (filterCompany) y el usuario tiene un empleado asociado; en
    // cualquier otro caso trae todos los clientes.
    final filterByEmployee =
        permission?.filterCompany == true && employeeId.isNotEmpty;

    setState(() => _isLoading = true);
    await ref.read(companyProvider.notifier).loadCompanies(
          employeeId: filterByEmployee ? employeeId : null,
        );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _debouncer._timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                onChanged: (text) {
                  _debouncer.run(() {
                    ref.read(companyProvider.notifier).searchCompanies(text);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : companies.isEmpty
                      ? const Center(
                          child: Text('No se encontraron clientes'),
                        )
                      : ListView.builder(
                          itemCount: companies.length,
                          itemBuilder: (context, index) {
                            final company = companies[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                  horizontal: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  company.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: _buildSubtitle(company),
                                trailing: company.hasDiscount
                                    ? CompanyDiscountChip(
                                        percent: company.totalDiscount,
                                      )
                                    : const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditClientScreen(company: company),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(Company company) {
    final parts = <String>[];
    if (company.fantasyName != null && company.fantasyName!.isNotEmpty) {
      parts.add(company.fantasyName!);
    }
    if (company.identificationType?.name != null &&
        company.identificationValue != null) {
      parts.add(
        '${company.identificationType!.name}: ${company.identificationValue}',
      );
    }
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: const TextStyle(fontSize: 12),
    );
  }
}

class _Debouncer {
  _Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
