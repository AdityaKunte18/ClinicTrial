import 'package:uuid/uuid.dart';

import '../data/demo_data.dart';
import '../data/syndrome_seed_data.dart';
import '../models/models.dart';
import '../utils/workup_generator.dart';
import 'data_repository.dart';

/// In-memory implementation of [DataRepository] for demo / offline mode.
/// All data lives in memory and is lost on app restart.
class InMemoryRepository implements DataRepository {
  final _uuid = const Uuid();

  // ── In-memory stores ──────────────────────────────────────────────
  final Map<String, Hospital> _hospitals = {};
  final Map<String, AppUser> _users = {};
  final Map<String, Patient> _patients = {};
  final Map<String, Admission> _admissions = {};
  final Map<String, AdmissionSyndrome> _admissionSyndromes = {};
  final Map<String, SyndromeProtocol> _syndromes = {};
  final Map<String, WorkupItem> _workupItems = {};
  final Map<String, ClassificationEvent> _classificationEvents = {};

  InMemoryRepository() {
    _seed();
  }

  void _seed() {
    // Hospital
    _hospitals[DemoData.hospital.id] = DemoData.hospital;

    // User
    _users[DemoData.demoUser.id] = DemoData.demoUser;

    // Patients
    for (final p in DemoData.samplePatients) {
      _patients[p.id] = p;
    }

    // Admissions
    for (final a in DemoData.sampleAdmissions) {
      _admissions[a.id] = a;
    }

    // Admission-Syndrome links
    for (final as_ in DemoData.sampleAdmissionSyndromes) {
      _admissionSyndromes[as_.id] = as_;
    }

    // Syndrome protocols (all 20)
    for (final sp in SyndromeSeedData.allProtocols) {
      _syndromes[sp.id] = sp;
    }

    // Generate workup items for demo admissions from their linked syndromes
    for (final as_ in DemoData.sampleAdmissionSyndromes) {
      final protocol = _syndromes[as_.syndromeId];
      if (protocol != null) {
        final items = generateWorkupItems(
          admissionId: as_.admissionId,
          protocol: protocol,
        );
        for (final item in items) {
          _workupItems[item.id] = item;
        }
      }
    }

    // Make demo data realistic: vary statuses for some items
    _applyRealisticStatuses();
  }

