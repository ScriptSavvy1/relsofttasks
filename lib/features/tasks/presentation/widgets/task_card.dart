import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/widgets/shared_widgets.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String assignedTo;
  final String dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final String department;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.department,
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
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge.fromPriority(priority),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge.fromTaskStatus(status),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.darkTextTertiary),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.darkTextPrimary,
                decoration: status == TaskStatus.completed ? TextDecoration.lineThrough : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                AvatarCircle(name: assignedTo, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    assignedTo,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.schedule_rounded, size: 13, color: AppColors.darkTextTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dueDate,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
