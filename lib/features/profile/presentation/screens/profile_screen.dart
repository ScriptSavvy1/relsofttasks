import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: authState.when(
          data: (profile) {
            if (profile == null) return const SizedBox.shrink();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Profile header
                  AvatarCircle(
                    name: profile.fullName,
                    imageUrl: profile.avatarUrl,
                    size: 80,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    profile.fullName,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    profile.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  StatusBadge(
                    label: profile.role.displayName,
                    color: AppColors.primary,
                  ),
                  if (profile.jobTitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      profile.jobTitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxxl),

                  // Menu items
                  _ProfileMenuItem(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.lock_outlined,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  if (profile.canManageUsers)
                    _ProfileMenuItem(
                      icon: Icons.people_outlined,
                      label: 'Staff Management',
                      onTap: () => context.push(RouteNames.users),
                    ),
                  if (profile.canViewAuditLogs)
                    _ProfileMenuItem(
                      icon: Icons.history_rounded,
                      label: 'Audit Logs',
                      onTap: () {},
                    ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push(RouteNames.settings),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Logout
                  SecondaryButton(
                    label: 'Sign Out',
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go(RouteNames.login);
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    'Relsoft TeamFlow v1.0.0',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(message: e.toString()),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        tileColor: AppColors.darkCard,
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 20, color: AppColors.darkTextSecondary),
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
