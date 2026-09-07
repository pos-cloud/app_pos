import 'dart:async';
import 'package:app_pos/providers/company_provider.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/widgets/company_discount_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  static String path = '/company_screen';
  const CompanyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  late final _Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = _Debouncer(milliseconds: 500);
  }

  @override
  void dispose() {
    _debouncer._timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companyProvider);
    final transactionCompany =
        ref.watch(globalTransactionProvider).transaction?.company;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Cliente'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cliente seleccionado (persistido en la transacción)
            if (transactionCompany != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber.shade100,
                      child: Icon(Icons.person, color: Colors.amber.shade800),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cliente seleccionado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            transactionCompany.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (transactionCompany.hasDiscount)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Descuento ${transactionCompany.totalDiscount.asPercent}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          if (transactionCompany.identificationType?.name !=
                                  null &&
                              transactionCompany.identificationValue != null)
                            Text(
                              '${transactionCompany.identificationType!.name}: ${transactionCompany.identificationValue}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                  ],
                ),
              ),
            ],
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                onChanged: (text) {
                  _debouncer.run(() {
                    // Llama al método de búsqueda en el provider
                    ref.read(companyProvider.notifier).searchCompanies(text);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            // Lista de clientes
            Expanded(
              child: companies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        final isSelected =
                            transactionCompany?.id == company.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 0.5),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 8),
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
                            subtitle:
                                company.identificationType?.name != null &&
                                        company.identificationValue != null
                                    ? Text(
                                        '${company.identificationType!.name}: ${company.identificationValue}',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (company.hasDiscount)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: CompanyDiscountChip(
                                      percent: company.totalDiscount,
                                    ),
                                  ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 28),
                              ],
                            ),
                            onTap: () {
                              // Actualizar la company en la transacción
                              ref
                                  .read(globalTransactionProvider.notifier)
                                  .updateCompany(company);

                              // Volver a la pantalla anterior
                              Navigator.pop(context);

                              final allowDiscount = ref
                                      .read(globalTransactionProvider)
                                      .transaction
                                      ?.type
                                      .allowCompanyDiscount ??
                                  true;
                              final appliedDiscount = allowDiscount &&
                                  company.hasDiscount;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appliedDiscount
                                        ? 'Cliente "${company.name}" seleccionado. Descuento ${company.totalDiscount.asPercent} aplicado.'
                                        : 'Cliente "${company.name}" seleccionado.',
                                  ),
                                  duration: Duration(
                                    milliseconds: appliedDiscount ? 1600 : 800,
                                  ),
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
