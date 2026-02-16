import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient get client {
    assert(_initialized, 'Supabase is not initialized. Set valid credentials in .env');
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    final url = Env.supabaseUrl;
    final key = Env.supabaseAnonKey;

    if (url.isEmpty || key.isEmpty || url.startsWith('https://your-')) {
      developer.log(
        'Supabase not configured — running in offline/demo mode. '
        'Set SUPABASE_URL and SUPABASE_ANON_KEY in .env to enable.',
        name: 'SupabaseService',
      );
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: key);
      _initialized = true;
    } catch (e) {
      developer.log('Supabase init failed: $e', name: 'SupabaseService');
    }
  }

  /// True when Supabase is not configured — switches to in-memory demo repo.
  static bool get isDemoMode => !_initialized;

  /// GoTrueClient when initialized, null in demo mode.
  static GoTrueClient? get authOrNull => _initialized ? client.auth : null;

  // Auth shortcuts — safe to call only when initialized
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => _initialized ? auth.currentUser : null;
  static bool get isAuthenticated => currentUser != null;
}
