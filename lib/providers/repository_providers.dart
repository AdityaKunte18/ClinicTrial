import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/data_repository.dart';
import '../repositories/in_memory_repository.dart';
import '../repositories/supabase_repository.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

/// Provides the active [DataRepository] implementation.
/// Uses [InMemoryRepository] when:
///   1. Supabase is not configured (isDemoMode), OR
///   2. The user chose "Continue as Demo" (AuthMode.demo).
/// Uses [SupabaseRepository] only when Supabase is configured AND the user
/// authenticated via Supabase.
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  final authState = ref.watch(authProvider);
  if (SupabaseService.isDemoMode || authState.mode == AuthMode.demo) {
    return InMemoryRepository();
  }
  return SupabaseRepository();
});
