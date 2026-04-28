import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the current Supabase auth session as a reactive stream.
final authSessionProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Reactive current-user provider that rebuilds when the auth session changes.
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authSessionProvider);
  return Supabase.instance.client.auth.currentUser;
});

/// Provides the current user ID (nullable), rebuilt on auth changes.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});

/// A [ChangeNotifier] that fires whenever the Supabase auth state changes.
/// Plug this into GoRouter's `refreshListenable` so redirects re-run on
/// sign-in, sign-out, and token refresh.
class GoRouterAuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  GoRouterAuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final goRouterAuthNotifierProvider = Provider<GoRouterAuthNotifier>((ref) {
  final notifier = GoRouterAuthNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
