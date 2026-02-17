import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'patient_providers.dart';
import 'repository_providers.dart';

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
