import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('User Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                children: [
                  const AvatarCircle(name: 'Omar Ibrahim', size: 64),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Omar Ibrahim', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkTextPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('omar@relsoft.com', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  const StatusBadge(label: 'Staff', color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Senior Developer • Engineering', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Task stats
            const Row(
              children: [
                _StatTile(count: '5', label: 'Active Tasks', color: AppColors.statusInProgress),
                SizedBox(width: AppSpacing.md),
                _StatTile(count: '12', label: 'Completed', color: AppColors.success),
                SizedBox(width: AppSpacing.md),
                _StatTile(count: '1', label: 'Overdue', color: AppColors.error),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Recent tasks
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Tasks', style: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Connect to Supabase to view user tasks.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  const _StatTile({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(count, style: AppTextStyles.headlineMedium.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
