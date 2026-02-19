class ClassificationEvent {
  final String id;
  final String admissionId;
  final String syndromeId;
  final String classificationRuleId;
  final String classificationName;
  final String trigger; // 'auto', 'doctor_selected', 'doctor_override'
  final String? previousClassification;
  final String? overrideReason;
  final String? triggeredByItemId;
  final DateTime createdAt;
  final String? createdBy;

  ClassificationEvent({
    required this.id,
    required this.admissionId,
    required this.syndromeId,
    required this.classificationRuleId,
    required this.classificationName,
    required this.trigger,
    this.previousClassification,
    this.overrideReason,
    this.triggeredByItemId,
    required this.createdAt,
    this.createdBy,
  });

  factory ClassificationEvent.fromJson(Map<String, dynamic> json) {
    return ClassificationEvent(
      id: json['id'] as String,
      admissionId: json['admission_id'] as String,
      syndromeId: json['syndrome_id'] as String,
      classificationRuleId: json['classification_rule_id'] as String,
      classificationName: json['classification_name'] as String,
      trigger: json['trigger'] as String,
      previousClassification: json['previous_classification'] as String?,
      overrideReason: json['override_reason'] as String?,
      triggeredByItemId: json['triggered_by_item_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admission_id': admissionId,
      'syndrome_id': syndromeId,
      'classification_rule_id': classificationRuleId,
      'classification_name': classificationName,
      'trigger': trigger,
      'previous_classification': previousClassification,
      'override_reason': overrideReason,
      'triggered_by_item_id': triggeredByItemId,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  @override
  String toString() =>
      'ClassificationEvent(id: $id, name: $classificationName, trigger: $trigger)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
