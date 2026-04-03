import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/models/transaction_movement.dart';

class NavigationDrawerCustom extends ConsumerWidget {
  final Function(TransactionMovement) onItemSelected;

  const NavigationDrawerCustom({
    super.key,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final permissionName = user?.permissionName ?? '';

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
                Text(
                  (user?.name.trim().isNotEmpty == true)
                      ? user!.name
                      : 'Sin usuario',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (permissionName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    permissionName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Contenido principal del Drawer (transacciones y reporte)
          Expanded(
            child: ListView(
              children: [
                // ListTile(
                //   title: const Text("Pendientes"),
                //   leading: const Icon(Icons.assessment, size: 24),
                //   onTap: () {
                //     Navigator.of(context).pushNamed('/transactions');
                //   },
                // ),
                const Divider(),
                ListTile(
                  title: const Text('Venta'),
                  leading: _getIconForMovement(TransactionMovement.sale),
                  onTap: () => onItemSelected(TransactionMovement.sale),
                ),
                // Por ahora no se usa Compra.
                // ListTile(
                //   title: const Text('Compra'),
                //   leading: _getIconForMovement(TransactionMovement.purchase),
                //   onTap: () => onItemSelected(TransactionMovement.purchase),
                // ),
                const Divider(),
                // Por ahora no se usa Reportes.
                // ListTile(
                //   title: const Text('Reportes'),
                //   leading: const Icon(Icons.assessment, size: 24),
                //   onTap: () {
                //     Navigator.of(context).pushNamed('/report');
                //   },
                // ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("Configuración"),
            leading: const Icon(Icons.settings, size: 24),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(SettingsScreen.path);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.red),
            ),
            leading: const Icon(Icons.logout, color: Colors.red, size: 24),
            onTap: () async {
              final authNotifier = ref.read(authProvider.notifier);
              await authNotifier.logout(ref);

              // Redirigir al usuario al login y limpiar el stack de navegación
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login_screen', (route) => false);
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
      // case TransactionMovement.stock:
      //   return const Icon(Icons.inventory, size: 24);
      // case TransactionMovement.production:
      //   return const Icon(Icons.factory, size: 24);
      // case TransactionMovement.money:
      //   return const Icon(Icons.account_balance_wallet, size: 24);
    }
  }
}
