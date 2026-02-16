enum UserRole {
  admin,
  consultant,
  jr3,
  jr2,
  jr1;

  String get toJson => name;

  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown UserRole: $value'),
    );
  }
}

class AppUser {
  final String id;
  /// Supabase Auth uid — only set in production mode.
  final String? authId;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String hospitalId;
  final String? unit;
  final DateTime createdAt;

  AppUser({
    required this.id,
    this.authId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.hospitalId,
    this.unit,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromJson(json['role'] as String),
      hospitalId: json['hospital_id'] as String,
      unit: json['unit'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (authId != null) 'auth_id': authId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toJson,
      'hospital_id': hospitalId,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? authId,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? hospitalId,
    String? unit,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      hospitalId: hospitalId ?? this.hospitalId,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'AppUser(id: $id, name: $name, role: ${role.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
