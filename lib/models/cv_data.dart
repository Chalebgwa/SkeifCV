import 'package:cv_generator/models/education.dart';
import 'package:cv_generator/models/work_experience.dart';

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
}
