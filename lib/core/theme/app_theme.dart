import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Professional Palette
  static const Color primaryBlue = Color(0xFF2E86C1);
  static const Color accentOrange = Color(0xFFEB984E);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textDim = Color(0xFF64748B);
  static const Color borderSoft = Color(0xFFE2E8F0);
  
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static ThemeData get whiteProfessionalTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentOrange,
          surface: surfaceWhite,
          onSurface: textMain,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.lexend(color: textMain, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.lexend(color: textMain, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.lexend(color: textMain, fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.inter(color: textMain),
          bodyMedium: GoogleFonts.inter(color: textDim),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceWhite,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: textMain),
          titleTextStyle: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderSoft, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderSoft, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: textDim, fontSize: 14),
          prefixIconColor: textDim,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
}
