import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/classification_engine.dart';
import 'repository_providers.dart';
import 'syndrome_providers.dart';
import 'workup_providers.dart';

// ── Classification events ───────────────────────────────────────────

/// All classification events for an admission, newest first.
final classificationEventsProvider =
    FutureProvider.family<List<ClassificationEvent>, String>(
        (ref, admissionId) async {
  final repo = ref.watch(dataRepositoryProvider);
  return repo.getClassificationEvents(admissionId);
});

// ── Active classification ───────────────────────────────────────────

/// Active classification for a specific admission+syndrome combo.
/// Returns the most recent non-override event.
final activeClassificationProvider = FutureProvider.family<
    ClassificationEvent?,
    ({String admissionId, String syndromeId})>((ref, params) async {
  final events =
      await ref.watch(classificationEventsProvider(params.admissionId).future);
  final syndromeEvents =
      events.where((e) => e.syndromeId == params.syndromeId).toList();
  if (syndromeEvents.isEmpty) return null;
  // Most recent event that's not an override (already sorted newest first)
  return syndromeEvents.firstOrNull;
});

// ── Result options from syndrome template ────────────────────────────

/// Parses result_options from a syndrome template for a given templateItemId.
final resultOptionsForItemProvider = Provider.family<List<ResultOption>,
    ({String syndromeId, String templateItemId})>((ref, params) {
  final protocolAsync =
      ref.watch(syndromeProtocolByIdProvider(params.syndromeId));
  final protocol = protocolAsync.valueOrNull;
  if (protocol == null) return [];

  final resultOptions = protocol.baseTemplate['result_options'];
  if (resultOptions is! List) return [];

  return resultOptions
      .whereType<Map<String, dynamic>>()
      .map((ro) => ResultOption.fromJson(ro))
      .where((ro) => ro.templateItemId == params.templateItemId)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
});

// ── Classification rules from syndrome template ─────────────────────

/// Parses classifications from a syndrome template.
final classificationRulesProvider =
    Provider.family<List<ClassificationRule>, String>((ref, syndromeId) {
  final protocolAsync =
      ref.watch(syndromeProtocolByIdProvider(syndromeId));
  final protocol = protocolAsync.valueOrNull;
  if (protocol == null) return [];

  final classifications = protocol.baseTemplate['classifications'];
  if (classifications is! List) return [];

  return classifications
      .whereType<Map<String, dynamic>>()
      .map((c) =>
          ClassificationRule.fromJson(c, syndromeId))
      .toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));
});

// ── Pending AI suggestions ──────────────────────────────────────────

/// Evaluates current results against classification rules.
/// Returns rules that match but haven't been applied yet.
final pendingAiSuggestionsProvider = FutureProvider.family<
    List<ClassificationRule>,
    ({String admissionId, String syndromeId})>((ref, params) async {
  final items =
      await ref.watch(workupItemsProvider(params.admissionId).future);
  final rules = ref.watch(classificationRulesProvider(params.syndromeId));
  if (rules.isEmpty) return [];

  // Get items for this syndrome
  final syndromeItems =
      items.where((i) => i.syndromeId == params.syndromeId).toList();

  // Evaluate rules
  final matches =
      ClassificationEngine.evaluateResults(items: syndromeItems, rules: rules);
  if (matches.isEmpty) return [];

  // Filter out already-applied classifications
  final events =
      await ref.watch(classificationEventsProvider(params.admissionId).future);
  final appliedRuleIds =
      events.map((e) => e.classificationRuleId).toSet();

  return matches.where((r) => !appliedRuleIds.contains(r.id)).toList();
});
