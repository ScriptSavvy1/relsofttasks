import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Mark all read',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'Today',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                _NotificationTile(
                  icon: Icons.add_task_rounded,
                  iconColor: AppColors.primary,
                  title: 'New task assigned',
                  body: 'Mohamed Ali assigned you "Implement user authentication flow"',
                  time: '2 hours ago',
                  isUnread: true,
                  onTap: () {},
                ).animate().fadeIn(duration: 300.ms),
                _NotificationTile(
                  icon: Icons.comment_rounded,
                  iconColor: AppColors.secondary,
                  title: 'New comment',
                  body: 'Mohamed Ali commented on "Implement user authentication flow"',
                  time: '3 hours ago',
                  isUnread: true,
                  onTap: () {},
                ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                _NotificationTile(
                  icon: Icons.event_rounded,
                  iconColor: AppColors.accent,
                  title: 'Meeting reminder',
                  body: 'Sprint Planning starts in 30 minutes',
                  time: '5 hours ago',
                  isUnread: false,
                  onTap: () {},
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              ]),
            ),

            // Earlier section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Earlier',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                _NotificationTile(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  title: 'Task completed',
                  body: 'Omar Ibrahim completed "Set up CI/CD pipeline"',
                  time: 'Yesterday',
                  isUnread: false,
                  onTap: () {},
                ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                _NotificationTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.warning,
                  title: 'Task overdue',
                  body: '"Write API documentation" is past its due date',
                  time: 'Yesterday',
                  isUnread: false,
                  onTap: () {},
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(time, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
