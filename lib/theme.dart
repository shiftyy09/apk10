import 'package:flutter/material.dart';

// Erőteljes, modern férfias színpaletta

const Color primaryPurple = Color(0xFFFF383B);    // fő szín: energikus piros (ne használj lila szót a dizájnban, csak a kompatibilitás miatt maradt ez a név)
const Color accentPink = Color(0xFFFF383B);       // narancsos akcentus
const Color gradientStart = Color(0xFF151515);    // fő háttér
const Color gradientEnd = Color(0xFF151515);      // szürkésebb háttér (pl. card dobozok)
const Color cardBackground = Color(0xFF545454);
const Color lightPurple = Color(0xFF545454);      // halványszürke háttér elem
const Color darkPurple = Color(0xFF191919);       // nagyon sötét területekre
const Color lightGray = Color(0xFF26282B);        // kiegészítő világosszürke
const Color darkGray = Color(0xFFF5F5F5);         // világos szöveg

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: gradientStart,
    colorScheme: ColorScheme.dark(
      primary: primaryPurple,
      secondary: accentPink,
      background: gradientStart,
      surface: cardBackground,
      onPrimary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: cardBackground,
      elevation: 10,
      shadowColor: lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryPurple),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: gradientStart,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  );
}
