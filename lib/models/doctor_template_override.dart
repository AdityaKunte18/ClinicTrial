class DoctorTemplateOverride {
  final String id;
  final String doctorId;
  final String syndromeId;
  final Map<String, dynamic> overrideTemplate;
  final int version;

  DoctorTemplateOverride({
    required this.id,
    required this.doctorId,
    required this.syndromeId,
    required this.overrideTemplate,
    required this.version,
  });

  factory DoctorTemplateOverride.fromJson(Map<String, dynamic> json) {
    return DoctorTemplateOverride(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      syndromeId: json['syndrome_id'] as String,
      overrideTemplate:
          Map<String, dynamic>.from(json['override_template'] as Map? ?? {}),
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'syndrome_id': syndromeId,
      'override_template': overrideTemplate,
      'version': version,
    };
  }

  DoctorTemplateOverride copyWith({
    String? id,
    String? doctorId,
    String? syndromeId,
    Map<String, dynamic>? overrideTemplate,
    int? version,
  }) {
    return DoctorTemplateOverride(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      syndromeId: syndromeId ?? this.syndromeId,
      overrideTemplate: overrideTemplate ?? this.overrideTemplate,
      version: version ?? this.version,
    );
  }

  @override
  String toString() =>
      'DoctorTemplateOverride(id: $id, doctorId: $doctorId, syndromeId: $syndromeId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorTemplateOverride && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
