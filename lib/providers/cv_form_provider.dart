import 'package:cv_generator/models/cv_data.dart';
import 'package:cv_generator/models/education.dart';
import 'package:cv_generator/models/work_experience.dart';
import 'package:flutter/material.dart';

class CvFormProvider extends ChangeNotifier {
  final CvData _cvData = CvData();

  CvData get cvData => _cvData;

  void updateFullName(String fullName) {
    _cvData.fullName = fullName;
    notifyListeners();
  }

  void updateEmail(String email) {
    _cvData.email = email;
    notifyListeners();
  }

  void updatePhone(String phone) {
    _cvData.phone = phone;
    notifyListeners();
  }

  void addWorkExperience() {
    _cvData.workExperience.add(WorkExperience());
    notifyListeners();
  }

  void removeWorkExperience(int index) {
    _cvData.workExperience.removeAt(index);
    notifyListeners();
  }

  void updateWorkExperience(int index, WorkExperience experience) {
    _cvData.workExperience[index] = experience;
    notifyListeners();
  }

  void addEducation() {
    _cvData.education.add(Education());
    notifyListeners();
  }

  void removeEducation(int index) {
    _cvData.education.removeAt(index);
    notifyListeners();
  }

  void updateEducation(int index, Education education) {
    _cvData.education[index] = education;
    notifyListeners();
  }

  void addSkill() {
    _cvData.skills.add('');
    notifyListeners();
  }

  void removeSkill(int index) {
    _cvData.skills.removeAt(index);
    notifyListeners();
  }

  void updateSkill(int index, String value) {
    _cvData.skills[index] = value;
    notifyListeners();
  }
}
