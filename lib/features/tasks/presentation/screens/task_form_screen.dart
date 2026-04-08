import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;
  const TaskFormScreen({super.key, this.taskId});
  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';
  String _selectedDepartment = 'Engineering';
  String? _selectedAssignee;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Task updated' : 'Task created'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _buildLabel('Title *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _titleController,
              validator: (v) => Validators.required(v, 'Title'),
              decoration: const InputDecoration(hintText: 'e.g., Implement login flow'),
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('Description'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Detailed description of the task...'),
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('Assign To'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedAssignee,
              decoration: const InputDecoration(hintText: 'Select team member'),
              items: ['Omar Ibrahim', 'Amina Khalil', 'Yusuf Ahmed', 'Halima Abdi']
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedAssignee = v),
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('Department'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartment,
              items: ['Engineering', 'Design', 'Product', 'Operations']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedDepartment = v); },
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Priority *'),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        items: ['low', 'medium', 'high', 'urgent']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                            .toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedPriority = v); },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Due Date'),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: _selectDueDate,
                        child: Container(
                          height: AppSpacing.inputHeight,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded, size: 18, color: AppColors.darkTextTertiary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _dueDate != null
                                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                    : 'Select date',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _dueDate != null ? AppColors.darkTextPrimary : AppColors.darkTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),

            PrimaryButton(
              label: widget.isEditing ? 'Update Task' : 'Create Task',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
              icon: widget.isEditing ? Icons.save_rounded : Icons.add_task_rounded,
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary));
  }
}
