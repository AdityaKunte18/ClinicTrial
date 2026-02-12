enum GuidelineStatus {
  pending,
  accepted,
  rejected,
  deferred;

  String get toJson => name;

  static GuidelineStatus fromJson(String value) {
    return GuidelineStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown GuidelineStatus: $value'),
    );
  }
}

class GuidelineUpdate {
  final String id;
  final DateTime scanDate;
  final String source;
  final String? sourceUrl;
  final String affectedSyndromeId;
  final String? affectedField;
  final String changeSummary;
  final String? currentValue;
  final String? proposedValue;
  final GuidelineStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewerNotes;

  GuidelineUpdate({
    required this.id,
    required this.scanDate,
    required this.source,
    this.sourceUrl,
    required this.affectedSyndromeId,
    this.affectedField,
    required this.changeSummary,
    this.currentValue,
    this.proposedValue,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewerNotes,
  });

  factory GuidelineUpdate.fromJson(Map<String, dynamic> json) {
    return GuidelineUpdate(
      id: json['id'] as String,
      scanDate: DateTime.parse(json['scan_date'] as String),
      source: json['source'] as String,
      sourceUrl: json['source_url'] as String?,
      affectedSyndromeId: json['affected_syndrome_id'] as String,
      affectedField: json['affected_field'] as String?,
      changeSummary: json['change_summary'] as String,
      currentValue: json['current_value'] as String?,
      proposedValue: json['proposed_value'] as String?,
      status: GuidelineStatus.fromJson(json['status'] as String),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewerNotes: json['reviewer_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scan_date': scanDate.toIso8601String(),
      'source': source,
      'source_url': sourceUrl,
      'affected_syndrome_id': affectedSyndromeId,
      'affected_field': affectedField,
      'change_summary': changeSummary,
      'current_value': currentValue,
      'proposed_value': proposedValue,
      'status': status.toJson,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewer_notes': reviewerNotes,
    };
  }

  GuidelineUpdate copyWith({
    String? id,
    DateTime? scanDate,
    String? source,
    String? sourceUrl,
    String? affectedSyndromeId,
    String? affectedField,
    String? changeSummary,
    String? currentValue,
    String? proposedValue,
    GuidelineStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewerNotes,
  }) {
    return GuidelineUpdate(
      id: id ?? this.id,
      scanDate: scanDate ?? this.scanDate,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      affectedSyndromeId: affectedSyndromeId ?? this.affectedSyndromeId,
      affectedField: affectedField ?? this.affectedField,
      changeSummary: changeSummary ?? this.changeSummary,
      currentValue: currentValue ?? this.currentValue,
      proposedValue: proposedValue ?? this.proposedValue,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
    );
  }

  @override
  String toString() =>
      'GuidelineUpdate(id: $id, source: $source, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GuidelineUpdate && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
