import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/widgets/shared_widgets.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

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
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/tasks/$taskId/edit'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: const Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task deleted')),
                            );
                          },
                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                case 'reassign':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reassign coming soon')),
                  );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Task')),
              const PopupMenuItem(value: 'reassign', child: Text('Reassign')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Task Header ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge.fromTaskStatus(TaskStatus.inProgress),
                      const SizedBox(width: AppSpacing.sm),
                      StatusBadge.fromPriority(TaskPriority.high),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Implement user authentication flow',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Build complete login, signup, and password reset flows using Supabase Auth',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Status Actions ──────────────────────────
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
                  Text(
                    'Update Status',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: TaskStatus.values
                        .where((s) => s != TaskStatus.cancelled)
                        .map((status) {
                      final isActive = status == TaskStatus.inProgress;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () {
                              // TODO: update status via repository
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? status.color.withValues(alpha: 0.2)
                                    : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(
                                  color: isActive ? status.color : AppColors.darkBorder,
                                  width: isActive ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(status.icon, size: 16, color: status.color),
                                  const SizedBox(height: 2),
                                  Text(
                                    status.displayName,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                      color: isActive ? status.color : AppColors.darkTextTertiary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Details Grid ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Column(
                children: [
                  _DetailRow(label: 'Assigned To', value: 'Omar Ibrahim', icon: Icons.person_outline),
                  _DetailRow(label: 'Assigned By', value: 'Mohamed Ali', icon: Icons.assignment_ind_outlined),
                  _DetailRow(label: 'Department', value: 'Engineering', icon: Icons.business_rounded),
                  _DetailRow(label: 'Due Date', value: 'Apr 11, 2026', icon: Icons.event_rounded, valueColor: AppColors.warning),
                  _DetailRow(label: 'Created', value: 'Apr 1, 2026', icon: Icons.calendar_today_rounded),
                  _DetailRow(label: 'Related Meeting', value: 'Sprint Planning', icon: Icons.groups_rounded, isLink: true),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Comments Section ────────────────────────
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
                  Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Comments (2)',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _CommentTile(
                    author: 'Omar Ibrahim',
                    comment: 'Started working on the login screen. Email/password flow is complete.',
                    timeAgo: '2 hours ago',
                  ),
                  const Divider(height: AppSpacing.xxl),
                  const _CommentTile(
                    author: 'Mohamed Ali',
                    comment: 'Looks great! Please also add remember me functionality.',
                    timeAgo: '1 hour ago',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Add comment input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Activity Timeline ───────────────────────
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
                  Row(
                    children: [
                      const Icon(Icons.timeline_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Activity',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _TimelineTile(
                    label: 'Status changed to In Progress',
                    author: 'Omar Ibrahim',
                    timeAgo: '3 hours ago',
                    color: AppColors.statusInProgress,
                  ),
                  const _TimelineTile(
                    label: 'Task created',
                    author: 'Mohamed Ali',
                    timeAgo: '2 days ago',
                    color: AppColors.primary,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isLink;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.darkTextTertiary),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? (isLink ? AppColors.primary : AppColors.darkTextPrimary),
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String author;
  final String comment;
  final String timeAgo;

  const _CommentTile({
    required this.author,
    required this.comment,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarCircle(name: author, size: 30),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    author,
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.darkTextPrimary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(timeAgo, style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                comment,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String label;
  final String author;
  final String timeAgo;
  final Color color;
  final bool isLast;

  const _TimelineTile({
    required this.label,
    required this.author,
    required this.timeAgo,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1.5, color: AppColors.darkBorder),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary)),
                  Text('$author • $timeAgo', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
