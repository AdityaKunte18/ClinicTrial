import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/models.dart';
import '../services/supabase_service.dart';
import 'repository_providers.dart';

// ── Auth Mode ───────────────────────────────────────────────────────
enum AuthMode { unauthenticated, demo, supabase }

// ── Auth State ──────────────────────────────────────────────────────
class AuthState {
  final AuthMode mode;
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.mode = AuthMode.unauthenticated,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated =>
      mode == AuthMode.demo || mode == AuthMode.supabase;

  AuthState copyWith({
    AuthMode? mode,
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Auth Notifier ───────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  StreamSubscription<sb.AuthState>? _authSub;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    if (SupabaseService.isDemoMode) return;

    // Listen to Supabase auth changes
    _authSub = SupabaseService.authOrNull?.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserProfile(session.user.id);
      } else {
        state = const AuthState(mode: AuthMode.unauthenticated);
      }
    });

    // Check for existing session
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      _loadUserProfile(currentUser.id);
    }
  }

  Future<void> _loadUserProfile(String authId) async {
    final repo = _ref.read(dataRepositoryProvider);
    final profile = await repo.getUserProfile(authId);
    if (profile != null) {
      state = AuthState(mode: AuthMode.supabase, user: profile);
    } else {
      // User authenticated but no profile yet — keep auth, user is null
      state = const AuthState(mode: AuthMode.supabase);
    }
  }

  /// Sign in with email & password via Supabase.
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final auth = SupabaseService.authOrNull;
      if (auth == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Supabase is not configured. Use demo mode instead.',
        );
        return;
      }
      await auth.signInWithPassword(email: email, password: password);
      // Auth state listener will update the state
      state = state.copyWith(isLoading: false);
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Create new account via Supabase and insert user profile.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? unit,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final auth = SupabaseService.authOrNull;
      if (auth == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Supabase is not configured. Use demo mode instead.',
        );
        return;
      }

      final res = await auth.signUp(email: email, password: password);
      final authUser = res.user;
      if (authUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sign-up succeeded but no user returned.',
        );
        return;
      }

      // Create profile in users table.
      // Use the known seed hospital UUID — RLS prevents querying hospitals
      // before the user profile exists.
      const seedHospitalId = '00000000-0000-0000-0000-000000000001';

      final repo = _ref.read(dataRepositoryProvider);
      final profile = AppUser(
        id: authUser.id, // Supabase Auth uid → mapped to auth_id by repo
        name: name,
        email: email,
        phone: phone,
        role: role,
        hospitalId: seedHospitalId,
        unit: unit,
        createdAt: DateTime.now(),
      );
      final saved = await repo.createUserProfile(profile);
      state = AuthState(mode: AuthMode.supabase, user: saved);
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign out from any mode.
  Future<void> signOut() async {
    if (state.mode == AuthMode.supabase) {
      try {
        await SupabaseService.authOrNull?.signOut();
      } catch (_) {}
    }
    state = const AuthState(mode: AuthMode.unauthenticated);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

// ── Providers ───────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

/// Listenable adapter for GoRouter refreshListenable.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

/// Convenience: is user authenticated?
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience: current AppUser.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});
