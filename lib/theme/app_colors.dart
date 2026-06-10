import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF2979FF);
  static const Color primaryLight  = Color(0xFF82B1FF);
  static const Color primaryDark   = Color(0xFF0D47A1);

  static const Color secondary     = Color(0xFF00B0FF);
  static const Color secondaryLight= Color(0xFF80D8FF);
  static const Color accent        = Color(0xFFFFB300); // streak gold

  static const Color success       = Color(0xFF00C853);
  static const Color error         = Color(0xFFFF1744);

  // ── LIGHT palette — layered soft blues ────────────────────────────────────
  // bg → surface → card → elevated  (each step slightly more saturated)
  static const Color lightBg           = Color(0xFFECF4FF); // blue-50 tinted
  static const Color lightSurface      = Color(0xFFFFFFFF);
  static const Color lightCard         = Color(0xFFDEEAFF); // blue-100
  static const Color lightCardElevated = Color(0xFFC8DBFF); // blue-200
  static const Color lightOnSurface    = Color(0xFF0D2352);
  static const Color lightSubtle       = Color(0xFF5A7AB5);
  static const Color lightDivider      = Color(0xFFBDD4FF);

  // ── DARK palette — layered navy blues ─────────────────────────────────────
  // bg → surface → card → elevated  (each step lighter navy)
  static const Color darkBg            = Color(0xFF04091A); // deepest navy
  static const Color darkSurface       = Color(0xFF080F28); // navy
  static const Color darkCard          = Color(0xFF0E1A3D); // mid navy
  static const Color darkCardElevated  = Color(0xFF162550); // lighter navy
  static const Color darkAccent        = Color(0xFF1565C0); // blue accent
  static const Color darkOnSurface     = Color(0xFFD0E4FF); // light blue-white
  static const Color darkSubtle        = Color(0xFF5A80B8); // muted
  static const Color darkDivider       = Color(0xFF1A2E5A);

  // ── Ringing screen ────────────────────────────────────────────────────────
  static const Color ringingLight      = Color(0xFF1565C0); // medium vivid blue
  static const Color ringingDark       = Color(0xFF1A3A7A); // dark but visible blue
}