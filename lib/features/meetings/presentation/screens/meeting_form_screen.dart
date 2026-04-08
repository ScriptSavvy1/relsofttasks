import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons.dart';

class MeetingFormScreen extends ConsumerStatefulWidget {
  final String? meetingId;

  const MeetingFormScreen({super.key, this.meetingId});

  bool get isEditing => meetingId != null;

  @override
  ConsumerState<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends ConsumerState<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _agendaController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedDepartment = 'Engineering';
  String _selectedType = 'general';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _agendaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement save via repository
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Meeting updated successfully' : 'Meeting created successfully',
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEditing ? 'Edit Meeting' : 'New Meeting'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Title
            _buildLabel('Title *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _titleController,
              validator: (v) => Validators.required(v, 'Title'),
              decoration: const InputDecoration(hintText: 'e.g., Sprint Planning - Week 5'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Description
            _buildLabel('Description'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Brief description of the meeting...'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date *'),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: _selectDate,
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
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.darkTextTertiary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Time *'),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: _selectTime,
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
                              const Icon(Icons.access_time_rounded, size: 18, color: AppColors.darkTextTertiary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _selectedTime.format(context),
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
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

            const SizedBox(height: AppSpacing.xl),

            // Department
            _buildLabel('Department *'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartment,
              decoration: const InputDecoration(),
              items: ['Engineering', 'Design', 'Product', 'Operations']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedDepartment = value);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Meeting Type
            _buildLabel('Meeting Type'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(),
              items: [
                'general', 'standup', 'sprint_review',
                'retrospective', 'planning', 'one_on_one', 'workshop', 'other'
              ].map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.replaceAll('_', ' ').toUpperCase()),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Location
            _buildLabel('Location'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'e.g., Conference Room A / Zoom link'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Agenda
            _buildLabel('Agenda'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _agendaController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '1. First agenda item\n2. Second agenda item\n3. ...',
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            PrimaryButton(
              label: widget.isEditing ? 'Update Meeting' : 'Create Meeting',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
              icon: widget.isEditing ? Icons.save_rounded : Icons.add_rounded,
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),
    );
  }
}
