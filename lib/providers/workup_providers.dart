import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../screens/workup/widgets/workup_helpers.dart';
import 'patient_providers.dart';
import 'repository_providers.dart';
import 'syndrome_providers.dart';

// ── Workup items for a single admission ─────────────────────────────

/// Fetches all workup items for an admission, sorted by sortOrder.
final workupItemsProvider =
    FutureProvider.family<List<WorkupItem>, String>((ref, admissionId) async {
  final repo = ref.watch(dataRepositoryProvider);
  return repo.getWorkupItems(admissionId);
});

/// Workup items grouped by domain for tab display.
final workupItemsByDomainProvider =
    FutureProvider.family<Map<WorkupDomain, List<WorkupItem>>, String>(
        (ref, admissionId) async {
  final items = await ref.watch(workupItemsProvider(admissionId).future);
  final grouped = <WorkupDomain, List<WorkupItem>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.domain, () => []).add(item);
  }
  return grouped;
});

// ── Admission lookup ────────────────────────────────────────────────

/// Lookup a single admission by ID from active admissions.
final admissionByIdProvider =
    FutureProvider.family<Admission?, String>((ref, admissionId) async {
  final admissions = await ref.watch(activeAdmissionsProvider.future);
  return admissions.cast<Admission?>().firstWhere(
        (a) => a!.id == admissionId,
        orElse: () => null,
      );
});

// ── Discharge check ─────────────────────────────────────────────────

/// Holds the hard-blocks and soft-warnings for a discharge decision.
class DischargeCheck {
  final List<WorkupItem> hardBlocks;
  final List<WorkupItem> softWarnings;

  DischargeCheck({required this.hardBlocks, required this.softWarnings});

  bool get canDischarge => hardBlocks.isEmpty;
}

/// Computes discharge readiness for an admission.
final dischargeCheckProvider =
    FutureProvider.family<DischargeCheck, String>((ref, admissionId) async {
  final items = await ref.watch(workupItemsProvider(admissionId).future);
  const completedStatuses = {WorkupStatus.done, WorkupStatus.notApplicable};

  final hardBlocks = items
      .where((i) => i.isHardBlock && !completedStatuses.contains(i.status))
      .toList();
  final softWarnings = items
      .where(
          (i) => i.isRequired && !i.isHardBlock && !completedStatuses.contains(i.status))
      .toList();

  return DischargeCheck(hardBlocks: hardBlocks, softWarnings: softWarnings);
});

// ── Cross-admission task aggregation ────────────────────────────────

/// A single task item combining workup item with patient & admission context.
class TaskItem {
  final WorkupItem workupItem;
  final Patient patient;
  final Admission admission;

  TaskItem({
    required this.workupItem,
    required this.patient,
    required this.admission,
  });
}

/// Grouped task lists for the My Tasks screen.
class TaskGroups {
  final List<TaskItem> overdue;
  final List<TaskItem> today;
  final List<TaskItem> upcoming;
  final List<TaskItem> noDay;

  TaskGroups({
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.noDay,
  });

  bool get isEmpty =>
      overdue.isEmpty && today.isEmpty && upcoming.isEmpty && noDay.isEmpty;
}

/// Aggregates all pending workup items across all active admissions,
/// grouped into overdue / today / upcoming / no-day buckets.
final allTasksProvider = FutureProvider<TaskGroups>((ref) async {
  final repo = ref.watch(dataRepositoryProvider);
  final admissions = await repo.getActiveAdmissions();
  final patients = await repo.getPatients();
  final patientMap = {for (final p in patients) p.id: p};

  final overdue = <TaskItem>[];
  final today = <TaskItem>[];
  final upcoming = <TaskItem>[];
  final noDay = <TaskItem>[];

  for (final adm in admissions) {
    final patient = patientMap[adm.patientId];
    if (patient == null) continue;
    final items = await repo.getWorkupItems(adm.id);
    for (final item in items) {
      if (item.status == WorkupStatus.done ||
          item.status == WorkupStatus.notApplicable) {
        continue;
      }
      final taskItem =
          TaskItem(workupItem: item, patient: patient, admission: adm);
      if (item.targetDay == null) {
        noDay.add(taskItem);
      } else if (item.targetDay! < adm.currentDay) {
        overdue.add(taskItem);
      } else if (item.targetDay == adm.currentDay) {
        today.add(taskItem);
      } else {
        upcoming.add(taskItem);
      }
    }
  }

  return TaskGroups(
    overdue: overdue,
    today: today,
    upcoming: upcoming,
    noDay: noDay,
  );
});

// ── Day simulation ──────────────────────────────────────────────────

/// Holds simulated day per admission. null = use admission.currentDay.
final simulatedDayProvider =
    StateProvider.family<int?, String>((ref, admissionId) => null);

/// Resolved effective day: simulated if set, otherwise admission.currentDay.
final effectiveDayProvider =
    FutureProvider.family<int, String>((ref, admissionId) async {
  final simulated = ref.watch(simulatedDayProvider(admissionId));
  if (simulated != null) return simulated;
  final admission =
      await ref.watch(admissionByIdProvider(admissionId).future);
  return admission?.currentDay ?? 1;
});

