/// Named route paths for GoRouter
class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // ── Main App ──────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ── Meetings ──────────────────────────────────────────────
  static const String meetings = '/meetings';
  static const String meetingDetail = '/meetings/:id';
  static const String meetingCreate = '/meetings/create';
  static const String meetingEdit = '/meetings/:id/edit';

  // ── Tasks ─────────────────────────────────────────────────
  static const String tasks = '/tasks';
  static const String myTasks = '/my-tasks';
  static const String teamTasks = '/team-tasks';
  static const String taskDetail = '/tasks/:id';
  static const String taskCreate = '/tasks/create';
  static const String taskEdit = '/tasks/:id/edit';

  // ── Notifications ─────────────────────────────────────────
  static const String notifications = '/notifications';

  // ── Users ─────────────────────────────────────────────────
  static const String users = '/users';
  static const String userDetail = '/users/:id';
  static const String inviteUser = '/users/invite';

  // ── Profile & Settings ────────────────────────────────────
  static const String profile = '/profile';
  static const String settings = '/settings';

  // ── Audit Logs ────────────────────────────────────────────
  static const String auditLogs = '/audit-logs';
}
