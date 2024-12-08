import 'package:app_pos/screens/login_screen.dart';
import 'package:app_pos/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'styles/theme.dart'; // Asegúrate de importar tu archivo de tema

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pos Cloud',
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: LoginScreen.path,
      routes: {
        LoginScreen.path: (context) => const LoginScreen(),
        MainScreen.path: (context) => const MainScreen(),
      },
    );
  }
}
