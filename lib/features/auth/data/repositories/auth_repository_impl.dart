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

      final user = response.user!;

      // STEP 2: Fetch profile
      debugPrint('[AUTH] Step 2: Fetching profile for userId=${user.id}');
      UserProfile? profile;
      try {
        profile = await getCurrentProfile();
      } catch (e, st) {
        debugPrint('[AUTH] Step 2 FAILED (database error): $e');
        debugPrint('[AUTH] Step 2 Stack trace: $st');
        throw AppAuthException(
          message: 'Failed to load user profile: $e',
          code: 'PROFILE_FETCH_ERROR',
          originalError: e,
        );
      }
      debugPrint('[AUTH] Step 2 result: profile=${profile?.fullName ?? "NULL"}');

      // STEP 2b: If no profile found, attempt to create a minimal one
      if (profile == null) {
        debugPrint('[AUTH] Step 2b: No profile found, creating minimal profile for ${user.id}');
        try {
          final meta = user.userMetadata ?? {};
          final fullName = meta['full_name'] as String? ??
              email.trim().split('@').first;
          final role = meta['role'] as String? ?? 'staff';

          await _client.from(SupabaseConstants.profilesTable).insert({
            'id': user.id,
            'email': user.email ?? email.trim(),
            'full_name': fullName,
            'role': role,
          });
          debugPrint('[AUTH] Step 2b: Minimal profile created, re-fetching...');
          profile = await getCurrentProfile();
        } catch (e, st) {
          debugPrint('[AUTH] Step 2b: Failed to create minimal profile: $e');
          debugPrint('[AUTH] Step 2b Stack trace: $st');
        }
      }

      if (profile == null) {
        throw const AppAuthException(
          message:
              'User profile not found. Please contact support or complete onboarding.',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      // STEP 3: Check active
      debugPrint('[AUTH] Step 3: Checking isActive=${profile.isActive}');
      if (!profile.isActive) {
        await _client.auth.signOut();
        throw const AppAuthException(
          message:
              'Your account has been deactivated. Contact an administrator.',
          code: 'ACCOUNT_DEACTIVATED',
        );
      }

      // STEP 4: Update last seen
      debugPrint('[AUTH] Step 4: Updating last_seen_at');
      try {
        await _client
            .from(SupabaseConstants.profilesTable)
            .update({'last_seen_at': DateTime.now().toIso8601String()})
            .eq('id', user.id);
        debugPrint('[AUTH] Step 4 SUCCESS: login complete');
      } catch (e, st) {
        // Non-fatal: don't block login for a last_seen update failure
        debugPrint('[AUTH] Step 4 WARNING: last_seen update failed: $e');
        debugPrint('[AUTH] Step 4 Stack trace: $st');
      }

      return profile;
    } on AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      debugPrint(
          '[AUTH] AuthException: ${e.message} | statusCode: ${e.statusCode}');
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
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      debugPrint('[AUTH] Attempting signUp for $email');
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim(), 'role': 'staff'},
      );

      if (response.user == null) {
        throw const AppAuthException(
          message: 'Sign up failed.',
          code: 'SIGN_UP_FAILED',
        );
      }

      final user = response.user!;

      // Profile is usually created via Supabase Trigger (database function)
      // but we'll try to fetch it or create it manually here to be safe
      UserProfile? profile = await getCurrentProfile();

      if (profile == null) {
        debugPrint('[AUTH] Creating profile manually after signUp');
        await _client.from(SupabaseConstants.profilesTable).insert({
          'id': user.id,
          'email': user.email ?? email.trim(),
          'full_name': fullName.trim(),
          'role': 'staff',
        });
        profile = await getCurrentProfile();
      }

      if (profile == null) {
        throw const AppAuthException(
          message: 'Failed to create user profile.',
          code: 'PROFILE_CREATION_FAILED',
        );
      }

      return profile;
    } on AuthException catch (e) {
      debugPrint('[AUTH] AuthException: ${e.message}');
      throw AppAuthException(
        message: _mapAuthError(e.message),
        originalError: e,
      );
    } catch (e, st) {
      debugPrint('[AUTH] UNEXPECTED ERROR: $e');
      debugPrint('[AUTH] Stack trace: $st');
      throw AppAuthException(
        message: 'An unexpected error occurred during sign up.',
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
    if (userId == null) {
      debugPrint('[AUTH] getCurrentProfile: No current user ID, returning null');
      return null;
    }

    debugPrint(
        '[AUTH] getCurrentProfile: querying ${SupabaseConstants.profilesTable} for userId=$userId');
    final data = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      debugPrint('[AUTH] getCurrentProfile: No profile row found');
      return null;
    }

    debugPrint('[AUTH] getCurrentProfile: SUCCESS, parsing profile');
    return UserProfileModel.fromJson(data);
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
