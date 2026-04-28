import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/task_status.dart';
import '../widgets/task_card.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tasks',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tasks assigned to you',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Summary Cards ───────────────────────────
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Row(
                  children: [
                    _MiniStatCard(count: '--', label: 'Active', color: AppColors.statusInProgress),
                    SizedBox(width: AppSpacing.md),
                    _MiniStatCard(count: '--', label: 'Overdue', color: AppColors.error),
                    SizedBox(width: AppSpacing.md),
                    _MiniStatCard(count: '--', label: 'Done', color: AppColors.success),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ── Task Sections ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Text(
                  'In Progress',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TaskCard(
                    title: 'Implement user authentication flow',
                    assignedTo: 'You',
                    dueDate: 'Apr ${8 + index}, 2026',
                    status: TaskStatus.inProgress,
                    priority: TaskPriority.high,
                    department: 'Engineering',
                    onTap: () => context.push('/tasks/my-task-$index'),
                  ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index)),
                  childCount: 2,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Text(
                  'Pending',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TaskCard(
                    title: 'Write API documentation',
                    assignedTo: 'You',
                    dueDate: 'Apr 20, 2026',
                    status: TaskStatus.pending,
                    priority: TaskPriority.low,
                    department: 'Engineering',
                    onTap: () => context.push('/tasks/pending-$index'),
                  ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index)),
                  childCount: 1,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _MiniStatCard({required this.count, required this.label, required this.color});

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
            Text(
              count,
              style: AppTextStyles.headlineMedium.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
