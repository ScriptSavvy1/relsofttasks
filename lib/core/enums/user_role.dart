/// User roles in the Relsoft TeamFlow system.
/// Ordered from most privileged to least privileged.
enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  admin('admin', 'Admin'),
  teamLead('team_lead', 'Team Lead'),
  staff('staff', 'Staff');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Parse from database string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.staff,
    );
  }

  /// Whether this role can create meetings
  bool get canCreateMeetings =>
      this == superAdmin || this == admin || this == teamLead;

  /// Whether this role can assign tasks
  bool get canAssignTasks =>
      this == superAdmin || this == admin || this == teamLead;

  /// Whether this role can manage users
  bool get canManageUsers => this == superAdmin || this == admin;

  /// Whether this role can view all data
  bool get canViewAllData => this == superAdmin || this == admin;

  /// Whether this role can view audit logs
  bool get canViewAuditLogs => this == superAdmin || this == admin;

  /// Whether this role is admin-level
  bool get isAdmin => this == superAdmin || this == admin;

  /// Whether this role has department-scoped access only
  bool get isDepartmentScoped => this == teamLead;

  /// Privilege level (higher = more privileged)
  int get privilegeLevel {
    switch (this) {
      case superAdmin:
        return 4;
      case admin:
        return 3;
      case teamLead:
        return 2;
      case staff:
        return 1;
    }
  }
}
