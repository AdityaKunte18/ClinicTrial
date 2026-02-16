import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'repository_providers.dart';

/// Search query for syndrome list.
final syndromeSearchQueryProvider = StateProvider<String>((ref) => '');

/// All active syndrome protocols.
final syndromeProtocolsProvider =
    FutureProvider<List<SyndromeProtocol>>((ref) async {
  final repo = ref.watch(dataRepositoryProvider);
  return repo.getSyndromeProtocols(activeOnly: true);
});

/// Filtered syndrome list based on search query.
final filteredSyndromeProtocolsProvider =
    FutureProvider<List<SyndromeProtocol>>((ref) async {
  final protocols = await ref.watch(syndromeProtocolsProvider.future);
  final query = ref.watch(syndromeSearchQueryProvider).toLowerCase();
  if (query.isEmpty) return protocols;

  return protocols.where((p) {
    return p.name.toLowerCase().contains(query) ||
        p.code.toLowerCase().contains(query) ||
        (p.category?.toLowerCase().contains(query) ?? false);
  }).toList();
});

/// Syndromes grouped by category.
final syndromesGroupedByCategoryProvider =
    FutureProvider<Map<String, List<SyndromeProtocol>>>((ref) async {
  final protocols = await ref.watch(filteredSyndromeProtocolsProvider.future);
  final grouped = <String, List<SyndromeProtocol>>{};
  for (final p in protocols) {
    final cat = p.category ?? 'Other';
    grouped.putIfAbsent(cat, () => []).add(p);
  }
  return grouped;
});

/// Single syndrome by ID.
final syndromeProtocolByIdProvider =
    FutureProvider.family<SyndromeProtocol?, String>((ref, id) async {
  final repo = ref.watch(dataRepositoryProvider);
  return repo.getSyndromeProtocol(id);
});
