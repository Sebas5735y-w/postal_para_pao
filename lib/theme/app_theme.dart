import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "Correo Antiguo" — inspirada en cartas viejas, sellos postales,
/// tinta desvanecida y papel kraft. Nada de rosa/blush ni starfield:
/// esto se siente a oficina de correos de los años 40.
class AppColors {
  static const kraftPaper = Color(0xFFE4D5B7); // papel kraft claro (fondo)
  static const kraftPaperDark = Color(0xFFD3BE93); // sombra de papel
  static const inkNavy = Color(0xFF2B3A4A); // tinta azul marino
  static const terracotta = Color(0xFFC1613C); // sello postal / acentos
  static const rust = Color(0xFF9C4221); // sello de cera
  static const mustard = Color(0xFFD4A24C); // estampillas
  static const forest = Color(0xFF3F5443); // detalles verdes vintage
  static const cream = Color(0xFFF3E9D2); // tarjetas / postales
  static const fadedBrown = Color(0xFF6B4F3B); // texto secundario
  static const stampBorder = Color(0xFFB08D57);
}

class AppTheme {
  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: AppColors.inkNavy,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w600,
          color: AppColors.inkNavy,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w600,
          color: AppColors.inkNavy,
        ),
        titleLarge: GoogleFonts.specialElite(
          color: AppColors.rust,
          letterSpacing: 0.5,
        ),
        bodyLarge: GoogleFonts.specialElite(
          color: AppColors.inkNavy,
          fontSize: 17,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.specialElite(
          color: AppColors.fadedBrown,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.specialElite(
          color: AppColors.cream,
          letterSpacing: 1.1,
        ),
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.kraftPaper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.terracotta,
          primary: AppColors.terracotta,
          secondary: AppColors.mustard,
          surface: AppColors.cream,
        ),
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.kraftPaper,
          elevation: 0,
          foregroundColor: AppColors.inkNavy,
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: AppColors.inkNavy,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rust,
            foregroundColor: AppColors.cream,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: GoogleFonts.specialElite(letterSpacing: 1),
          ),
        ),
      );
}
