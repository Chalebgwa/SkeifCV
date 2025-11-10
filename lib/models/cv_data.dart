import 'education.dart';
import 'work_experience.dart';
import 'dart:convert';

class CvData {
  String fullName;
  String email;
  String phone;
  List<WorkExperience> workExperience;
  List<Education> education;
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
      'workExperience': workExperience.map((w) => w.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills,
    };
  }

  static CvData fromJson(Map<String, dynamic> json) {
    return CvData(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      workExperience: (json['workExperience'] as List<dynamic> ?? [])
          .map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic> ?? [])
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic> ?? []).cast<String>(),
    );
  }

  // Convenient copyWith for immutable-style updates
  CvData copyWith({
    String? fullName,
    String? email,
    String? phone,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<String>? skills,
  }) {
    return CvData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      workExperience:
          workExperience ?? List<WorkExperience>.from(this.workExperience),
      education: education ?? List<Education>.from(this.education),
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
}
