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

    // Seed pre-applied classification events
    for (final evt in DemoData.sampleClassificationEvents) {
      _classificationEvents[evt.id] = evt;
    }

    // Generate classification-triggered workup items for pre-applied events
    _seedClassificationWorkupItems();

    // Make demo data realistic: vary statuses for some items
    _applyRealisticStatuses();
  }

  /// Generates additional workup items from pre-applied classification events.
  void _seedClassificationWorkupItems() {
    for (final evt in _classificationEvents.values) {
      final protocol = _syndromes[evt.syndromeId];
      if (protocol == null) continue;

      final classifications = protocol.baseTemplate['classifications'];
      if (classifications is! List) continue;

      // Find the matching classification rule
      final ruleMap = classifications
          .whereType<Map<String, dynamic>>()
          .where((c) => c['id'] == evt.classificationRuleId)
          .firstOrNull;
      if (ruleMap == null) continue;

      final additionalWorkup = ruleMap['additional_workup'];
      if (additionalWorkup is! Map<String, dynamic>) continue;

      final items = generateClassificationItems(
        admissionId: evt.admissionId,
        syndromeId: evt.syndromeId,
        classificationEventId: evt.id,
        additionalWorkup: additionalWorkup,
      );
      for (final item in items) {
        _workupItems[item.id] = item;
      }
    }
  }

  /// Updates a subset of demo workup items to varied statuses so screens
  /// like Timeline, Discharge, and Tasks show meaningful data.
  void _applyRealisticStatuses() {
    final now = DateTime.now();

    // ── demo-adm-001 (Day 3, CKD + Electrolyte) ──────────────────────
    // Day 1: done, but c-b2 & c-b3 get specific classification-triggering results.
    // Day 2 blood: resulted. Day 2 other: ordered.
    // Classification items (sortOrder >= 1000): remain pending with AI Added chips.
    _updateItemsByAdmission('demo-adm-001', (items) {
      for (final item in items) {
        // Skip classification-generated items — leave pending
        if (item.sortOrder >= 1000) continue;

        if (item.templateItemId == 'c-b2') {
          // RFT: G4 result triggers cls-ckd-g4 (already applied)
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.resulted,
            resultValue: 'G4',
            resultOptionId: 'ro-ckd-gfr-g4',
            completedAt: now.subtract(const Duration(days: 1, hours: 8)),
          );
        } else if (item.templateItemId == 'c-b3') {
          // ABG: metabolic acidosis result
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.resulted,
            resultValue: 'metabolic_acidosis',
            resultOptionId: 'ro-ckd-abg-met-acid',
            completedAt: now.subtract(const Duration(days: 1, hours: 6)),
          );
        } else if (item.targetDay != null && item.targetDay! <= 1) {
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

    // ── demo-adm-002 (Day 1, Fever) — all pending (just admitted) ────
    // No changes needed, items are already pending.

    // ── demo-adm-003 (Day 4, GI/Hepatology + Hematology) ────────────
    // Specific results for classification triggers. Keep he-b6 pending for auto-shift.
    _updateItemsByAdmission('demo-adm-003', (items) {
      for (final item in items) {
        // Skip classification-generated items — leave pending
        if (item.sortOrder >= 1000) continue;

        if (item.isHardBlock) {
          // Leave hard-blocks pending to demonstrate discharge blocking
          continue;
        }

        // Specific classification-triggering result values
        if (item.templateItemId == 'g-b6') {
          // Ascitic fluid: high_saag → cls-gi-portal-htn (already applied)
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.resulted,
            resultValue: 'high_saag',
            resultOptionId: 'ro-gi-saag-high',
            completedAt: now.subtract(const Duration(days: 2, hours: 5)),
          );
        } else if (item.templateItemId == 'g-b5') {
          // Hepatitis panel: hbsag_positive → cls-gi-hbv NOT applied → AI banner
          _workupItems[item.id] = item.copyWith(
            status: WorkupStatus.resulted,
            resultValue: 'hbsag_positive',
            resultOptionId: 'ro-gi-hep-hbsag',
            completedAt: now.subtract(const Duration(days: 2, hours: 3)),
          );
        } else if (item.templateItemId == 'he-b6') {
          // Hemolysis screen (Day 2): keep pending → auto-shifts to Day 4
          // Already pending by default, no changes needed.
        } else if (item.targetDay != null && item.targetDay! <= 3) {
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
