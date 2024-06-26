import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Map<int, Color> orange = const <int, Color>{
    50: const Color(0xFFFCF2E7),
    100: const Color(0xFFF8DEC3),
    200: const Color(0xFFF3C89C),
    300: const Color(0xFFEEB274),
    400: const Color(0xFFEAA256),
    500: const Color(0xFFE69138),
    600: const Color(0xFFE38932),
    700: const Color(0xFFDF7E2B),
    800: const Color(0xFFDB7424),
    900: const Color(0xFFD56217)
  };

  static const Map<int, Color> digital = const <int, Color>{
    50: const Color(0xFFFCF2E7),
    100: const Color(0xFFF8DEC3),
    200: const Color(0xFFF3C89C),
    300: const Color(0xFFEEB274),
    400: const Color(0xFFEAA256),
    500: const Color(0xFFE64B44),
    600: const Color(0xFFE38932),
    700: const Color(0xFFDF7E2B),
    800: const Color(0xFFDB7424),
    900: const Color(0xFFD56217)
  };
}

class FontFamily {
  FontFamily._();

  static String productSans = "ProductSans";
  static String roboto = "Roboto";
}

final ThemeData themeData = new ThemeData(
  fontFamily: FontFamily.productSans,
  brightness: Brightness.light,
  primarySwatch: MaterialColor(AppColors.digital[500].value, AppColors.digital),
  primaryColor: AppColors.digital[500],
  primaryColorBrightness: Brightness.light,
  accentColor: AppColors.digital[500],
  accentColorBrightness: Brightness.light,
  // appBar title
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Colors.white),
  ),
  // drawer's icon
  primaryIconTheme: IconThemeData(color: Colors.white),
);

final ThemeData themeDataDark = ThemeData(
  fontFamily: FontFamily.productSans,
  brightness: Brightness.dark,
  primaryColor: AppColors.digital[500],
  primaryColorBrightness: Brightness.dark,
  accentColor: AppColors.digital[500],
  accentColorBrightness: Brightness.dark,
);
