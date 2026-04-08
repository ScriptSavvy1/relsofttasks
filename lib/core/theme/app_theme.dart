import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// ============================================================
/// Centralized theme for Relsoft TeamFlow
/// 
/// Light theme is PRIMARY (70% white, 20% blue, 10% accent).
/// Dark theme available but light is default per brand guide.
/// ============================================================
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════
  // LIGHT THEME (Primary — matches Relsoft brand guidelines)
  // ══════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,

      // ── Color Scheme ────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,          // #2F5EA8
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,      // #1F3F73
        onSecondary: Colors.white,
        tertiary: AppColors.accent,          // #D4AF37 Gold
        surface: AppColors.darkSurface,      // White
        onSurface: AppColors.darkTextPrimary, // #1F2937
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.darkBorder,
      ),

      scaffoldBackgroundColor: AppColors.darkBg, // #F5F7FA

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: AppSpacing.iconSize,
        ),
      ),

      // ── Bottom Navigation ───────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // ── NavigationBar (Material 3) ─────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: AppColors.darkTextTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppSpacing.iconSize,
            );
          }
          return const IconThemeData(
            color: AppColors.darkTextTertiary,
            size: AppSpacing.iconSize,
          );
        }),
      ),

      // ── Cards ───────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
      ),

      // ── Inputs ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant, // #F0F3F8
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.darkTextTertiary,
        suffixIconColor: AppColors.darkTextTertiary,
      ),

      // ── Elevated Button ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          side: const BorderSide(color: AppColors.darkBorder),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Chip ────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        disabledColor: AppColors.darkSurfaceVariant,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Divider ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ── Dialog ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // ── Bottom Sheet ────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),

      // ── Snackbar ────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Tab Bar ─────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkTextTertiary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),

      // ── Progress Indicator ──────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkSurfaceVariant,
        circularTrackColor: AppColors.darkSurfaceVariant,
      ),

      // ── Switch ──────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return AppColors.darkSurfaceVariant;
        }),
      ),

      // ── Popup Menu ──────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // ── ListTile ────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // ── Tooltip ─────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
        ),
      ),

      // ── Dropdown Menu ───────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DARK THEME (Secondary — uses same brand blues on dark bg)
  // ══════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,      // #4F7EDB lighter for dark mode
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: Color(0xFF111827),
        onSurface: Color(0xFFF1F5F9),
        error: AppColors.error,
        onError: Colors.white,
        outline: Color(0xFF2D3A4F),
      ),

      scaffoldBackgroundColor: const Color(0xFF0B0F19),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: const Color(0xFFF1F5F9),
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1A2332),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: Color(0xFF2D3A4F)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF2D3A4F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF2D3A4F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}
