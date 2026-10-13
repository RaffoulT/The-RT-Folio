import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0D0E11);
  static const Color surface = Color(0xFF14171C);
  static const Color surfaceBorder = Color(0xFF242830);
  static const Color surfaceHighlight = Color(0xFF1E222A);
  
  static const Color textPrimary = Color(0xFFF5F3EF);
  static const Color textMuted = Color(0xFF9E988E);
  static const Color textSubtle = Color(0xFF6B665F);
  
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color warmRed = Color(0xFFE26D5C);
  static const Color fujiGreen = Color(0xFF4A7C59);

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: goldAccent,
        secondary: warmRed,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withValues(alpha: 0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceMono(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: surfaceBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: baseText.copyWith(
        headlineMedium: GoogleFonts.spaceMono(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        titleLarge: GoogleFonts.spaceMono(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}
