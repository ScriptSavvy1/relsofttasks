import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: authState.when(
          data: (profile) {
            if (profile == null) return const SizedBox.shrink();
            return CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeader(context, profile.fullName, profile.role.displayName)
                      .animate()
                      .fadeIn(duration: 500.ms),
                ),

                // ── Stats Grid ──────────────────────────────
                SliverToBoxAdapter(
                  child: _buildStatsGrid(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.05, end: 0),
                ),

                // ── Quick Actions ───────────────────────────
                if (profile.canCreateMeetings || profile.canAssignTasks)
                  SliverToBoxAdapter(
                    child: _buildQuickActions(context, profile)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms),
                  ),

                // ── Recent Activity ─────────────────────────
                SliverToBoxAdapter(
                  child: _buildRecentActivity(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms),
                ),

                // ── Overdue Tasks ───────────────────────────
                SliverToBoxAdapter(
                  child: _buildOverdueTasks(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.huge),
                ),
              ],
            );
          },
          loading: () => const LoadingIndicator(message: 'Loading dashboard...'),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(authControllerProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String role) {
    final greeting = _getGreeting();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    role,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          IconButton(
            onPressed: () => context.push(RouteNames.notifications),
            icon: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkTextSecondary,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkSurfaceVariant,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        children: [
          StatCard(
            title: 'Active Tasks',
            value: '--',
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.statusInProgress,
            iconBgColor: AppColors.statusInProgress,
            subtitle: 'Across all teams',
            onTap: () => context.push(RouteNames.tasks),
          ),
          const StatCard(
            title: 'Overdue',
            value: '--',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.error,
            iconBgColor: AppColors.error,
            subtitle: 'Needs attention',
          ),
          StatCard(
            title: 'Meetings',
            value: '--',
            icon: Icons.groups_rounded,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondary,
            subtitle: 'This week',
            onTap: () => context.push(RouteNames.meetings),
          ),
          const StatCard(
            title: 'Completed',
            value: '--',
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            iconBgColor: AppColors.success,
            subtitle: 'This month',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (profile.canCreateMeetings)
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_rounded,
                    label: 'New Meeting',
                    color: AppColors.secondary,
                    onTap: () => context.push(RouteNames.meetingCreate),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              if (profile.canAssignTasks)
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_task_rounded,
                    label: 'New Task',
                    color: AppColors.primary,
                    onTap: () => context.push(RouteNames.taskCreate),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people_rounded,
                  label: 'Team',
                  color: AppColors.accent,
                  onTap: () => context.push(RouteNames.users),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: InfoCard(
        title: 'Recent Activity',
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'View All',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        child: const Column(
          children: [
            _ActivityTile(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              title: 'Task completed',
              subtitle: 'Loading recent activities...',
              timeAgo: '--',
            ),
            Divider(height: 1),
            _ActivityTile(
              icon: Icons.groups_outlined,
              iconColor: AppColors.secondary,
              title: 'Meeting scheduled',
              subtitle: 'Connect to Supabase to see live data',
              timeAgo: '--',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueTasks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: InfoCard(
        title: 'Overdue Tasks',
        actions: [
          TextButton(
            onPressed: () => context.push(RouteNames.tasks),
            child: Text(
              'View All',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        child: const EmptyState(
          icon: Icons.check_circle_outline,
          title: 'No overdue tasks',
          subtitle: 'Great job! All tasks are on track.',
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeAgo;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
