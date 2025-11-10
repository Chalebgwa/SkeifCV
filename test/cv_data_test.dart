import 'package:cv_generator/models/cv_data.dart';
import 'package:cv_generator/models/education.dart';
import 'package:cv_generator/models/work_experience.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CvData serialization', () {
    test('toJson and fromJson retain typed collections', () {
      final data = CvData(
        fullName: 'Ada Lovelace',
        email: 'ada@example.com',
        phoneNumber: '+44 123 456',
        selectedThemeId: 'theme_custom',
        workExperience: [
          WorkExperience(
            jobTitle: 'Mathematician',
            company: 'Royal Society',
            dates: '1842-1843',
            description: 'Analytical Engine notes',
          ),
        ],
        education: [
          Education(
            institution: 'Self-taught',
            degree: 'Mathematics',
            dates: '1830-1840',
            description: 'Private tutoring',
          ),
        ],
        skills: ['Analysis', 'Algorithms'],
      );

      final json = data.toJson();
      final restored = CvData.fromJson(json);

      expect(restored.fullName, equals('Ada Lovelace'));
      expect(restored.workExperience.single.jobTitle, equals('Mathematician'));
      expect(restored.education.single.institution, equals('Self-taught'));
      expect(restored.skills, containsAll(['Analysis', 'Algorithms']));
      expect(restored.selectedThemeId, equals('theme_custom'));
    });

    test('copyWith creates defensive copies of collections', () {
      final original = CvData(
        workExperience: [
          WorkExperience(jobTitle: 'Engineer'),
        ],
        education: [
          Education(institution: 'MIT'),
        ],
        skills: ['Dart'],
      );

      final copy = original.copyWith(
        workExperience: [
          ...original.workExperience,
          WorkExperience(jobTitle: 'Architect'),
        ],
        education: [
          ...original.education,
          Education(institution: 'Stanford'),
        ],
        skills: [...original.skills, 'Flutter'],
      );

      expect(original.workExperience.length, equals(1));
      expect(copy.workExperience.length, equals(2));
      expect(original.education.length, equals(1));
      expect(copy.education.length, equals(2));
      expect(original.skills.length, equals(1));
      expect(copy.skills.length, equals(2));
    });
  });
}
