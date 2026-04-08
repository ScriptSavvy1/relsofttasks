import '../../domain/entities/user_profile.dart';
import '../../../../core/enums/user_role.dart';

/// Data model for user profile — handles JSON serialization
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.avatarUrl,
    super.phone,
    super.jobTitle,
    super.isActive,
    super.lastSeenAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      jobTitle: json['job_title'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role.value,
      'avatar_url': avatarUrl,
      'phone': phone,
      'job_title': jobTitle,
      'is_active': isActive,
    };
  }

  /// Convert to update-only JSON (excludes read-only/protected fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'job_title': jobTitle,
      'avatar_url': avatarUrl,
    };
  }
}
