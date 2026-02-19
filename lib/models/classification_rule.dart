class ClassificationCriterion {
  final String templateItemId;
  final String operator;
  final dynamic value;

  ClassificationCriterion({
    required this.templateItemId,
    required this.operator,
    required this.value,
  });

  factory ClassificationCriterion.fromJson(Map<String, dynamic> json) {
    return ClassificationCriterion(
      templateItemId: json['template_item_id'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_item_id': templateItemId,
      'operator': operator,
      'value': value,
    };
  }
}

class GuidelineReference {
  final String name;
  final String? section;
  final String? url;

  GuidelineReference({
    required this.name,
    this.section,
    this.url,
  });

  factory GuidelineReference.fromJson(Map<String, dynamic> json) {
    return GuidelineReference(
      name: json['name'] as String,
      section: json['section'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'section': section,
      'url': url,
    };
  }
}

class ClassificationRule {
  final String id;
  final String syndromeId;
  final String classificationName;
  final String classificationCode;
  final List<ClassificationCriterion> criteria;
  final List<GuidelineReference> guidelines;
  final Map<String, dynamic>? additionalWorkupItems;
  final Map<String, dynamic>? treatmentOverrides;
  final int priority;

  ClassificationRule({
    required this.id,
    required this.syndromeId,
    required this.classificationName,
    required this.classificationCode,
    required this.criteria,
    required this.guidelines,
    this.additionalWorkupItems,
    this.treatmentOverrides,
    required this.priority,
  });

  factory ClassificationRule.fromJson(Map<String, dynamic> json, String syndromeId) {
    return ClassificationRule(
      id: json['id'] as String,
      syndromeId: syndromeId,
      classificationName: json['name'] as String,
      classificationCode: json['code'] as String,
      criteria: (json['criteria'] as List<dynamic>?)
              ?.map((c) =>
                  ClassificationCriterion.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      guidelines: (json['guidelines'] as List<dynamic>?)
              ?.map(
                  (g) => GuidelineReference.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      additionalWorkupItems:
          json['additional_workup'] as Map<String, dynamic>?,
      treatmentOverrides:
          json['treatment_overrides'] as Map<String, dynamic>?,
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syndrome_id': syndromeId,
      'name': classificationName,
      'code': classificationCode,
      'criteria': criteria.map((c) => c.toJson()).toList(),
      'guidelines': guidelines.map((g) => g.toJson()).toList(),
      'additional_workup': additionalWorkupItems,
      'treatment_overrides': treatmentOverrides,
      'priority': priority,
    };
  }

  @override
  String toString() =>
      'ClassificationRule(id: $id, name: $classificationName, code: $classificationCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ClassificationRule && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
