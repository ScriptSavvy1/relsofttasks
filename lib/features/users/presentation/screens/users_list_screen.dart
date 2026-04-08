import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/enums/user_role.dart';

class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Staff Management'),
        actions: [
          GestureDetector(
            onTap: () => context.push('/users/invite'),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.lg),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Invite', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: _sampleUsers.length,
        itemBuilder: (context, index) {
          final user = _sampleUsers[index];
          return _UserCard(
            name: user['name']!,
            email: user['email']!,
            role: UserRole.fromString(user['role']!),
            department: user['department']!,
            isActive: user['active'] == 'true',
            onTap: () => context.push('/users/user-$index'),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 40 * index))
              .slideX(begin: 0.03, end: 0);
        },
      ),
    );
  }

  static const _sampleUsers = [
    {'name': 'Ahmed Hassan', 'email': 'ahmed@relsoft.com', 'role': 'super_admin', 'department': 'All', 'active': 'true'},
    {'name': 'Sarah Osman', 'email': 'sarah@relsoft.com', 'role': 'admin', 'department': 'Engineering', 'active': 'true'},
    {'name': 'Mohamed Ali', 'email': 'mohamed@relsoft.com', 'role': 'team_lead', 'department': 'Engineering', 'active': 'true'},
    {'name': 'Fatima Yusuf', 'email': 'fatima@relsoft.com', 'role': 'team_lead', 'department': 'Design', 'active': 'true'},
    {'name': 'Omar Ibrahim', 'email': 'omar@relsoft.com', 'role': 'staff', 'department': 'Engineering', 'active': 'true'},
    {'name': 'Amina Khalil', 'email': 'amina@relsoft.com', 'role': 'staff', 'department': 'Engineering', 'active': 'true'},
    {'name': 'Yusuf Ahmed', 'email': 'yusuf@relsoft.com', 'role': 'staff', 'department': 'Design', 'active': 'true'},
    {'name': 'Halima Abdi', 'email': 'halima@relsoft.com', 'role': 'staff', 'department': 'Product', 'active': 'false'},
  ];
}

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final bool isActive;
  final VoidCallback onTap;

  const _UserCard({
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isActive ? AppColors.darkBorder : AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                AvatarCircle(name: name, size: 44),
                if (!isActive)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkCard, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isActive ? AppColors.darkTextPrimary : AppColors.darkTextTertiary,
                        ),
                      ),
                      if (!isActive) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text('(Inactive)', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextTertiary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      StatusBadge(
                        label: role.displayName,
                        color: role.isAdmin ? AppColors.accent : AppColors.primary,
                        isSmall: true,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        department,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
          ],
        ),
      ),
    );
  }
}
