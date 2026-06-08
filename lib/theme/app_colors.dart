import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand — light blue palette ────────────────────────────────────────────

  static const Color primary        = Color(0xFF2196F3); // Material Blue
  static const Color primaryLight   = Color(0xFF64B5F6); // Blue 300
  static const Color primaryDark    = Color(0xFF1565C0); // Blue 800

  static const Color secondary      = Color(0xFF00BCD4); // Cyan accent
  static const Color secondaryLight = Color(0xFF4DD0E1);
  static const Color secondaryDark  = Color(0xFF00838F);

  static const Color accent         = Color(0xFFFFB347); // warm orange (streak)

  // ── Neutrals ──────────────────────────────────────────────────────────────

  static const Color grey50         = Color(0xFFFAFAFA);
  static const Color grey100        = Color(0xFFF5F5F5);
  static const Color grey200        = Color(0xFFEEEEEE);
  static const Color grey400        = Color(0xFFBDBDBD);
  static const Color grey600        = Color(0xFF757575);
  static const Color grey800        = Color(0xFF424242);
  static const Color grey900        = Color(0xFF212121);

  // ── Semantic ──────────────────────────────────────────────────────────────

  static const Color success        = Color(0xFF4CAF50);
  static const Color warning        = Color(0xFFFFC107);
  static const Color error          = Color(0xFFEF5350);
  static const Color info           = Color(0xFF42A5F5);

  // ── Streak colors ─────────────────────────────────────────────────────────

  static const Color streakFire     = Color(0xFFFF6D00);
  static const Color streakGold     = Color(0xFFFFD600);

  // ── Light theme surfaces — white + light blue tint ────────────────────────

  static const Color lightBackground     = Color(0xFFF0F8FF); // Alice Blue
  static const Color lightSurface        = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE3F2FD); // Blue 50
  static const Color lightOnSurface      = Color(0xFF1A1A2E);

  // ── Dark theme surfaces ───────────────────────────────────────────────────

  static const Color darkBackground      = Color(0xFF0D1117);
  static const Color darkSurface         = Color(0xFF161B22);
  static const Color darkSurfaceVariant  = Color(0xFF21262D);
  static const Color darkOnSurface       = Color(0xFFE6EDF3);
}