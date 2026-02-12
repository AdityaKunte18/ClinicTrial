class Patient {
  final String id;
  final String uhid;
  final String name;
  final int age;
  final String sex;
  final String? phone;
  final String? rationCardType;
  final bool pmjayEligible;
  final bool mjpjayEligible;
  final String? ayushmanCardNumber;

  Patient({
    required this.id,
    required this.uhid,
    required this.name,
    required this.age,
    required this.sex,
    this.phone,
    this.rationCardType,
    required this.pmjayEligible,
    required this.mjpjayEligible,
    this.ayushmanCardNumber,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      uhid: json['uhid'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      phone: json['phone'] as String?,
      rationCardType: json['ration_card_type'] as String?,
      pmjayEligible: json['pmjay_eligible'] as bool? ?? false,
      mjpjayEligible: json['mjpjay_eligible'] as bool? ?? false,
      ayushmanCardNumber: json['ayushman_card_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uhid': uhid,
      'name': name,
      'age': age,
      'sex': sex,
      'phone': phone,
      'ration_card_type': rationCardType,
      'pmjay_eligible': pmjayEligible,
      'mjpjay_eligible': mjpjayEligible,
      'ayushman_card_number': ayushmanCardNumber,
    };
  }

  Patient copyWith({
    String? id,
    String? uhid,
    String? name,
    int? age,
    String? sex,
    String? phone,
    String? rationCardType,
    bool? pmjayEligible,
    bool? mjpjayEligible,
    String? ayushmanCardNumber,
  }) {
    return Patient(
      id: id ?? this.id,
      uhid: uhid ?? this.uhid,
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      phone: phone ?? this.phone,
      rationCardType: rationCardType ?? this.rationCardType,
      pmjayEligible: pmjayEligible ?? this.pmjayEligible,
      mjpjayEligible: mjpjayEligible ?? this.mjpjayEligible,
      ayushmanCardNumber: ayushmanCardNumber ?? this.ayushmanCardNumber,
    );
  }

  @override
  String toString() => 'Patient(id: $id, uhid: $uhid, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Patient && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
