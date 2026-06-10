import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand palette ─────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1E7BE0); // vivid blue
  static const Color primaryLight   = Color(0xFF5BA7F5); // lighter blue
  static const Color primaryDark    = Color(0xFF0D4F9A); // deep blue

  static const Color secondary      = Color(0xFF38BDF8); // sky blue
  static const Color secondaryLight = Color(0xFF7DD3FC);
  static const Color secondaryDark  = Color(0xFF0284C7);

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

  // ── Light theme — soft blue tones ─────────────────────────────────────────
  static const Color lightBackground     = Color(0xFFEFF6FF); // blue-50
  static const Color lightSurface        = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFDBEAFE); // blue-100
  static const Color lightCard           = Color(0xFFF0F9FF); // sky-50
  static const Color lightOnSurface      = Color(0xFF1E3A5F);

  // ── Dark theme — rich dark blue shades ────────────────────────────────────
  static const Color darkBackground      = Color(0xFF060E1C); // near-black navy
  static const Color darkSurface         = Color(0xFF0D1B35); // deep navy
  static const Color darkSurfaceVariant  = Color(0xFF152847); // navy card
  static const Color darkSurfaceElevated = Color(0xFF1A3258); // lighter navy
  static const Color darkAccentBlue      = Color(0xFF1D4ED8); // accent blue
  static const Color darkOnSurface       = Color(0xFFCBDCF8); // light blue-white
  static const Color darkSubtleText      = Color(0xFF6B90C4); // muted blue
}