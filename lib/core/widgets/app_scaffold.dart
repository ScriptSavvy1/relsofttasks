import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Main app scaffold with bottom navigation bar
class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: RouteNames.dashboard,
    ),
    _NavItem(
      label: 'Meetings',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      route: RouteNames.meetings,
    ),
    _NavItem(
      label: 'My Tasks',
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt_rounded,
      route: RouteNames.myTasks,
    ),
    _NavItem(
      label: 'Alerts',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      route: RouteNames.notifications,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      route: RouteNames.profile,
    ),
  ];

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_navItems[index].route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync tab index with current route
    final location = GoRouterState.of(context).matchedLocation;
    final index = _navItems.indexWhere((item) => item.route == location);
    if (index != -1 && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.darkBorder.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => _onItemTapped(index),
                    child: AnimatedContainer(
                      duration: AppSpacing.animFast,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: AppSpacing.animFast,
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              key: ValueKey(isSelected),
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.darkTextTertiary,
                              size: AppSpacing.iconSize,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.darkTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
