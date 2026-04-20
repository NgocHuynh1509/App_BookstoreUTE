import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminColors {
  static const primary = Color(0xFF0D5CB6);
  static const secondary = Color(0xFF1A94FF);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F4FF);
  static const border = Color(0xFFE3E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

class AdminTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AdminColors.primary,
        onPrimary: Colors.white,
        secondary: AdminColors.secondary,
        onSecondary: Colors.white,
        error: AdminColors.danger,
        onError: Colors.white,
        background: AdminColors.background,
        onBackground: AdminColors.textPrimary,
        surface: AdminColors.surface,
        onSurface: AdminColors.textPrimary,
      ),
      scaffoldBackgroundColor: AdminColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.beVietnamProTextTheme(base.textTheme).apply(
        bodyColor: AdminColors.textPrimary,
        displayColor: AdminColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.surface,
        foregroundColor: AdminColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AdminColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AdminColors.secondary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AdminColors.surface,
        selectedColor: AdminColors.secondary.withOpacity(0.12),
        secondarySelectedColor: AdminColors.secondary.withOpacity(0.12),
        labelStyle: const TextStyle(color: AdminColors.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AdminColors.surface,
        indicatorColor: AdminColors.secondary.withOpacity(0.12),
        selectedIconTheme: const IconThemeData(color: AdminColors.primary),
        selectedLabelTextStyle: const TextStyle(
          color: AdminColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedIconTheme: const IconThemeData(color: AdminColors.textSecondary),
        unselectedLabelTextStyle: const TextStyle(color: AdminColors.textSecondary),
        labelType: NavigationRailLabelType.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AdminColors.surface,
        indicatorColor: AdminColors.secondary.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dividerTheme: const DividerThemeData(color: AdminColors.border, thickness: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      textTheme: GoogleFonts.beVietnamProTextTheme(base.textTheme),
    );
  }
}
