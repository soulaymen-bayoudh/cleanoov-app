import 'package:flutter/material.dart';

// Charte graphique officielle Cleanoov
// Source: cleanoov.com — CLE(noir) + NOOV(vert) + icône solaire
class AppColors {
  // Couleurs Cleanoov officielles
  static const Color cleanoovGreen = Color(0xFF22A353);      // Vert NOOV
  static const Color cleanoovGreenLight = Color(0xFF2ECC71); // Sparkles/accents
  static const Color cleanoovDark = Color(0xFF0A0A0A);       // Noir CLE
  static const Color cleanoovNavy = Color(0xFF0A0E1A);       // Fond hero site
  static const Color cleanoovNavyMid = Color(0xFF111827);    // Fond secondaire

  // Alias utilisés dans l'app
  static const Color primary = cleanoovNavy;
  static const Color accent = cleanoovGreen;
  static const Color accentLight = cleanoovGreenLight;
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Sections fiche diagnostic
  static const Color sectionBefore = Color(0xFFDC2626);
  static const Color sectionCleaning = cleanoovGreen;
  static const Color sectionAfter = cleanoovNavy;
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cleanoovGreen,
          primary: AppColors.cleanoovNavy,
          secondary: AppColors.cleanoovGreen,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cleanoovNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cleanoovGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.cleanoovGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),
      );
}
