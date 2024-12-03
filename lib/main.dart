import 'package:app_pos/screens/login_screen.dart';
import 'package:app_pos/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryLogoColor = Color(0xFF4A90E2);

    return MaterialApp(
      title: 'Flutter Demo',
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryLogoColor),
        useMaterial3: true,
      ),
      initialRoute: LoginScreen.path,
      routes: {
        LoginScreen.path: (context) => const LoginScreen(),
        MainScreen.path: (context) => const MainScreen(),
      },
    );
  }
}
