class ResultOption {
  final String id;
  final String templateItemId;
  final String label;
  final String? value;
  final int sortOrder;

  ResultOption({
    required this.id,
    required this.templateItemId,
    required this.label,
    this.value,
    required this.sortOrder,
  });

  factory ResultOption.fromJson(Map<String, dynamic> json) {
    return ResultOption(
      id: json['id'] as String,
      templateItemId: json['template_item_id'] as String,
      label: json['label'] as String,
      value: json['value'] as String?,
      sortOrder: json['sort'] as int? ?? json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_item_id': templateItemId,
      'label': label,
      'value': value,
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() => 'ResultOption(id: $id, label: $label, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ResultOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
