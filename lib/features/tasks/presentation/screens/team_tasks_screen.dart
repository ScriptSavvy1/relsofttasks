import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/enums/task_status.dart';
import 'tasks_list_screen.dart';

class TeamTasksScreen extends ConsumerWidget {
  const TeamTasksScreen({super.key});

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
        title: const Text('Team Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 6,
        itemBuilder: (context, index) {
          final statuses = [
            TaskStatus.inProgress, TaskStatus.pending, TaskStatus.blocked,
            TaskStatus.completed, TaskStatus.inProgress, TaskStatus.pending,
          ];
          final names = [
            'Omar Ibrahim', 'Amina Khalil', 'Yusuf Ahmed',
            'Halima Abdi', 'Omar Ibrahim', 'Amina Khalil',
          ];
          return TaskCard(
            title: 'Team task #${index + 1}',
            assignedTo: names[index],
            dueDate: 'Apr ${10 + index}, 2026',
            status: statuses[index],
            priority: TaskPriority.values[index % TaskPriority.values.length],
            department: 'Engineering',
            onTap: () => context.push('/tasks/team-$index'),
          );
        },
      ),
    );
  }
}
