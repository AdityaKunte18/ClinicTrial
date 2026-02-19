enum WorkupDomain {
  history,
  examination,
  blood,
  radiology,
  treatment,
  referral,
  schemePrereq,
  discharge;

  String get toJson {
    switch (this) {
      case WorkupDomain.schemePrereq:
        return 'scheme_prereq';
      default:
        return name;
    }
  }

  static WorkupDomain fromJson(String value) {
    if (value == 'scheme_prereq') return WorkupDomain.schemePrereq;
    return WorkupDomain.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown WorkupDomain: $value'),
    );
  }
}

enum WorkupStatus {
  pending,
  ordered,
  sent,
  resulted,
  reviewed,
  done,
  notApplicable,
  deferredOpd;

  String get toJson {
    switch (this) {
      case WorkupStatus.notApplicable:
        return 'not_applicable';
      case WorkupStatus.deferredOpd:
        return 'deferred_opd';
      default:
        return name;
    }
  }

  static WorkupStatus fromJson(String value) {
    switch (value) {
      case 'not_applicable':
        return WorkupStatus.notApplicable;
      case 'deferred_opd':
        return WorkupStatus.deferredOpd;
      default:
        return WorkupStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => throw ArgumentError('Unknown WorkupStatus: $value'),
        );
    }
  }
}

enum ReminderLevel {
  none,
  nudge,
  firm,
  escalation,
  block;

  String get toJson => name;

  static ReminderLevel fromJson(String value) {
    return ReminderLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown ReminderLevel: $value'),
    );
  }
}

class WorkupItem {
  final String id;
  final String admissionId;
  final String? syndromeId;
  final WorkupDomain domain;
  final String itemText;
  final bool isRequired;
  final bool isHardBlock;
  final int? targetDay;
  final WorkupStatus status;
  final String? resultValue;
  final String? completedBy;
  final DateTime? completedAt;
  final String? notes;
  final bool aiSuggested;
  final ReminderLevel reminderLevel;
  final String? category;
  final int sortOrder;
  final String? templateItemId;
  final int? originalTargetDay;
  final String? resultOptionId;
  final String? classificationEventId;

  WorkupItem({
    required this.id,
    required this.admissionId,
    this.syndromeId,
    required this.domain,
    required this.itemText,
    required this.isRequired,
    required this.isHardBlock,
    this.targetDay,
    required this.status,
    this.resultValue,
    this.completedBy,
    this.completedAt,
    this.notes,
    required this.aiSuggested,
    required this.reminderLevel,
    this.category,
    required this.sortOrder,
    this.templateItemId,
    this.originalTargetDay,
    this.resultOptionId,
    this.classificationEventId,
  });

  factory WorkupItem.fromJson(Map<String, dynamic> json) {
    return WorkupItem(
      id: json['id'] as String,
      admissionId: json['admission_id'] as String,
      syndromeId: json['syndrome_id'] as String?,
      domain: WorkupDomain.fromJson(json['domain'] as String),
      itemText: json['item_text'] as String,
      isRequired: json['is_required'] as bool? ?? false,
      isHardBlock: json['is_hard_block'] as bool? ?? false,
      targetDay: json['target_day'] as int?,
      status: WorkupStatus.fromJson(json['status'] as String),
      resultValue: json['result_value'] as String?,
      completedBy: json['completed_by'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      notes: json['notes'] as String?,
      aiSuggested: json['ai_suggested'] as bool? ?? false,
      reminderLevel:
          ReminderLevel.fromJson(json['reminder_level'] as String? ?? 'none'),
      category: json['category'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      templateItemId: json['template_item_id'] as String?,
      originalTargetDay: json['original_target_day'] as int?,
      resultOptionId: json['result_option_id'] as String?,
      classificationEventId: json['classification_event_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admission_id': admissionId,
      'syndrome_id': syndromeId,
      'domain': domain.toJson,
      'item_text': itemText,
      'is_required': isRequired,
      'is_hard_block': isHardBlock,
      'target_day': targetDay,
      'status': status.toJson,
      'result_value': resultValue,
      'completed_by': completedBy,
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'ai_suggested': aiSuggested,
      'reminder_level': reminderLevel.toJson,
      'category': category,
      'sort_order': sortOrder,
      'template_item_id': templateItemId,
      'original_target_day': originalTargetDay,
      'result_option_id': resultOptionId,
      'classification_event_id': classificationEventId,
    };
  }

  WorkupItem copyWith({
    String? id,
    String? admissionId,
    String? syndromeId,
    WorkupDomain? domain,
    String? itemText,
    bool? isRequired,
    bool? isHardBlock,
    int? targetDay,
    WorkupStatus? status,
    String? resultValue,
    String? completedBy,
    DateTime? completedAt,
    String? notes,
    bool? aiSuggested,
    ReminderLevel? reminderLevel,
    String? category,
    int? sortOrder,
    String? templateItemId,
    int? originalTargetDay,
    String? resultOptionId,
    String? classificationEventId,
  }) {
    return WorkupItem(
      id: id ?? this.id,
      admissionId: admissionId ?? this.admissionId,
      syndromeId: syndromeId ?? this.syndromeId,
      domain: domain ?? this.domain,
      itemText: itemText ?? this.itemText,
      isRequired: isRequired ?? this.isRequired,
      isHardBlock: isHardBlock ?? this.isHardBlock,
      targetDay: targetDay ?? this.targetDay,
      status: status ?? this.status,
      resultValue: resultValue ?? this.resultValue,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      aiSuggested: aiSuggested ?? this.aiSuggested,
      reminderLevel: reminderLevel ?? this.reminderLevel,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      templateItemId: templateItemId ?? this.templateItemId,
      originalTargetDay: originalTargetDay ?? this.originalTargetDay,
      resultOptionId: resultOptionId ?? this.resultOptionId,
      classificationEventId: classificationEventId ?? this.classificationEventId,
    );
  }

  @override
  String toString() =>
      'WorkupItem(id: $id, domain: ${domain.name}, itemText: $itemText, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkupItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
