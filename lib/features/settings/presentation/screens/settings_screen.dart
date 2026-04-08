import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              _SettingsTile(
                icon: Icons.text_fields_rounded,
                title: 'Text Size',
                subtitle: 'Medium',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                trailing: Switch(value: false, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.alarm_outlined,
                title: 'Due Date Reminders',
                subtitle: '24 hours before',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsSection(
            title: 'About',
            children: [
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                subtitle: '1.0.0 (Build 1)',
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextTertiary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.darkTextSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: trailing ?? (onTap != null
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary)
          : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }
}
