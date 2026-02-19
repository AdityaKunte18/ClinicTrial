import '../models/models.dart';

/// Hardcoded demo data for offline/demo mode.
class DemoData {
  static const demoHospitalId = 'demo-hospital-001';
  static const demoUserId = 'demo-user-001';

  static final hospital = Hospital(
    id: demoHospitalId,
    name: 'Government Medical College & Hospital',
    city: 'Pune',
    type: HospitalType.government,
    mjpjayEmpanelled: true,
    pmjayEmpanelled: true,
  );

  static final demoUser = AppUser(
    id: demoUserId,
    name: 'Dr. Demo User',
    email: 'demo@clinicalpilot.dev',
    phone: '9876543210',
    role: UserRole.consultant,
    hospitalId: demoHospitalId,
    unit: 'Medicine Unit 1',
    createdAt: DateTime(2025, 1, 1),
  );

  static List<Patient> get samplePatients => [
    Patient(
      id: 'demo-patient-001',
      uhid: 'GMC-2025-1001',
      name: 'Ramesh Kumar',
      age: 58,
      sex: 'M',
      phone: '9812345001',
      rationCardType: 'orange',
      pmjayEligible: false,
      mjpjayEligible: true,
      ayushmanCardNumber: 'MH-MJPJAY-900001',
    ),
    Patient(
      id: 'demo-patient-002',
      uhid: 'GMC-2025-1002',
      name: 'Priya Sharma',
      age: 35,
      sex: 'F',
      phone: '9812345002',
      pmjayEligible: false,
      mjpjayEligible: false,
    ),
    Patient(
      id: 'demo-patient-003',
      uhid: 'GMC-2025-1003',
      name: 'Mohammed Ansari',
      age: 72,
      sex: 'M',
      phone: '9812345003',
      rationCardType: 'yellow',
      pmjayEligible: true,
      mjpjayEligible: false,
      ayushmanCardNumber: 'MH-PMJAY-700003',
    ),
  ];

  static List<Admission> get sampleAdmissions {
    final now = DateTime.now();
    return [
      Admission(
        id: 'demo-adm-001',
        patientId: 'demo-patient-001',
        hospitalId: demoHospitalId,
        bedNumber: 'M1-12',
        admissionDate: now.subtract(const Duration(days: 2)),
        expectedDischarge: now.add(const Duration(days: 2)),
        admittingDoctorId: demoUserId,
        status: AdmissionStatus.active,
        currentDay: 3,
        dischargeBlocked: false,
      ),
      Admission(
        id: 'demo-adm-002',
        patientId: 'demo-patient-002',
        hospitalId: demoHospitalId,
        bedNumber: 'M1-08',
        admissionDate: now,
        expectedDischarge: now.add(const Duration(days: 4)),
        admittingDoctorId: demoUserId,
        status: AdmissionStatus.active,
        currentDay: 1,
        dischargeBlocked: false,
      ),
      Admission(
        id: 'demo-adm-003',
        patientId: 'demo-patient-003',
        hospitalId: demoHospitalId,
        bedNumber: 'M1-03',
        admissionDate: now.subtract(const Duration(days: 3)),
        expectedDischarge: now.add(const Duration(days: 1)),
        admittingDoctorId: demoUserId,
        status: AdmissionStatus.active,
        currentDay: 4,
        dischargeBlocked: true,
        dischargeBlockReasons: ['Pending biopsy report', 'INR not in range'],
      ),
    ];
  }

  static List<AdmissionSyndrome> get sampleAdmissionSyndromes => [
    AdmissionSyndrome(
      id: 'demo-as-001',
      admissionId: 'demo-adm-001',
      syndromeId: 'syn-08',
      isPrimary: true,
      detectedBy: 'manual',
      activeClassificationId: 'cls-ckd-g4',
    ),
    AdmissionSyndrome(
      id: 'demo-as-002',
      admissionId: 'demo-adm-001',
      syndromeId: 'syn-09',
      isPrimary: false,
      detectedBy: 'manual',
    ),
    AdmissionSyndrome(
      id: 'demo-as-003',
      admissionId: 'demo-adm-002',
      syndromeId: 'syn-01',
      isPrimary: true,
      detectedBy: 'manual',
    ),
    AdmissionSyndrome(
      id: 'demo-as-004',
      admissionId: 'demo-adm-003',
      syndromeId: 'syn-06',
      isPrimary: true,
      detectedBy: 'manual',
      activeClassificationId: 'cls-gi-portal-htn',
    ),
    AdmissionSyndrome(
      id: 'demo-as-005',
      admissionId: 'demo-adm-003',
      syndromeId: 'syn-12',
      isPrimary: false,
      detectedBy: 'manual',
    ),
  ];

  // ── Pre-applied classification events ─────────────────────────────
  static List<ClassificationEvent> get sampleClassificationEvents {
    final now = DateTime.now();
    return [
      // demo-adm-001 / syn-08: CKD Stage 4 auto-classified from RFT 'G4'
      ClassificationEvent(
        id: 'demo-cls-evt-001',
        admissionId: 'demo-adm-001',
        syndromeId: 'syn-08',
        classificationRuleId: 'cls-ckd-g4',
        classificationName: 'CKD Stage 4 (Severe)',
        trigger: 'auto',
        triggeredByItemId: 'c-b2',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        createdBy: demoUserId,
      ),
      // demo-adm-003 / syn-06: Portal Hypertension from ascitic fluid 'high_saag'
      ClassificationEvent(
        id: 'demo-cls-evt-002',
        admissionId: 'demo-adm-003',
        syndromeId: 'syn-06',
        classificationRuleId: 'cls-gi-portal-htn',
        classificationName: 'Portal Hypertension (High SAAG)',
        trigger: 'auto',
        triggeredByItemId: 'g-b6',
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        createdBy: demoUserId,
      ),
      // NOTE: cls-gi-hbv deliberately NOT seeded — g-b5 result 'hbsag_positive'
      // will trigger the AI suggestion banner for "Hepatitis B Related CLD"
    ];
  }
}
