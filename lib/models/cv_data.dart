import 'package:cv_generator/models/education.dart';
import 'package:cv_generator/models/work_experience.dart';

class CvData {
  String fullName;
  String email;
  String phoneNumber;
  List<WorkExperience> workExperience;
  List<Education> education;
  List<String> skills;
  String selectedThemeId;

  CvData({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<String>? skills,
    this.selectedThemeId = 'theme_1',
  })  : workExperience = workExperience ?? <WorkExperience>[],
        education = education ?? <Education>[],
        skills = skills ?? <String>[];

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'workExperience': workExperience.map((w) => w.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills,
      'selectedThemeId': selectedThemeId,
    };
  }

  static CvData fromJson(Map<String, dynamic> json) {
    return CvData(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      workExperience:
          (json['workExperience'] as List<dynamic>?)
                  ?.map((e) => WorkExperience.fromJson(
                      e as Map<String, dynamic>?))
                  .toList() ??
              <WorkExperience>[],
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          <Education>[],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      selectedThemeId: json['selectedThemeId'] ?? 'theme_1',
    );
  }

  CvData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<String>? skills,
    String? selectedThemeId,
  }) {
    return CvData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      workExperience:
          workExperience ?? List<WorkExperience>.from(this.workExperience),
      education: education ?? List<Education>.from(this.education),
      skills: skills ?? List<String>.from(this.skills),
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
    );
  }

  @override
  String toString() =>
      'CvData(fullName: $fullName, email: $email, phoneNumber: $phoneNumber, theme: $selectedThemeId, workExperience: ${workExperience.length}, education: ${education.length}, skills: ${skills.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CvData) return false;
    return fullName == other.fullName &&
        email == other.email &&
        phoneNumber == other.phoneNumber &&
        selectedThemeId == other.selectedThemeId &&
        _listEquals(workExperience, other.workExperience) &&
        _listEquals(education, other.education) &&
        _listEquals(skills, other.skills);
  }

  @override
  int get hashCode =>
      fullName.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      selectedThemeId.hashCode ^
      _deepHash(workExperience) ^
      _deepHash(education) ^
      _deepHash(skills);

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
