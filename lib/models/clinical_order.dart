enum OrderType {
  investigation,
  treatment,
  radiology,
  referral,
  diet,
  nursing;

  String get toJson => name;

  static OrderType fromJson(String value) {
    return OrderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown OrderType: $value'),
    );
  }
}

enum OrderStatus {
  draft,
  confirmed,
  sent,
  executed,
  cancelled;

  String get toJson => name;

  static OrderStatus fromJson(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown OrderStatus: $value'),
    );
  }
}

class ClinicalOrder {
  final String id;
  final String? workupItemId;
  final String admissionId;
  final OrderType orderType;
  final String orderText;
  final Map<String, dynamic>? details;
  final OrderStatus status;
  final String? orderedBy;
  final String generatedBy;

  ClinicalOrder({
    required this.id,
    this.workupItemId,
    required this.admissionId,
    required this.orderType,
    required this.orderText,
    this.details,
    required this.status,
    this.orderedBy,
    required this.generatedBy,
  });

  factory ClinicalOrder.fromJson(Map<String, dynamic> json) {
    return ClinicalOrder(
      id: json['id'] as String,
      workupItemId: json['workup_item_id'] as String?,
      admissionId: json['admission_id'] as String,
      orderType: OrderType.fromJson(json['order_type'] as String),
      orderText: json['order_text'] as String,
      details: json['details'] != null
          ? Map<String, dynamic>.from(json['details'] as Map)
          : null,
      status: OrderStatus.fromJson(json['status'] as String),
      orderedBy: json['ordered_by'] as String?,
      generatedBy: json['generated_by'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workup_item_id': workupItemId,
      'admission_id': admissionId,
      'order_type': orderType.toJson,
      'order_text': orderText,
      'details': details,
      'status': status.toJson,
      'ordered_by': orderedBy,
      'generated_by': generatedBy,
    };
  }

  ClinicalOrder copyWith({
    String? id,
    String? workupItemId,
    String? admissionId,
    OrderType? orderType,
    String? orderText,
    Map<String, dynamic>? details,
    OrderStatus? status,
    String? orderedBy,
    String? generatedBy,
  }) {
    return ClinicalOrder(
      id: id ?? this.id,
      workupItemId: workupItemId ?? this.workupItemId,
      admissionId: admissionId ?? this.admissionId,
      orderType: orderType ?? this.orderType,
      orderText: orderText ?? this.orderText,
      details: details ?? this.details,
      status: status ?? this.status,
      orderedBy: orderedBy ?? this.orderedBy,
      generatedBy: generatedBy ?? this.generatedBy,
    );
  }

  @override
  String toString() =>
      'ClinicalOrder(id: $id, orderType: ${orderType.name}, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ClinicalOrder && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
