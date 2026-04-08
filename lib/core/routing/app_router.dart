import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/route_names.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/meetings/presentation/screens/meetings_list_screen.dart';
import '../../features/meetings/presentation/screens/meeting_detail_screen.dart';
import '../../features/meetings/presentation/screens/meeting_form_screen.dart';
import '../../features/tasks/presentation/screens/tasks_list_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/my_tasks_screen.dart';
import '../../features/tasks/presentation/screens/team_tasks_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/users/presentation/screens/users_list_screen.dart';
import '../../features/users/presentation/screens/user_detail_screen.dart';
import '../../features/users/presentation/screens/invite_user_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,

    // Redirect logic based on auth state
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.forgotPassword ||
          state.matchedLocation == RouteNames.splash;

      // If not logged in and not on auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return RouteNames.login;
      }

      // If logged in and on login page, redirect to dashboard
      if (isLoggedIn && state.matchedLocation == RouteNames.login) {
        return RouteNames.dashboard;
      }

      return null;
    },

    routes: [
      // ── Auth Routes (no shell) ─────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Main App Routes (with bottom nav shell) ────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.meetings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MeetingsListScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.myTasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyTasksScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.notifications,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Full-screen Routes (outside shell) ─────────────────
      GoRoute(
        path: '/meetings/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MeetingFormScreen(),
      ),
      GoRoute(
        path: '/meetings/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MeetingDetailScreen(
          meetingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/meetings/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MeetingFormScreen(
          meetingId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: RouteNames.tasks,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TasksListScreen(),
      ),
      GoRoute(
        path: '/tasks/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TaskDetailScreen(
          taskId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TaskFormScreen(
          taskId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: RouteNames.teamTasks,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TeamTasksScreen(),
      ),
      GoRoute(
        path: RouteNames.users,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: '/users/invite',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InviteUserScreen(),
      ),
      GoRoute(
        path: '/users/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => UserDetailScreen(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
