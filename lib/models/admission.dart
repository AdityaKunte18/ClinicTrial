enum AdmissionStatus {
  active,
  discharged,
  transferred,
  lama,
  expired;

  String get toJson => name;

  static AdmissionStatus fromJson(String value) {
    return AdmissionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown AdmissionStatus: $value'),
    );
  }
}

class Admission {
  final String id;
  final String patientId;
  final String hospitalId;
  final String? bedNumber;
  final DateTime admissionDate;
  final DateTime? expectedDischarge;
  final DateTime? actualDischargeDate;
  final String admittingDoctorId;
  final AdmissionStatus status;
  final int currentDay;
  final bool dischargeBlocked;
  final List<String>? dischargeBlockReasons;

  Admission({
    required this.id,
    required this.patientId,
    required this.hospitalId,
    this.bedNumber,
    required this.admissionDate,
    this.expectedDischarge,
    this.actualDischargeDate,
    required this.admittingDoctorId,
    required this.status,
    required this.currentDay,
    required this.dischargeBlocked,
    this.dischargeBlockReasons,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      hospitalId: json['hospital_id'] as String,
      bedNumber: json['bed_number'] as String?,
      admissionDate: DateTime.parse(json['admission_date'] as String),
      expectedDischarge: json['expected_discharge'] != null
          ? DateTime.parse(json['expected_discharge'] as String)
          : null,
      actualDischargeDate: json['actual_discharge_date'] != null
          ? DateTime.parse(json['actual_discharge_date'] as String)
          : null,
      admittingDoctorId: json['admitting_doctor_id'] as String,
      status: AdmissionStatus.fromJson(json['status'] as String),
      currentDay: json['current_day'] as int? ?? 1,
      dischargeBlocked: json['discharge_blocked'] as bool? ?? false,
      dischargeBlockReasons: (json['discharge_block_reasons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'hospital_id': hospitalId,
      'bed_number': bedNumber,
      'admission_date': admissionDate.toIso8601String(),
      'expected_discharge': expectedDischarge?.toIso8601String(),
      'actual_discharge_date': actualDischargeDate?.toIso8601String(),
      'admitting_doctor_id': admittingDoctorId,
      'status': status.toJson,
      'current_day': currentDay,
      'discharge_blocked': dischargeBlocked,
      'discharge_block_reasons': dischargeBlockReasons,
    };
  }

  Admission copyWith({
    String? id,
    String? patientId,
    String? hospitalId,
    String? bedNumber,
    DateTime? admissionDate,
    DateTime? expectedDischarge,
    DateTime? actualDischargeDate,
    String? admittingDoctorId,
    AdmissionStatus? status,
    int? currentDay,
    bool? dischargeBlocked,
    List<String>? dischargeBlockReasons,
  }) {
    return Admission(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      hospitalId: hospitalId ?? this.hospitalId,
      bedNumber: bedNumber ?? this.bedNumber,
      admissionDate: admissionDate ?? this.admissionDate,
      expectedDischarge: expectedDischarge ?? this.expectedDischarge,
      actualDischargeDate: actualDischargeDate ?? this.actualDischargeDate,
      admittingDoctorId: admittingDoctorId ?? this.admittingDoctorId,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      dischargeBlocked: dischargeBlocked ?? this.dischargeBlocked,
      dischargeBlockReasons:
          dischargeBlockReasons ?? this.dischargeBlockReasons,
    );
  }

  @override
  String toString() =>
      'Admission(id: $id, patientId: $patientId, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Admission && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
