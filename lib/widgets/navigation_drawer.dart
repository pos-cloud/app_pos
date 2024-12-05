import 'package:app_pos/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/models/transaction_movement.dart';

class NavigationDrawerCustom extends StatelessWidget {
  final Function(TransactionMovement) onItemSelected;

  const NavigationDrawerCustom({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Logo
          DrawerHeader(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centrado de los elementos
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Alineación centrada
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 50,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Franco Androetto', // Nombre del usuario hardcodeado
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Administrador', // Correo hardcodeado
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Contenido principal del Drawer (transacciones y reporte)
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
          // Línea divisoria antes de Cerrar sesión
          const Divider(),
          // Botón Cerrar sesión
          Consumer(
            builder: (context, ref, child) {
              return ListTile(
                title: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.red),
                ),
                leading: const Icon(Icons.logout, color: Colors.red, size: 24),
                onTap: () async {
                  final authNotifier = ref.read(authProvider.notifier);
                  await authNotifier.logout(ref);

                  // Redirigir al usuario al login y limpiar el stack de navegación
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login_screen', (route) => false);
                },
              );
            },
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
