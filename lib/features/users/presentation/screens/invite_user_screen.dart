import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({super.key});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'staff';
  String _selectedDepartment = 'Engineering';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Call Vercel invite-user endpoint
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation sent!'), backgroundColor: AppColors.success),
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
        title: const Text('Invite Team Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text('Full Name *', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary)),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              validator: (v) => Validators.required(v, 'Name'),
              decoration: const InputDecoration(hintText: 'e.g., Ahmed Hassan', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Email *', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary)),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'user@relsoft.com', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Role *', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: ['staff', 'team_lead', 'admin']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.replaceAll('_', ' ').toUpperCase())))
                  .toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedRole = v); },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Department *', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartment,
              items: ['Engineering', 'Design', 'Product', 'Operations']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedDepartment = v); },
            ),
            const SizedBox(height: AppSpacing.xxxl),
            PrimaryButton(
              label: 'Send Invitation',
              isLoading: _isLoading,
              onPressed: _handleInvite,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
