import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(
            _emailController.text.trim(),
          );
      setState(() => _emailSent = true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: _emailSent ? _buildSuccessState() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Reset Password',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.darkTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enter your email and we\'ll send you a link to reset your password.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                Text(
                  'Email',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    hintText: 'you@relsoft.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: 'Send Reset Link',
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  icon: Icons.send_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 36,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Check Your Email',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.darkTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        PrimaryButton(
          label: 'Back to Login',
          onPressed: () => context.pop(),
          icon: Icons.arrow_back_rounded,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
