import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography system for Relsoft TeamFlow
class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Headings ──────────────────────────────────────────────
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Title ─────────────────────────────────────────────────
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ── Body ──────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Label ─────────────────────────────────────────────────
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ── Caption / Overline ────────────────────────────────────
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColors.darkTextTertiary,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.5,
  );

  // ── Button ────────────────────────────────────────────────
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.4,
  );
}
