/// Supabase table and bucket name constants
/// Centralized to avoid typos and make refactoring easy
class SupabaseConstants {
  SupabaseConstants._();

  // ── Table Names ───────────────────────────────────────────
  static const String profilesTable = 'profiles';
  static const String departmentsTable = 'departments';
  static const String teamMembershipsTable = 'team_memberships';
  static const String meetingsTable = 'meetings';
  static const String meetingAttendeesTable = 'meeting_attendees';
  static const String meetingNotesTable = 'meeting_notes';
  static const String meetingDecisionsTable = 'meeting_decisions';
  static const String meetingActionItemsTable = 'meeting_action_items';
  static const String tasksTable = 'tasks';
  static const String taskCommentsTable = 'task_comments';
  static const String taskUpdatesTable = 'task_updates';
  static const String notificationsTable = 'notifications';
  static const String auditLogsTable = 'audit_logs';
  static const String fileAttachmentsTable = 'file_attachments';

  // ── Storage Buckets ───────────────────────────────────────
  static const String attachmentsBucket = 'attachments';
  static const String avatarsBucket = 'avatars';
}

/// General app constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Relsoft TeamFlow';
  static const String appVersion = '1.0.0';

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── File Upload ───────────────────────────────────────────
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxAvatarSize = 2 * 1024 * 1024; // 2MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv'];

  // ── Notification defaults ─────────────────────────────────
  static const int dueSoonHours = 24; // Notify 24 hours before due
}
