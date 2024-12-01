import 'package:app_pos/routes/router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const Color primaryLogoColor =
        Color(0xFF4A90E2); // Reemplaza con el color de tu logo
    return MaterialApp.router(
      routerConfig: applicationRouter,
      title: 'Flutter Demo',
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryLogoColor),
        useMaterial3: true,
      ),
    );
  }
}
