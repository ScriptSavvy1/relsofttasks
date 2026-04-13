import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/network/supabase_client_provider.dart';

/// Provides the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

/// Provides the current user's profile (fetched from DB)
final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentProfile();
});

/// Auth state notifier for login/logout operations
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserProfile?>(AuthController.new);

class AuthController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo.hasActiveSession) {
      return repo.getCurrentProfile();
    }
    return null;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.signIn(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    });
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncData(null);
  }

  Future<void> sendPasswordReset(String email) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.sendPasswordReset(email);
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.getCurrentProfile();
    });
  }
}
