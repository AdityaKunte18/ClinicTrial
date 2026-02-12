import 'workup_item.dart';

class Reminder {
  final String id;
  final String workupItemId;
  final String admissionId;
  final String targetUserId;
  final ReminderLevel level;
  final String message;
  final String? aiContext;
  final DateTime? sentAt;
  final bool acknowledged;
  final DateTime? acknowledgedAt;

  Reminder({
    required this.id,
    required this.workupItemId,
    required this.admissionId,
    required this.targetUserId,
    required this.level,
    required this.message,
    this.aiContext,
    this.sentAt,
    required this.acknowledged,
    this.acknowledgedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      workupItemId: json['workup_item_id'] as String,
      admissionId: json['admission_id'] as String,
      targetUserId: json['target_user_id'] as String,
      level: ReminderLevel.fromJson(json['level'] as String),
      message: json['message'] as String,
      aiContext: json['ai_context'] as String?,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      acknowledged: json['acknowledged'] as bool? ?? false,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workup_item_id': workupItemId,
      'admission_id': admissionId,
      'target_user_id': targetUserId,
      'level': level.toJson,
      'message': message,
      'ai_context': aiContext,
      'sent_at': sentAt?.toIso8601String(),
      'acknowledged': acknowledged,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
    };
  }

  Reminder copyWith({
    String? id,
    String? workupItemId,
    String? admissionId,
    String? targetUserId,
    ReminderLevel? level,
    String? message,
    String? aiContext,
    DateTime? sentAt,
    bool? acknowledged,
    DateTime? acknowledgedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      workupItemId: workupItemId ?? this.workupItemId,
      admissionId: admissionId ?? this.admissionId,
      targetUserId: targetUserId ?? this.targetUserId,
      level: level ?? this.level,
      message: message ?? this.message,
      aiContext: aiContext ?? this.aiContext,
      sentAt: sentAt ?? this.sentAt,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }

  @override
  String toString() =>
      'Reminder(id: $id, level: ${level.name}, acknowledged: $acknowledged)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Reminder && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
