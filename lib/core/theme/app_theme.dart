import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const defaultPrimary = Color(0xFFFF007A);
  static const secondaryColor = Color(0xFFFF8FB1);
  static const backgroundLight = Color(0xFFFFFFFF);
  static const backgroundDark = Color(0xFF121212);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1E1E1E);

  static ThemeData light({Color primaryColor = defaultPrimary}) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardLight,
        onSurface: const Color(0xFF111111),
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
        headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF111111)),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF111111)),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF777777)),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: backgroundLight,
        foregroundColor: const Color(0xFF111111),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData dark({Color primaryColor = defaultPrimary}) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardDark,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: backgroundDark,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  static SystemUiOverlayStyle overlayStyle(bool darkMode) {
    return SystemUiOverlayStyle(
      statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
    );
  }
}
