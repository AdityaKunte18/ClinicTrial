class SyndromeProtocol {
  final String id;
  final String code;
  final String name;
  final String? category;
  final int version;
  final bool isActive;
  final Map<String, dynamic> baseTemplate;
  final String? createdBy;
  final DateTime updatedAt;

  SyndromeProtocol({
    required this.id,
    required this.code,
    required this.name,
    this.category,
    required this.version,
    required this.isActive,
    required this.baseTemplate,
    this.createdBy,
    required this.updatedAt,
  });

  factory SyndromeProtocol.fromJson(Map<String, dynamic> json) {
    return SyndromeProtocol(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      version: json['version'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      baseTemplate:
          Map<String, dynamic>.from(json['base_template'] as Map? ?? {}),
      createdBy: json['created_by'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'version': version,
      'is_active': isActive,
      'base_template': baseTemplate,
      'created_by': createdBy,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SyndromeProtocol copyWith({
    String? id,
    String? code,
    String? name,
    String? category,
    int? version,
    bool? isActive,
    Map<String, dynamic>? baseTemplate,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return SyndromeProtocol(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      baseTemplate: baseTemplate ?? this.baseTemplate,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'SyndromeProtocol(id: $id, code: $code, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyndromeProtocol && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
