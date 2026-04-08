import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the current Supabase auth session
final authSessionProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provides the current authenticated user (nullable)
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Provides the current user ID (nullable)
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});
