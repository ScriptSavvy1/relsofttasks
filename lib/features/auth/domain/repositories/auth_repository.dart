import '../entities/user_profile.dart';

/// Repository interface for auth operations (domain layer contract)
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordReset(String email);

  /// Get the current authenticated user's profile
  Future<UserProfile?> getCurrentProfile();

  /// Update the current user's profile
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? jobTitle,
    String? avatarUrl,
  });

  /// Check if there is an active session
  bool get hasActiveSession;

  /// Get the current user ID
  String? get currentUserId;
}
