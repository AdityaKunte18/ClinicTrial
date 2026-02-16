import '../models/models.dart';

/// Abstract interface for all data access.
/// Implemented by InMemoryRepository (demo) and SupabaseRepository (production).
abstract class DataRepository {
  // Auth / User
  Future<AppUser?> getUserProfile(String userId);
  Future<AppUser> createUserProfile(AppUser user);
  Future<List<Hospital>> getHospitals();

  // Patients
  Future<List<Patient>> getPatients({String? searchQuery});
  Future<Patient?> getPatientByUhid(String uhid);
  Future<Patient> createPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);

  // Admissions
  Future<List<Admission>> getActiveAdmissions();
  Future<Admission> createAdmission(Admission admission);
  Future<Admission> updateAdmission(Admission admission);
  Future<List<AdmissionSyndrome>> getAdmissionSyndromes(String admissionId);
  Future<void> setAdmissionSyndromes(
    String admissionId,
    List<AdmissionSyndrome> syndromes,
  );

  // Syndromes
  Future<List<SyndromeProtocol>> getSyndromeProtocols({bool activeOnly = true});
  Future<SyndromeProtocol?> getSyndromeProtocol(String id);

  // Workup Items
  Future<List<WorkupItem>> getWorkupItems(String admissionId);
  Future<void> createWorkupItems(List<WorkupItem> items);
  Future<WorkupItem> updateWorkupItem(WorkupItem item);
}
