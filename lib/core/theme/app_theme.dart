import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 232, 233, 235),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 251, 252, 252),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black), // modern replacement
          bodySmall: TextStyle(color: Colors.black54), // modern replacement
        ),
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}