import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── LIGHT ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary:              AppColors.primary,
      onPrimary:            Colors.white,
      primaryContainer:     AppColors.lightCard,
      onPrimaryContainer:   AppColors.primaryDark,
      secondary:            AppColors.secondary,
      onSecondary:          Colors.white,
      secondaryContainer:   AppColors.lightCardElevated,
      onSecondaryContainer: AppColors.primaryDark,
      surface:              AppColors.lightSurface,
      onSurface:            AppColors.lightOnSurface,
      surfaceContainerHighest: AppColors.lightCard,
      error:                AppColors.error,
      onError:              Colors.white,
      outline:              AppColors.lightDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.lightBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.lightOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.lightOnSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightDivider),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.lightSubtle),
        trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.lightCard),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.lightDivider),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.primary),

      textTheme: const TextTheme(
        displayLarge:   TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: AppColors.lightOnSurface),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightOnSurface),
        titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightOnSurface),
        bodyMedium:     TextStyle(fontSize: 14, color: AppColors.lightOnSurface),
        bodySmall:      TextStyle(fontSize: 12, color: AppColors.lightSubtle),
      ),
    );
  }

  // ── DARK ──────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary:              AppColors.primaryLight,
      onPrimary:            AppColors.darkBg,
      primaryContainer:     AppColors.darkCard,
      onPrimaryContainer:   AppColors.darkOnSurface,
      secondary:            AppColors.secondaryLight,
      onSecondary:          AppColors.darkBg,
      secondaryContainer:   AppColors.darkCardElevated,
      onSecondaryContainer: AppColors.darkOnSurface,
      surface:              AppColors.darkSurface,
      onSurface:            AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkCard,
      error:                AppColors.error,
      onError:              Colors.white,
      outline:              AppColors.darkDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.darkBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.darkOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkDivider),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.darkBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.darkBg,
        elevation: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.darkSubtle),
        trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.darkAccent
            : AppColors.darkCard),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.darkDivider),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.primaryLight),

      textTheme: const TextTheme(
        displayLarge:   TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: AppColors.darkOnSurface),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkOnSurface),
        titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkOnSurface),
        bodyMedium:     TextStyle(fontSize: 14, color: AppColors.darkOnSurface),
        bodySmall:      TextStyle(fontSize: 12, color: AppColors.darkSubtle),
      ),
    );
  }
}