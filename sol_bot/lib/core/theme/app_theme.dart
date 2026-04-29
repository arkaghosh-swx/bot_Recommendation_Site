// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Backgrounds ───────────────────────────────────────────
  static const Color bg = Color(0xFF0E1A17);
  static const Color surface = Color(0xFF142420);
  static const Color surface2 = Color(0xFF182C27);
  static const Color surface3 = Color(0xFF1F3A33);

  // ── Borders ───────────────────────────────────────────────
  static const Color border = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color border2 = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)

  // ── Primary Accent (medical green) ───────────────────────
  static const Color accent = Color(0xFF3E7C6B);
  static const Color accentDim = Color(0x1F3E7C6B); // 12% opacity
  static const Color accentGlow = Color(0x403E7C6B); // 25%

  // ── Secondary ─────────────────────────────────────────────
  static const Color accentSoft = Color(0xFF8FB3A5);
  static const Color accentWa = Color(0xFF22C55E);

  // ── Gold CTA ──────────────────────────────────────────────
  static const Color gold = Color(0xFFC2A878);

  // ── Text ──────────────────────────────────────────────────
  static const Color text = Color(0xFFE6EFE9);
  static const Color text2 = Color(0xFF9FB3AB);

  // ── Status ────────────────────────────────────────────────
  static const Color green = Color(0xFF6AA895);
  static const Color red = Color(0xFFD66B6B);

  // ── Gradient ──────────────────────────────────────────────
  static const LinearGradient grad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E7C6B), Color(0xFF6AA895)],
  );

  static const LinearGradient gradWa = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E7C6B), Color(0xFF4F8F7E)],
  );

  // ── Bot avatar gradient ───────────────────────────────────
  static const LinearGradient botAvatarGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D7CFF), Color(0xFF9A5CFF)],
  );

  // ── Orb glows ─────────────────────────────────────────────
  static const Color orbBlue = Color(0xFF3B82F6);
  static const Color orbGreen = Color(0xFF22C55E);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentWa,
        surface: AppColors.surface,
        error: AppColors.red,
      ),
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: TextTheme(
        // Heading styles — Syne
        displayLarge: GoogleFonts.syne(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.syne(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          letterSpacing: -1.0,
        ),
        headlineLarge: GoogleFonts.syne(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineMedium: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineSmall: GoogleFonts.syne(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        titleLarge: GoogleFonts.syne(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        titleMedium: GoogleFonts.syne(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        // Body styles — DM Sans
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.text,
          height: 1.65,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.text,
          height: 1.65,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.text2,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.text2,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.text2,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Syne',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        iconTheme: IconThemeData(color: AppColors.text2),
      ),
      dividerColor: AppColors.border,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0x663B82F6), // rgba(59,130,246,0.4)
            width: 1.5,
          ),
        ),
        hintStyle: GoogleFonts.dmSans(fontSize: 14.5, color: AppColors.text2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.surface3),
        thickness: WidgetStateProperty.all(3),
        radius: const Radius.circular(2),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// ── Text style helpers ─────────────────────────────────────
class AppTextStyles {
  static TextStyle syne({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.text,
    double letterSpacing = 0,
    double height = 1.2,
  }) {
    return GoogleFonts.syne(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle dmSans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double height = 1.65,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}