// ── Progress tracking ───────────────────────────────────────────────

/// Progress stats for a single domain.
class DomainProgress {
  final WorkupDomain domain;
  final int total;
  final int completed;

  DomainProgress({
    required this.domain,
    required this.total,
    required this.completed,
  });

  double get percent => total == 0 ? 0 : completed / total;
}

/// Aggregate progress stats for an admission.
class WorkupProgress {
  final int totalItems;
  final int completedItems;
  final int requiredItems;
  final int requiredCompleted;
  final int alertCount;
  final bool canDischarge;
  final Map<WorkupDomain, DomainProgress> byDomain;

  WorkupProgress({
    required this.totalItems,
    required this.completedItems,
    required this.requiredItems,
    required this.requiredCompleted,
    required this.alertCount,
    required this.canDischarge,
    required this.byDomain,
  });

  double get overallPercent =>
      totalItems == 0 ? 0 : completedItems / totalItems;

  double get requiredPercent =>
      requiredItems == 0 ? 0 : requiredCompleted / requiredItems;
}

/// Computes overall and per-domain progress for an admission.
final workupProgressProvider =
    FutureProvider.family<WorkupProgress, String>((ref, admissionId) async {
  final items = await ref.watch(workupItemsProvider(admissionId).future);
  final effectiveDay =
      await ref.watch(effectiveDayProvider(admissionId).future);
  final dischargeCheck =
      await ref.watch(dischargeCheckProvider(admissionId).future);

  // Only clinical domains (6 tabs)
  final clinicalItems = items
      .where(
          (i) => WorkupHelpers.clinicalDomains.contains(i.domain))
      .toList();

  final totalItems = clinicalItems.length;
  final completedItems =
      clinicalItems.where((i) => WorkupHelpers.isCompleted(i.status)).length;
  final requiredItems = clinicalItems.where((i) => i.isRequired).length;
  final requiredCompleted = clinicalItems
      .where((i) => i.isRequired && WorkupHelpers.isCompleted(i.status))
      .length;

  // Overdue: targetDay < effectiveDay and not complete
  final alertCount = clinicalItems
      .where((i) =>
          i.targetDay != null &&
          i.targetDay! < effectiveDay &&
          !WorkupHelpers.isCompleted(i.status))
      .length;

  // Per-domain breakdown
  final byDomain = <WorkupDomain, DomainProgress>{};
  for (final domain in WorkupHelpers.clinicalDomains) {
    final domainItems =
        clinicalItems.where((i) => i.domain == domain).toList();
    byDomain[domain] = DomainProgress(
      domain: domain,
      total: domainItems.length,
      completed: domainItems
          .where((i) => WorkupHelpers.isCompleted(i.status))
          .length,
    );
  }

  return WorkupProgress(
    totalItems: totalItems,
    completedItems: completedItems,
    requiredItems: requiredItems,
    requiredCompleted: requiredCompleted,
    alertCount: alertCount,
    canDischarge: dischargeCheck.canDischarge,
    byDomain: byDomain,
  );
});

// ── Day-to-date mapping ─────────────────────────────────────────────

/// Maps admission days (1-5) to actual calendar dates.
final dayToDateProvider =
    FutureProvider.family<Map<int, DateTime>, String>(
        (ref, admissionId) async {
  final admission =
      await ref.watch(admissionByIdProvider(admissionId).future);
  if (admission == null) return {};
  final map = <int, DateTime>{};
  for (int d = 1; d <= 5; d++) {
    map[d] = admission.admissionDate.add(Duration(days: d - 1));
  }
  return map;
});

// ── Timeline display items (with auto-shift) ────────────────────────

/// Workup items with display-adjusted days: pending past-day items
/// are shifted to the effective (current) day for timeline display.
final timelineDisplayItemsProvider =
    FutureProvider.family<List<WorkupItem>, String>(
        (ref, admissionId) async {
  final items =
      await ref.watch(workupItemsProvider(admissionId).future);
  final effectiveDay =
      await ref.watch(effectiveDayProvider(admissionId).future);

  return items.map((item) {
    if (item.targetDay != null &&
        item.targetDay! < effectiveDay &&
        !WorkupHelpers.isCompleted(item.status)) {
      // Auto-shift: pending past-day items appear on current day
      return item.copyWith(targetDay: effectiveDay);
    }
    return item;
  }).toList();
});

// ── Syndrome names for display ──────────────────────────────────────

/// Resolves syndrome protocol names for an admission.
final admissionSyndromeNamesProvider =
    FutureProvider.family<List<String>, String>((ref, admissionId) async {
  final syndromes =
      await ref.watch(admissionSyndromesProvider(admissionId).future);
  final names = <String>[];
  for (final s in syndromes) {
    final protocol =
        await ref.watch(syndromeProtocolByIdProvider(s.syndromeId).future);
    if (protocol != null) names.add(protocol.name);
  }
  return names;
});
