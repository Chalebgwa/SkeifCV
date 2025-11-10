import 'package:cv_generator/models/education.dart';
import 'package:cv_generator/models/work_experience.dart';
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
}
