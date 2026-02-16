import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'repository_providers.dart';

/// Search query for patient list.
final patientSearchQueryProvider = StateProvider<String>((ref) => '');

/// Active admissions list (auto-refreshes when invalidated).
final activeAdmissionsProvider = FutureProvider<List<Admission>>((ref) async {
  final repo = ref.watch(dataRepositoryProvider);
  return repo.getActiveAdmissions();
});

/// All patients, optionally filtered by search query.
final patientsProvider = FutureProvider<List<Patient>>((ref) async {
  final repo = ref.watch(dataRepositoryProvider);
  final query = ref.watch(patientSearchQueryProvider);
  return repo.getPatients(searchQuery: query.isEmpty ? null : query);
});

/// Lookup patient by ID from the patients list.
final patientByIdProvider =
    FutureProvider.family<Patient?, String>((ref, patientId) async {
  final patients = await ref.watch(patientsProvider.future);
  return patients.cast<Patient?>().firstWhere(
        (p) => p!.id == patientId,
        orElse: () => null,
      );
});

/// Syndromes linked to a specific admission.
final admissionSyndromesProvider =
    FutureProvider.family<List<AdmissionSyndrome>, String>(
        (ref, admissionId) async {
  final repo = ref.watch(dataRepositoryProvider);
  return repo.getAdmissionSyndromes(admissionId);
});

/// View model combining admission + patient for display in patient card.
class AdmissionWithPatient {
  final Admission admission;
  final Patient patient;
  final List<AdmissionSyndrome> syndromes;

  AdmissionWithPatient({
    required this.admission,
    required this.patient,
    required this.syndromes,
  });
}

/// Combined view: active admissions enriched with patient data.
final activeAdmissionsWithPatientsProvider =
    FutureProvider<List<AdmissionWithPatient>>((ref) async {
  final repo = ref.watch(dataRepositoryProvider);
  final admissions = await repo.getActiveAdmissions();
  final patients = await repo.getPatients();

  final patientMap = {for (final p in patients) p.id: p};

  final result = <AdmissionWithPatient>[];
  for (final adm in admissions) {
    final patient = patientMap[adm.patientId];
    if (patient == null) continue;
    final syndromes = await repo.getAdmissionSyndromes(adm.id);
    result.add(AdmissionWithPatient(
      admission: adm,
      patient: patient,
      syndromes: syndromes,
    ));
  }
  return result;
});
