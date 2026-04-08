import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';

/// Supabase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException(
          message: 'Sign in failed. Please check your credentials.',
          code: 'SIGN_IN_FAILED',
        );
      }

      // Fetch the full profile
      final profile = await getCurrentProfile();
      if (profile == null) {
        throw const AppAuthException(
          message: 'User profile not found.',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      // Check if user is active
      if (!profile.isActive) {
        await _client.auth.signOut();
        throw const AppAuthException(
          message: 'Your account has been deactivated. Contact an administrator.',
          code: 'ACCOUNT_DEACTIVATED',
        );
      }

      // Update last seen
      await _client
          .from(SupabaseConstants.profilesTable)
          .update({'last_seen_at': DateTime.now().toIso8601String()})
          .eq('id', response.user!.id);

      return profile;
    } on AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      throw AppAuthException(
        message: _mapAuthError(e.message),
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'An unexpected error occurred during sign in.',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to sign out.',
        originalError: e,
      );
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AppAuthException(
        message: _mapAuthError(e.message),
        originalError: e,
      );
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to send password reset email.',
        originalError: e,
      );
    }
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return UserProfileModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? jobTitle,
    String? avatarUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const AppAuthException(
        message: 'Not authenticated.',
        code: 'NOT_AUTHENTICATED',
      );
    }

    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName.trim();
      if (phone != null) updates['phone'] = phone.trim();
      if (jobTitle != null) updates['job_title'] = jobTitle.trim();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) {
        final profile = await getCurrentProfile();
        return profile!;
      }

      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(data);
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to update profile.',
        originalError: e,
      );
    }
  }

  @override
  bool get hasActiveSession => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Map Supabase auth error messages to user-friendly messages
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (lower.contains('too many requests') ||
        lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email address.';
    }
    return message;
  }
}
