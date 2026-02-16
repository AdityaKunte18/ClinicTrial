import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../utils/workup_generator.dart';
import 'auth_provider.dart';
import 'patient_providers.dart';
import 'repository_providers.dart';

// ── Wizard State ────────────────────────────────────────────────────
class AdmissionWizardState {
  final int currentStep; // 0=Patient, 1=Syndromes, 2=Confirm
  final Patient? selectedPatient;
  final String bedNumber;
  final List<String> selectedSyndromeIds;
  final String? primarySyndromeId;
  final bool isSubmitting;
  final String? error;
  final String? createdAdmissionId;

  const AdmissionWizardState({
    this.currentStep = 0,
    this.selectedPatient,
    this.bedNumber = '',
    this.selectedSyndromeIds = const [],
    this.primarySyndromeId,
    this.isSubmitting = false,
    this.error,
    this.createdAdmissionId,
  });

  bool get canProceedFromPatient =>
      selectedPatient != null && bedNumber.isNotEmpty;

  bool get canProceedFromSyndromes => selectedSyndromeIds.isNotEmpty;

  AdmissionWizardState copyWith({
    int? currentStep,
    Patient? selectedPatient,
    String? bedNumber,
    List<String>? selectedSyndromeIds,
    String? primarySyndromeId,
    bool? isSubmitting,
    String? error,
    String? createdAdmissionId,
  }) {
    return AdmissionWizardState(
      currentStep: currentStep ?? this.currentStep,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      bedNumber: bedNumber ?? this.bedNumber,
      selectedSyndromeIds: selectedSyndromeIds ?? this.selectedSyndromeIds,
      primarySyndromeId: primarySyndromeId ?? this.primarySyndromeId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      createdAdmissionId: createdAdmissionId ?? this.createdAdmissionId,
    );
  }
}

// ── Wizard Notifier ─────────────────────────────────────────────────
class AdmissionWizardNotifier extends StateNotifier<AdmissionWizardState> {
  final Ref _ref;

  AdmissionWizardNotifier(this._ref) : super(const AdmissionWizardState());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void selectPatient(Patient patient) {
    state = state.copyWith(selectedPatient: patient);
  }

  void setBedNumber(String bed) {
    state = state.copyWith(bedNumber: bed);
  }

  void toggleSyndrome(String syndromeId) {
    final ids = List<String>.from(state.selectedSyndromeIds);
    if (ids.contains(syndromeId)) {
      ids.remove(syndromeId);
      // If we removed the primary, pick new primary or null
      final newPrimary =
          state.primarySyndromeId == syndromeId
              ? (ids.isNotEmpty ? ids.first : null)
              : state.primarySyndromeId;
      state = state.copyWith(
          selectedSyndromeIds: ids, primarySyndromeId: newPrimary);
    } else {
      ids.add(syndromeId);
      // First selected becomes primary automatically
      final newPrimary = state.primarySyndromeId ?? syndromeId;
      state = state.copyWith(
          selectedSyndromeIds: ids, primarySyndromeId: newPrimary);
    }
  }

  void setPrimarySyndrome(String syndromeId) {
    state = state.copyWith(primarySyndromeId: syndromeId);
  }

  /// Submit the admission: create admission, link syndromes, generate workup items.
  Future<void> submit() async {
    if (state.selectedPatient == null || state.selectedSyndromeIds.isEmpty) {
      return;
    }
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repo = _ref.read(dataRepositoryProvider);
      final authState = _ref.read(authProvider);
      final uuid = const Uuid();

      final now = DateTime.now();
      final admission = Admission(
        id: uuid.v4(),
        patientId: state.selectedPatient!.id,
        hospitalId: authState.user!.hospitalId,
        bedNumber: state.bedNumber,
        admissionDate: now,
        expectedDischarge: now.add(const Duration(days: 5)),
        admittingDoctorId: authState.user!.id,
        status: AdmissionStatus.active,
        currentDay: 1,
        dischargeBlocked: false,
      );

      final created = await repo.createAdmission(admission);

      // Link syndromes
      final syndromes = state.selectedSyndromeIds.map((sid) {
        return AdmissionSyndrome(
          id: uuid.v4(),
          admissionId: created.id,
          syndromeId: sid,
          isPrimary: sid == state.primarySyndromeId,
          detectedBy: 'manual',
        );
      }).toList();
      await repo.setAdmissionSyndromes(created.id, syndromes);

      // Generate workup items from syndrome templates
      final allWorkupItems = <WorkupItem>[];
      for (final sid in state.selectedSyndromeIds) {
        final protocol = await repo.getSyndromeProtocol(sid);
        if (protocol != null) {
          allWorkupItems.addAll(generateWorkupItems(
            admissionId: created.id,
            protocol: protocol,
          ));
        }
      }
      await repo.createWorkupItems(allWorkupItems);

      // Invalidate cached data
      _ref.invalidate(activeAdmissionsProvider);
      _ref.invalidate(activeAdmissionsWithPatientsProvider);

      state = state.copyWith(
        isSubmitting: false,
        createdAdmissionId: created.id,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  void reset() {
    state = const AdmissionWizardState();
  }
}

final admissionWizardProvider =
    StateNotifierProvider<AdmissionWizardNotifier, AdmissionWizardState>((ref) {
  return AdmissionWizardNotifier(ref);
});
