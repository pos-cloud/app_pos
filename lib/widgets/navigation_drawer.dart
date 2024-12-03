import 'package:flutter/material.dart';
import 'package:app_pos/models/transaction_movement.dart';

class NavigationDrawerCustom extends StatelessWidget {
  final Function(TransactionMovement) onItemSelected;

  const NavigationDrawerCustom({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...TransactionMovement.values.map((movement) {
                  return ListTile(
                    title: Text(movement.name),
                    leading: _getIconForMovement(movement),
                    onTap: () => onItemSelected(movement),
                  );
                }).toList(),
                const Divider(), // Línea divisoria
                ListTile(
                  title: const Text("Report"),
                  leading: const Icon(Icons.assessment, size: 24),
                  onTap: () {
                    // Acción específica para Report
                    Navigator.of(context).pushNamed('/report');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Método para obtener íconos según el tipo de movimiento.
  Icon _getIconForMovement(TransactionMovement movement) {
    switch (movement) {
      case TransactionMovement.sale:
        return const Icon(Icons.shopping_cart, size: 24);
      case TransactionMovement.purchase:
        return const Icon(Icons.shopping_basket, size: 24);
      case TransactionMovement.stock:
        return const Icon(Icons.inventory, size: 24);
      case TransactionMovement.production:
        return const Icon(Icons.factory, size: 24);
      case TransactionMovement.money:
        return const Icon(Icons.account_balance_wallet, size: 24);
    }
  }
}
