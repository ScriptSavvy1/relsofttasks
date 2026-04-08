import '../../../../core/enums/user_role.dart';

/// Domain entity for user profile — pure Dart, no framework dependencies
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;
  final String? jobTitle;
  final bool isActive;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.jobTitle,
    this.isActive = true,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this user can perform an action based on role
  bool get canCreateMeetings => role.canCreateMeetings;
  bool get canAssignTasks => role.canAssignTasks;
  bool get canManageUsers => role.canManageUsers;
  bool get canViewAllData => role.canViewAllData;
  bool get canViewAuditLogs => role.canViewAuditLogs;
  bool get isAdmin => role.isAdmin;

  UserProfile copyWith({
    String? fullName,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? phone,
    String? jobTitle,
    bool? isActive,
    DateTime? lastSeenAt,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      isActive: isActive ?? this.isActive,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
