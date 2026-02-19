import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/supabase_service.dart';
import 'data_repository.dart';

/// Production implementation of [DataRepository] backed by Supabase/PostgreSQL.
class SupabaseRepository implements DataRepository {
  SupabaseClient get _db => SupabaseService.client;

  // ── Auth / User ───────────────────────────────────────────────────

  @override
  Future<AppUser?> getUserProfile(String userId) async {
    final data =
        await _db.from('users').select().eq('auth_id', userId).maybeSingle();
    return data != null ? AppUser.fromJson(data) : null;
  }

  @override
  Future<AppUser> createUserProfile(AppUser user) async {
    final json = user.toJson();
    // AppUser.id holds the Supabase Auth uid during signup.
    // Map it to the auth_id column; let the DB generate the row id.
    json['auth_id'] = json.remove('id');
    final data = await _db.from('users').insert(json).select().single();
    return AppUser.fromJson(data);
  }

  @override
  Future<List<Hospital>> getHospitals() async {
    final data = await _db.from('hospitals').select();
    return data.map((j) => Hospital.fromJson(j)).toList();
  }

  // ── Patients ──────────────────────────────────────────────────────

  @override
  Future<List<Patient>> getPatients({String? searchQuery}) async {
    var query = _db.from('patients').select();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,uhid.ilike.%$searchQuery%');
    }
    final data = await query.order('name');
    return data.map((j) => Patient.fromJson(j)).toList();
  }

  @override
  Future<Patient?> getPatientByUhid(String uhid) async {
    final data =
        await _db.from('patients').select().eq('uhid', uhid).maybeSingle();
    return data != null ? Patient.fromJson(data) : null;
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    final json = patient.toJson();
    json.remove('id'); // Let Supabase generate UUID
    final data = await _db.from('patients').insert(json).select().single();
    return Patient.fromJson(data);
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    final data = await _db
        .from('patients')
        .update(patient.toJson())
        .eq('id', patient.id)
        .select()
        .single();
    return Patient.fromJson(data);
  }

  // ── Admissions ────────────────────────────────────────────────────

  @override
  Future<List<Admission>> getActiveAdmissions() async {
    final data = await _db
        .from('admissions')
        .select()
        .eq('status', 'active')
        .order('admission_date', ascending: false);
    return data.map((j) => Admission.fromJson(j)).toList();
  }

  @override
  Future<Admission> createAdmission(Admission admission) async {
    final json = admission.toJson();
    json.remove('id');
    final data = await _db.from('admissions').insert(json).select().single();
    return Admission.fromJson(data);
  }

  @override
  Future<Admission> updateAdmission(Admission admission) async {
    final data = await _db
        .from('admissions')
        .update(admission.toJson())
        .eq('id', admission.id)
        .select()
        .single();
    return Admission.fromJson(data);
  }

  @override
  Future<List<AdmissionSyndrome>> getAdmissionSyndromes(
      String admissionId) async {
    final data = await _db
        .from('admission_syndromes')
        .select()
        .eq('admission_id', admissionId);
    return data.map((j) => AdmissionSyndrome.fromJson(j)).toList();
  }

  @override
  Future<void> setAdmissionSyndromes(
    String admissionId,
    List<AdmissionSyndrome> syndromes,
  ) async {
    // Delete existing links then insert new ones
    await _db
        .from('admission_syndromes')
        .delete()
        .eq('admission_id', admissionId);
    if (syndromes.isNotEmpty) {
      final rows = syndromes.map((s) {
        final json = s.toJson();
        json.remove('id');
        json['admission_id'] = admissionId;
        return json;
      }).toList();
      await _db.from('admission_syndromes').insert(rows);
    }
  }

  // ── Syndromes ─────────────────────────────────────────────────────

  @override
  Future<List<SyndromeProtocol>> getSyndromeProtocols(
      {bool activeOnly = true}) async {
    var query = _db.from('syndrome_protocols').select();
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    final data = await query.order('code');
    return data.map((j) => SyndromeProtocol.fromJson(j)).toList();
  }

  @override
  Future<SyndromeProtocol?> getSyndromeProtocol(String id) async {
    final data = await _db
        .from('syndrome_protocols')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data != null ? SyndromeProtocol.fromJson(data) : null;
  }

  // ── Workup Items ──────────────────────────────────────────────────

  @override
  Future<List<WorkupItem>> getWorkupItems(String admissionId) async {
    final data = await _db
        .from('workup_items')
        .select()
        .eq('admission_id', admissionId)
        .order('sort_order');
    return data.map((j) => WorkupItem.fromJson(j)).toList();
  }

  @override
  Future<void> createWorkupItems(List<WorkupItem> items) async {
    if (items.isEmpty) return;
    final rows = items.map((item) {
      final json = item.toJson();
      json.remove('id'); // Let Supabase generate UUID
      return json;
    }).toList();
    await _db.from('workup_items').insert(rows);
  }

  @override
  Future<WorkupItem> updateWorkupItem(WorkupItem item) async {
    final data = await _db
        .from('workup_items')
        .update(item.toJson())
        .eq('id', item.id)
        .select()
        .single();
    return WorkupItem.fromJson(data);
  }

  // ── Classification Events ───────────────────────────────────────

  @override
  Future<List<ClassificationEvent>> getClassificationEvents(
      String admissionId) async {
    final data = await _db
        .from('classification_events')
        .select()
        .eq('admission_id', admissionId)
        .order('created_at', ascending: false);
    return data.map((j) => ClassificationEvent.fromJson(j)).toList();
  }

  @override
  Future<ClassificationEvent> createClassificationEvent(
      ClassificationEvent event) async {
    final json = event.toJson();
    json.remove('id');
    final data = await _db
        .from('classification_events')
        .insert(json)
        .select()
        .single();
    return ClassificationEvent.fromJson(data);
  }
}
