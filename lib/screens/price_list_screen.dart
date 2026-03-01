import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/providers/price_list_provider.dart';

class PriceListScreen extends ConsumerWidget {
  static const path = '/price_list_screen';

  const PriceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceLists = ref.watch(priceListProvider);
    final selectedPriceList =
        ref.watch(globalTransactionProvider).transaction?.priceList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Lista de Precios'),
      ),
      body: priceLists.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: priceLists.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: Icon(
                      Icons.clear,
                      color: selectedPriceList == null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(
                      'Sin lista de precios',
                      style: TextStyle(
                        fontWeight: selectedPriceList == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        selectedPriceList == null
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () {
                      ref
                          .read(globalTransactionProvider.notifier)
                          .updatePriceList(null);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lista de precios quitada'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                  );
                }

                final priceList = priceLists[index - 1];
                final isSelected =
                    selectedPriceList?.id == priceList.id;

                return ListTile(
                  leading: Icon(
                    Icons.list_alt,
                    color:
                        isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(
                    priceList.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: priceList.percentage != 0
                      ? Text('${priceList.percentage}%')
                      : null,
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    ref
                        .read(globalTransactionProvider.notifier)
                        .updatePriceList(priceList);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Lista "${priceList.name}" seleccionada',
                        ),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
