import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales extraídos del logo
  static const Color primaryColor = Color(0xFF0275D8); // Azul intenso
  static const Color secondaryColor = Color(0xFFE8F1F8); // Azul claro pastel
  static const Color backgroundColorLight = Color(0xFFFFFFFF); // Blanco
  static const Color backgroundColorDark =
      Color(0xFF201C1C); // Gris oscuro cálido

  // static const Color backgroundColorDark =
  //     Color(0xFF28242C); // Gris oscuro con toque violeta

  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColorLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // Tema oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColorDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}