  /// Updates a subset of demo workup items to varied statuses so screens
  /// like Timeline, Discharge, and Tasks show meaningful data.
  void _applyRealisticStatuses() {
    final now = DateTime.now();

    // demo-adm-001 (Day 3, CKD + Electrolyte) — some Day 1 items done, Day 2 mixed
    _updateItemsByAdmission('demo-adm-001', (items) {
      for (final item in items) {
        if (item.targetDay != null && item.targetDay! <= 1) {
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.done,
            completedAt: now.subtract(const Duration(days: 1)),
          );
        } else if (item.targetDay == 2 &&
            item.domain == WorkupDomain.blood) {
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.resulted,
            resultValue: 'Within normal limits',
          );
        } else if (item.targetDay == 2) {
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.ordered,
          );
        }
      }
    });

    // demo-adm-002 (Day 1, Fever) — all pending (just admitted)
    // No changes needed, items are already pending.

    // demo-adm-003 (Day 4, GI/Hepatology + Hematology, discharge blocked)
    // Mark most non-hard-block items as done, leave hard-blocks pending
    _updateItemsByAdmission('demo-adm-003', (items) {
      for (final item in items) {
        if (item.isHardBlock) {
          // Leave hard-blocks pending to demonstrate discharge blocking
          continue;
        }
        if (item.targetDay != null && item.targetDay! <= 3) {
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.done,
            completedAt: now.subtract(Duration(days: 4 - item.targetDay!)),
          );
        } else if (item.targetDay == 4) {
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.ordered,
          );
        }
      }
    });
  }

  void _updateItemsByAdmission(
      String admissionId, void Function(List<WorkupItem>) updater) {
    final items = _workupItems.values
        .where((w) => w.admissionId == admissionId)
        .toList();
    updater(items);
  }

  // ── Auth / User ───────────────────────────────────────────────────

  @override
  Future<AppUser?> getUserProfile(String userId) async {
    return _users[userId];
  }

  @override
  Future<AppUser> createUserProfile(AppUser user) async {
    _users[user.id] = user;
    return user;
  }

  @override
  Future<List<Hospital>> getHospitals() async {
    return _hospitals.values.toList();
  }

  // ── Patients ──────────────────────────────────────────────────────

  @override
  Future<List<Patient>> getPatients({String? searchQuery}) async {
    var list = _patients.values.toList();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.uhid.toLowerCase().contains(q) ||
            (p.phone?.contains(q) ?? false);
      }).toList();
    }
    return list;
  }

  @override
  Future<Patient?> getPatientByUhid(String uhid) async {
    return _patients.values.cast<Patient?>().firstWhere(
          (p) => p!.uhid == uhid,
          orElse: () => null,
        );
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    final p = patient.copyWith(id: patient.id.isEmpty ? _uuid.v4() : null);
    _patients[p.id] = p;
    return p;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    _patients[patient.id] = patient;
    return patient;
  }

  // ── Admissions ────────────────────────────────────────────────────

  @override
  Future<List<Admission>> getActiveAdmissions() async {
    return _admissions.values
        .where((a) => a.status == AdmissionStatus.active)
        .toList();
  }

  @override
  Future<Admission> createAdmission(Admission admission) async {
    final a =
        admission.copyWith(id: admission.id.isEmpty ? _uuid.v4() : null);
    _admissions[a.id] = a;
    return a;
  }

  @override
  Future<Admission> updateAdmission(Admission admission) async {
    _admissions[admission.id] = admission;
    return admission;
  }

  @override
  Future<List<AdmissionSyndrome>> getAdmissionSyndromes(
      String admissionId) async {
    return _admissionSyndromes.values
        .where((as_) => as_.admissionId == admissionId)
        .toList();
  }

  @override
  Future<void> setAdmissionSyndromes(
    String admissionId,
    List<AdmissionSyndrome> syndromes,
  ) async {
    // Remove existing links for this admission
    _admissionSyndromes
        .removeWhere((_, v) => v.admissionId == admissionId);
    // Add new links
    for (final s in syndromes) {
      final as_ = s.copyWith(
        id: s.id.isEmpty ? _uuid.v4() : null,
        admissionId: admissionId,
      );
      _admissionSyndromes[as_.id] = as_;
    }
  }

  // ── Syndromes ─────────────────────────────────────────────────────

  @override
  Future<List<SyndromeProtocol>> getSyndromeProtocols(
      {bool activeOnly = true}) async {
    var list = _syndromes.values.toList();
    if (activeOnly) {
      list = list.where((s) => s.isActive).toList();
    }
    return list;
  }

  @override
  Future<SyndromeProtocol?> getSyndromeProtocol(String id) async {
    return _syndromes[id];
  }

  // ── Workup Items ──────────────────────────────────────────────────

  @override
  Future<List<WorkupItem>> getWorkupItems(String admissionId) async {
    return _workupItems.values
        .where((w) => w.admissionId == admissionId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<void> createWorkupItems(List<WorkupItem> items) async {
    for (final item in items) {
      _workupItems[item.id] = item;
    }
  }

  @override
  Future<WorkupItem> updateWorkupItem(WorkupItem item) async {
    _workupItems[item.id] = item;
    return item;
  }

  // ── Classification Events ───────────────────────────────────────

  @override
  Future<List<ClassificationEvent>> getClassificationEvents(
      String admissionId) async {
    return _classificationEvents.values
        .where((e) => e.admissionId == admissionId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<ClassificationEvent> createClassificationEvent(
      ClassificationEvent event) async {
    _classificationEvents[event.id] = event;
    return event;
  }
}
