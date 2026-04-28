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
import '../../../auth/presentation/providers/auth_providers.dart';

class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  ConsumerState<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends ConsumerState<MeetingsListScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meetings',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        authState.whenOrNull(
                          data: (profile) {
                            if (profile?.canCreateMeetings ?? false) {
                              return _buildAddButton(context);
                            }
                            return null;
                          },
                        ) ?? const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: AppSpacing.md),

                    // Filter chips
                    _buildFilterChips(),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Meeting List ────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _MeetingCard(
                      title: 'Sprint Planning - Week ${index + 1}',
                      dateTime: 'Apr ${6 + index}, 2026 • 10:00 AM',
                      department: 'Engineering',
                      organizer: 'Mohamed Ali',
                      attendeeCount: 4 + index,
                      status: index == 0
                          ? MeetingStatus.scheduled
                          : index == 1
                              ? MeetingStatus.completed
                              : MeetingStatus.completed,
                      onTap: () => context.push('/meetings/meeting-$index'),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 50 * index),
                        )
                        .slideX(begin: 0.05, end: 0);
                  },
                  childCount: 5,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.huge),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.meetingCreate),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'New',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search meetings...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Scheduled', 'Completed', 'Cancelled'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundColor: AppColors.darkSurfaceVariant,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.darkTextSecondary,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.darkBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final String department;
  final String organizer;
  final int attendeeCount;
  final MeetingStatus status;
  final VoidCallback onTap;

  const _MeetingCard({
    required this.title,
    required this.dateTime,
    required this.department,
    required this.organizer,
    required this.attendeeCount,
    required this.status,
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
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                ),
                StatusBadge(
                  label: status.displayName,
                  color: status.color,
                  icon: status.icon,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.darkTextTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dateTime,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.business_rounded, size: 14, color: AppColors.darkTextTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  department,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                const Icon(Icons.person_outline, size: 14, color: AppColors.darkTextTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  organizer,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 14, color: AppColors.darkTextTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$attendeeCount attendees',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.darkTextTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
