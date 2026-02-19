class AdmissionSyndrome {
  final String id;
  final String admissionId;
  final String syndromeId;
  final bool isPrimary;
  final String detectedBy;
  final double? confidenceScore;
  final String? activeClassificationId;

  AdmissionSyndrome({
    required this.id,
    required this.admissionId,
    required this.syndromeId,
    required this.isPrimary,
    required this.detectedBy,
    this.confidenceScore,
    this.activeClassificationId,
  });

  factory AdmissionSyndrome.fromJson(Map<String, dynamic> json) {
    return AdmissionSyndrome(
      id: json['id'] as String,
      admissionId: json['admission_id'] as String,
      syndromeId: json['syndrome_id'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      detectedBy: json['detected_by'] as String,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      activeClassificationId: json['active_classification_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admission_id': admissionId,
      'syndrome_id': syndromeId,
      'is_primary': isPrimary,
      'detected_by': detectedBy,
      'confidence_score': confidenceScore,
      'active_classification_id': activeClassificationId,
    };
  }

  AdmissionSyndrome copyWith({
    String? id,
    String? admissionId,
    String? syndromeId,
    bool? isPrimary,
    String? detectedBy,
    double? confidenceScore,
    String? activeClassificationId,
  }) {
    return AdmissionSyndrome(
      id: id ?? this.id,
      admissionId: admissionId ?? this.admissionId,
      syndromeId: syndromeId ?? this.syndromeId,
      isPrimary: isPrimary ?? this.isPrimary,
      detectedBy: detectedBy ?? this.detectedBy,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      activeClassificationId: activeClassificationId ?? this.activeClassificationId,
    );
  }

  @override
  String toString() =>
      'AdmissionSyndrome(id: $id, admissionId: $admissionId, syndromeId: $syndromeId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdmissionSyndrome && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
