import 'package:app_pos/providers/theme_mode_provider.dart';
import 'package:app_pos/screens/clients_screen.dart';
import 'package:app_pos/screens/company_screen.dart';
import 'package:app_pos/screens/login_screen.dart';
import 'package:app_pos/screens/main_screen.dart';
import 'package:app_pos/screens/price_list_screen.dart';
import 'package:app_pos/screens/products_screen.dart';
import 'package:app_pos/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'styles/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Pos Cloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: LoginScreen.path,
      routes: {
        LoginScreen.path: (context) => const LoginScreen(),
        MainScreen.path: (context) => const MainScreen(),
        CompanyScreen.path: (context) => const CompanyScreen(),
        ClientsScreen.path: (context) => const ClientsScreen(),
        ProductsScreen.path: (context) => const ProductsScreen(),
        SettingsScreen.path: (context) => const SettingsScreen(),
        PriceListScreen.path: (context) => const PriceListScreen(),
      },
    );
  }
}
