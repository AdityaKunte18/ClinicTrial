enum HospitalType {
  government,
  municipal,
  teaching,
  private_;

  String get toJson {
    if (this == HospitalType.private_) return 'private';
    return name;
  }

  static HospitalType fromJson(String value) {
    if (value == 'private') return HospitalType.private_;
    return HospitalType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown HospitalType: $value'),
    );
  }
}

class Hospital {
  final String id;
  final String name;
  final String city;
  final HospitalType type;
  final bool mjpjayEmpanelled;
  final bool pmjayEmpanelled;

  Hospital({
    required this.id,
    required this.name,
    required this.city,
    required this.type,
    required this.mjpjayEmpanelled,
    required this.pmjayEmpanelled,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      type: HospitalType.fromJson(json['type'] as String),
      mjpjayEmpanelled: json['mjpjay_empanelled'] as bool? ?? false,
      pmjayEmpanelled: json['pmjay_empanelled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'type': type.toJson,
      'mjpjay_empanelled': mjpjayEmpanelled,
      'pmjay_empanelled': pmjayEmpanelled,
    };
  }

  Hospital copyWith({
    String? id,
    String? name,
    String? city,
    HospitalType? type,
    bool? mjpjayEmpanelled,
    bool? pmjayEmpanelled,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      type: type ?? this.type,
      mjpjayEmpanelled: mjpjayEmpanelled ?? this.mjpjayEmpanelled,
      pmjayEmpanelled: pmjayEmpanelled ?? this.pmjayEmpanelled,
    );
  }

  @override
  String toString() => 'Hospital(id: $id, name: $name, city: $city)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Hospital && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
