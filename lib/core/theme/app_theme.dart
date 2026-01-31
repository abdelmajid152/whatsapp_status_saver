import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Theme Configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.card,
        error: AppColors.destructive,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.secondaryForeground,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.secondaryForeground,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.workSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryForeground,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.secondaryForeground.withValues(
          alpha: 0.7,
        ),
        indicatorColor: AppColors.primaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 6,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: GoogleFonts.workSansTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
        contentTextStyle: GoogleFonts.workSans(
          color: AppColors.textLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.secondaryForeground,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.cardDark,
        error: AppColors.destructive,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textLight,
        onSurface: AppColors.textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.textLight,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.workSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textLight.withValues(alpha: 0.7),
        indicatorColor: AppColors.primaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 6,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme)
          .apply(
            bodyColor: AppColors.textLight,
            displayColor: AppColors.textLight,
          ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardDark,
        contentTextStyle: GoogleFonts.workSans(
          color: AppColors.textLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.textPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.textLight),
      ),
    );
  }
}
