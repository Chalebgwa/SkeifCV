class CvData {
  String fullName;
  String email;
  String phone;
  // Use dynamic lists so we don't require specific methods to exist at compile time.
  List<dynamic> workExperience;
  List<dynamic> education;
  List<String> skills;

  CvData({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.workExperience = const [],
    this.education = const [],
    this.skills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      // Attempt runtime serialization: if item has toJson, call it; otherwise pass through maps or strings.
      'workExperience': workExperience.map((w) => _serializable(w)).toList(),
      'education': education.map((e) => _serializable(e)).toList(),
      'skills': skills,
    };
  }

  static CvData fromJson(Map<String, dynamic> json) {
    return CvData(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      // Use nullable casts to avoid dead null-aware expressions and keep parsed entries as maps/dynamics.
      workExperience:
          (json['workExperience'] as List<dynamic>?)?.map((e) => e).toList() ??
          [],
      education:
          (json['education'] as List<dynamic>?)?.map((e) => e).toList() ?? [],
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Convenient copyWith for immutable-style updates
  CvData copyWith({
    String? fullName,
    String? email,
    String? phone,
    List<dynamic>? workExperience,
    List<dynamic>? education,
    List<String>? skills,
  }) {
    return CvData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      workExperience: workExperience ?? List<dynamic>.from(this.workExperience),
      education: education ?? List<dynamic>.from(this.education),
      skills: skills ?? List<String>.from(this.skills),
    );
  }

  @override
  String toString() =>
      'CvData(fullName: $fullName, email: $email, phone: $phone, workExperience: ${workExperience.length}, education: ${education.length}, skills: ${skills.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CvData) return false;
    return fullName == other.fullName &&
        email == other.email &&
        phone == other.phone &&
        _listEquals(workExperience, other.workExperience) &&
        _listEquals(education, other.education) &&
        _listEquals(skills, other.skills);
  }

  @override
  int get hashCode =>
      fullName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      _deepHash(workExperience) ^
      _deepHash(education) ^
      _deepHash(skills);

  // Small helpers to avoid adding new dependencies
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _deepHash<T>(List<T> list) {
    var hash = 0;
    for (var item in list) {
      hash = 0x1fffffff & (hash + item.hashCode);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= (hash >> 6);
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= (hash >> 11);
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return hash;
  }

  // Try to serialize an arbitrary object at runtime:
  static dynamic _serializable(dynamic o) {
    if (o == null) return null;
    if (o is Map) return o;
    try {
      // dynamic call: if the object provides toJson at runtime, this will work.
      return (o as dynamic).toJson();
    } catch (_) {
      // fallback to String representation
      return o.toString();
    }
  }
}
