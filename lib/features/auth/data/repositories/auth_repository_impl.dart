import 'package:flutter/foundation.dart';
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
      // STEP 1: Auth sign-in
      debugPrint('[AUTH] Step 1: Attempting signInWithPassword for $email');
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AUTH] Step 1 SUCCESS: userId=${response.user?.id}');

      if (response.user == null) {
        throw const AppAuthException(
          message: 'Sign in failed. Please check your credentials.',
          code: 'SIGN_IN_FAILED',
        );
      }

      // STEP 2: Fetch profile
      debugPrint('[AUTH] Step 2: Fetching profile for userId=${response.user!.id}');
      final profile = await getCurrentProfile();
      debugPrint('[AUTH] Step 2 result: profile=${profile?.fullName ?? "NULL"}');
      if (profile == null) {
        throw const AppAuthException(
          message: 'User profile not found.',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      // STEP 3: Check active
      debugPrint('[AUTH] Step 3: Checking isActive=${profile.isActive}');
      if (!profile.isActive) {
        await _client.auth.signOut();
        throw const AppAuthException(
          message: 'Your account has been deactivated. Contact an administrator.',
          code: 'ACCOUNT_DEACTIVATED',
        );
      }

      // STEP 4: Update last seen
      debugPrint('[AUTH] Step 4: Updating last_seen_at');
      await _client
          .from(SupabaseConstants.profilesTable)
          .update({'last_seen_at': DateTime.now().toIso8601String()})
          .eq('id', response.user!.id);
      debugPrint('[AUTH] Step 4 SUCCESS: login complete');

      return profile;
    } on AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      debugPrint('[AUTH] AuthException: ${e.message} | statusCode: ${e.statusCode}');
      throw AppAuthException(
        message: _mapAuthError(e.message),
        originalError: e,
      );
    } catch (e, st) {
      debugPrint('[AUTH] UNEXPECTED ERROR: $e');
      debugPrint('[AUTH] Stack trace: $st');
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
      debugPrint('[AUTH] getCurrentProfile: querying profiles table for userId=$userId');
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      debugPrint('[AUTH] getCurrentProfile: SUCCESS');
      return UserProfileModel.fromJson(data);
    } catch (e, st) {
      debugPrint('[AUTH] getCurrentProfile FAILED: $e');
      debugPrint('[AUTH] Stack trace: $st');
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
