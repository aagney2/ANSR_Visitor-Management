import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/client_config.dart';

class AppTheme {
  final ClientConfig config;

  AppTheme(this.config);

  ThemeData get theme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: config.primaryColor,
      onPrimary: Colors.white,
      secondary: config.secondaryColor,
      onSecondary: Colors.white,
      tertiary: config.accentColor,
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
      surface: config.surfaceColor,
      onSurface: const Color(0xFF1C1B1F),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: config.backgroundColor,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: const Color(0xFF1C1B1F),
        displayColor: const Color(0xFF1C1B1F),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: config.primaryColor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: config.primaryColor, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: config.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF757575),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFFBDBDBD),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF0F0F0)),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return config.primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
