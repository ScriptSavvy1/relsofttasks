import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';

class MeetingDetailScreen extends ConsumerWidget {
  final String meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

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
        title: const Text('Meeting Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/meetings/$meetingId/edit'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(context);
                case 'export':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export coming soon')),
                  );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Meeting')),
              const PopupMenuItem(value: 'export', child: Text('Export Notes')),
            ],
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: const Text('Are you sure you want to delete this meeting? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meeting deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting title & status
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
                      const StatusBadge(
                        label: 'Completed',
                        color: AppColors.success,
                        icon: Icons.check_circle_outline,
                      ),
                      const Spacer(),
                      Text(
                        'ID: ${meetingId.length >= 8 ? meetingId.substring(0, 8) : meetingId}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sprint Planning - Week 1',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _InfoRow(icon: Icons.schedule, label: 'Apr 6, 2026 • 10:00 AM'),
                  const SizedBox(height: AppSpacing.sm),
                  const _InfoRow(icon: Icons.business, label: 'Engineering'),
                  const SizedBox(height: AppSpacing.sm),
                  const _InfoRow(icon: Icons.person, label: 'Organized by Mohamed Ali'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Agenda
            _SectionCard(
              title: 'Agenda',
              icon: Icons.list_alt_rounded,
              child: Text(
                '1. Review backlog items\n2. Estimate story points\n3. Assign tasks\n4. Identify blockers',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                  height: 1.8,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Attendees
            const _SectionCard(
              title: 'Attendees (4)',
              icon: Icons.people_outlined,
              child: Column(
                children: [
                  _AttendeeTile(name: 'Mohamed Ali', role: 'Organizer', attended: true),
                  _AttendeeTile(name: 'Omar Ibrahim', role: 'Senior Developer', attended: true),
                  _AttendeeTile(name: 'Amina Khalil', role: 'Frontend Developer', attended: true),
                  _AttendeeTile(name: 'Yusuf Ahmed', role: 'UI Designer', attended: false),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Discussion Notes
            _SectionCard(
              title: 'Discussion Notes',
              icon: Icons.note_alt_outlined,
              child: Text(
                'Connect to Supabase to view meeting notes.\nNotes will appear here in chronological order.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Decisions
            _SectionCard(
              title: 'Decisions Made',
              icon: Icons.gavel_rounded,
              child: Text(
                'Connect to Supabase to view decisions.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action Items
            _SectionCard(
              title: 'Action Items',
              icon: Icons.checklist_rounded,
              actionLabel: 'Convert to Tasks',
              onAction: () {},
              child: Text(
                'Connect to Supabase to view action items.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkTextTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
              if (actionLabel != null) ...[
                const Spacer(),
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AttendeeTile extends StatelessWidget {
  final String name;
  final String role;
  final bool attended;

  const _AttendeeTile({
    required this.name,
    required this.role,
    required this.attended,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          AvatarCircle(name: name, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                Text(
                  role,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            attended ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: attended ? AppColors.success : AppColors.darkTextTertiary,
          ),
        ],
      ),
    );
  }
}
