import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/enums/task_status.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../widgets/task_card.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text('All Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.taskCreate),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Row(
              children: ['All', 'Pending', 'In Progress', 'Blocked', 'Completed']
                  .map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.darkTextSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.darkBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Task list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              itemCount: 8,
              itemBuilder: (context, index) {
                final statuses = [
                  TaskStatus.inProgress, TaskStatus.pending, TaskStatus.blocked,
                  TaskStatus.completed, TaskStatus.inProgress, TaskStatus.pending,
                  TaskStatus.completed, TaskStatus.inProgress,
                ];
                final priorities = [
                  TaskPriority.high, TaskPriority.medium, TaskPriority.urgent,
                  TaskPriority.low, TaskPriority.high, TaskPriority.medium,
                  TaskPriority.low, TaskPriority.high,
                ];
                return TaskCard(
                  title: _sampleTitles[index % _sampleTitles.length],
                  assignedTo: _sampleNames[index % _sampleNames.length],
                  dueDate: 'Apr ${8 + index}, 2026',
                  status: statuses[index],
                  priority: priorities[index],
                  department: index.isEven ? 'Engineering' : 'Design',
                  onTap: () => context.push('/tasks/task-$index'),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 40 * index))
                    .slideX(begin: 0.03, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Filter Tasks', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.darkTextPrimary)),
            const SizedBox(height: AppSpacing.xxl),
            Text('Priority', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['All', 'Low', 'Medium', 'High', 'Urgent'].map((p) {
                final isSelected = _selectedPriority == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  onSelected: (_) => setState(() { _selectedPriority = p; Navigator.pop(context); }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  static const _sampleTitles = [
    'Implement user authentication flow',
    'Design task management screens',
    'Set up CI/CD pipeline',
    'Write API documentation',
    'Build dashboard analytics',
    'Create notification system',
    'Optimize database queries',
    'Mobile responsive layouts',
  ];

  static const _sampleNames = [
    'Omar Ibrahim', 'Yusuf Ahmed', 'Amina Khalil', 'Halima Abdi',
    'Mohamed Ali', 'Fatima Yusuf', 'Omar Ibrahim', 'Amina Khalil',
  ];
}

