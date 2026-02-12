class SchemePackage {
  final String id;
  final String scheme;
  final String specialtyCode;
  final String packageCode;
  final String packageName;
  final int packageAmount;
  final bool governmentReserved;
  final Map<String, dynamic>? prerequisites;
  final List<String>? linkedSyndromes;
  final bool isActive;
  final int version;
  final DateTime? lastVerified;

  SchemePackage({
    required this.id,
    required this.scheme,
    required this.specialtyCode,
    required this.packageCode,
    required this.packageName,
    required this.packageAmount,
    required this.governmentReserved,
    this.prerequisites,
    this.linkedSyndromes,
    required this.isActive,
    required this.version,
    this.lastVerified,
  });

  factory SchemePackage.fromJson(Map<String, dynamic> json) {
    return SchemePackage(
      id: json['id'] as String,
      scheme: json['scheme'] as String,
      specialtyCode: json['specialty_code'] as String,
      packageCode: json['package_code'] as String,
      packageName: json['package_name'] as String,
      packageAmount: json['package_amount'] as int,
      governmentReserved: json['government_reserved'] as bool? ?? false,
      prerequisites: json['prerequisites'] != null
          ? Map<String, dynamic>.from(json['prerequisites'] as Map)
          : null,
      linkedSyndromes: (json['linked_syndromes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
      lastVerified: json['last_verified'] != null
          ? DateTime.parse(json['last_verified'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheme': scheme,
      'specialty_code': specialtyCode,
      'package_code': packageCode,
      'package_name': packageName,
      'package_amount': packageAmount,
      'government_reserved': governmentReserved,
      'prerequisites': prerequisites,
      'linked_syndromes': linkedSyndromes,
      'is_active': isActive,
      'version': version,
      'last_verified': lastVerified?.toIso8601String(),
    };
  }

  SchemePackage copyWith({
    String? id,
    String? scheme,
    String? specialtyCode,
    String? packageCode,
    String? packageName,
    int? packageAmount,
    bool? governmentReserved,
    Map<String, dynamic>? prerequisites,
    List<String>? linkedSyndromes,
    bool? isActive,
    int? version,
    DateTime? lastVerified,
  }) {
    return SchemePackage(
      id: id ?? this.id,
      scheme: scheme ?? this.scheme,
      specialtyCode: specialtyCode ?? this.specialtyCode,
      packageCode: packageCode ?? this.packageCode,
      packageName: packageName ?? this.packageName,
      packageAmount: packageAmount ?? this.packageAmount,
      governmentReserved: governmentReserved ?? this.governmentReserved,
      prerequisites: prerequisites ?? this.prerequisites,
      linkedSyndromes: linkedSyndromes ?? this.linkedSyndromes,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      lastVerified: lastVerified ?? this.lastVerified,
    );
  }

  @override
  String toString() =>
      'SchemePackage(id: $id, scheme: $scheme, packageCode: $packageCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SchemePackage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
