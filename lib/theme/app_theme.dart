import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Light theme — white + light blue ─────────────────────────────────────

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary:          AppColors.primary,
      onPrimary:        Colors.white,
      primaryContainer: AppColors.lightSurfaceVariant,
      onPrimaryContainer: AppColors.primaryDark,
      secondary:        AppColors.secondary,
      onSecondary:      Colors.white,
      secondaryContainer: Color(0xFFB2EBF2),
      onSecondaryContainer: AppColors.secondaryDark,
      surface:          AppColors.lightSurface,
      onSurface:        AppColors.lightOnSurface,
      error:            AppColors.error,
      onError:          Colors.white,
      outline:          AppColors.grey400,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.lightOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.lightOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.grey200),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.grey400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryLight
              : AppColors.grey200,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
      ),

      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.bold,  color: AppColors.lightOnSurface),
        headlineMedium:TextStyle(fontSize: 28, fontWeight: FontWeight.bold,  color: AppColors.lightOnSurface),
        titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600,  color: AppColors.lightOnSurface),
        bodyMedium:    TextStyle(fontSize: 14,                               color: AppColors.grey800),
        bodySmall:     TextStyle(fontSize: 12,                               color: AppColors.grey600),
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary:          AppColors.primaryLight,
      onPrimary:        AppColors.darkBackground,
      primaryContainer: Color(0xFF1565C0),
      onPrimaryContainer: Colors.white,
      secondary:        AppColors.secondaryLight,
      onSecondary:      AppColors.darkBackground,
      secondaryContainer: Color(0xFF006064),
      onSecondaryContainer: Colors.white,
      surface:          AppColors.darkSurface,
      onSurface:        AppColors.darkOnSurface,
      error:            AppColors.error,
      onError:          Colors.white,
      outline:          Color(0xFF30363D),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.darkOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.darkBackground,
        elevation: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryLight
              : AppColors.grey600,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.darkSurfaceVariant,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primaryLight,
      ),

      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: AppColors.darkOnSurface),
        headlineMedium:TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkOnSurface),
        titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkOnSurface),
        bodyMedium:    TextStyle(fontSize: 14,                              color: Color(0xFFB1BAC4)),
        bodySmall:     TextStyle(fontSize: 12,                              color: Color(0xFF8B949E)),
      ),
    );
  }
}
