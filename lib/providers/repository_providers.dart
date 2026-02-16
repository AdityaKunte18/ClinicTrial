import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/data_repository.dart';
import '../repositories/in_memory_repository.dart';
import '../repositories/supabase_repository.dart';
import '../services/supabase_service.dart';

/// Provides the active [DataRepository] implementation.
/// Uses [InMemoryRepository] in demo mode, [SupabaseRepository] when Supabase
/// is configured.
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  if (SupabaseService.isDemoMode) {
    return InMemoryRepository();
  }
  return SupabaseRepository();
});
