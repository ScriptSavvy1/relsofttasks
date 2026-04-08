import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Stat card for dashboard metrics
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconBgColor ?? AppColors.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Info card with title, content, and optional actions
class InfoCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;

  const InfoCard({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}
