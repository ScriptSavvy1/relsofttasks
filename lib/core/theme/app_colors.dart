import 'package:flutter/material.dart';

/// ============================================================
/// Relsoft TeamFlow — Official Brand Colors
/// ============================================================
/// Usage ratio: 70% White/Light · 20% Primary Blue · 10% Accent
/// 
/// NOTE: Variable names like `darkBg`, `darkCard` etc. refer to
/// the app's "primary surface" colors (which are LIGHT in this
/// app). They are kept as-is to avoid refactoring all screens.
/// ============================================================
class AppColors {
  AppColors._();

  // ── Primary Brand Colors ──────────────────────────────────
  static const Color primary = Color(0xFF2F5EA8);           // Primary Blue
  static const Color primaryLight = Color(0xFF4F7EDB);       // Light Blue (accents)
  static const Color primaryDark = Color(0xFF1F3F73);        // Deep Blue (hover/nav)
  static const Color secondary = Color(0xFF1F3F73);          // Deep Blue
  static const Color secondaryLight = Color(0xFF6B8FCC);     // Lighter deep blue

  // ── Accent Colors ─────────────────────────────────────────
  static const Color accent = Color(0xFFD4AF37);             // Gold — premium feel
  static const Color accentTeal = Color(0xFF14B8A6);         // Teal — modern tech feel

  // ── App Surface Colors (Light Theme — 70% White) ──────────
  static const Color darkBg = Color(0xFFF5F7FA);             // Page background (light gray)
  static const Color darkSurface = Color(0xFFFFFFFF);         // Surface white
  static const Color darkSurfaceVariant = Color(0xFFF0F3F8);  // Elevated surface
  static const Color darkCard = Color(0xFFFFFFFF);            // Card background
  static const Color darkCardHover = Color(0xFFF0F4FA);       // Card hover
  static const Color darkBorder = Color(0xFFE2E8F0);          // Subtle border
  static const Color darkDivider = Color(0xFFE5E7EB);         // Divider

  // ── Light Theme Surface Colors (kept for reference) ───────
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F3F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ── Text Colors ───────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFF1F2937);     // Dark Gray — primary text
  static const Color darkTextSecondary = Color(0xFF6B7280);   // Medium Gray — secondary
  static const Color darkTextTertiary = Color(0xFF9CA3AF);    // Light gray — tertiary

  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // ── Status Colors ─────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);             // Green 500
  static const Color successBg = Color(0xFFE8F9EE);           // Light green bg
  static const Color warning = Color(0xFFF59E0B);             // Amber 500
  static const Color warningBg = Color(0xFFFFF8E1);           // Light amber bg
  static const Color error = Color(0xFFEF4444);               // Red 500
  static const Color errorBg = Color(0xFFFDE8E8);             // Light red bg
  static const Color info = Color(0xFF3B82F6);                // Blue 500
  static const Color infoBg = Color(0xFFE8F0FE);              // Light blue bg

  // ── Task Status Colors ────────────────────────────────────
  static const Color statusPending = Color(0xFF9CA3AF);       // Gray
  static const Color statusInProgress = Color(0xFF2F5EA8);    // Primary Blue
  static const Color statusBlocked = Color(0xFFEF4444);       // Red
  static const Color statusCompleted = Color(0xFF22C55E);     // Green
  static const Color statusCancelled = Color(0xFF6B7280);     // Medium Gray

  // ── Priority Colors ───────────────────────────────────────
  static const Color priorityLow = Color(0xFF6B7280);         // Gray
  static const Color priorityMedium = Color(0xFF2F5EA8);      // Primary Blue
  static const Color priorityHigh = Color(0xFFD4AF37);        // Gold
  static const Color priorityUrgent = Color(0xFFEF4444);      // Red

  // ── Gradient Definitions ──────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2F5EA8), Color(0xFF4F7EDB)],           // Primary → Light Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFEEF2F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1F3F73), Color(0xFF2F5EA8)],           // Deep Blue → Primary
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navGradient = LinearGradient(
    colors: [Color(0xFF1F3F73), Color(0xFF2F5EA8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFE8C84A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
