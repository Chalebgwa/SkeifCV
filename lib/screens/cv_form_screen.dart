import 'package:cv_generator/models/education.dart';
import 'package:cv_generator/models/work_experience.dart';
import 'package:cv_generator/providers/cv_form_provider.dart';
import 'package:cv_generator/screens/pdf_preview_screen.dart';
import 'package:cv_generator/services/pdf_generator.dart';
import 'package:cv_generator/widgets/custom_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CvFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create CV'),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final pdfData = await PdfGenerator.generateCv(provider.cvData);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfPreviewScreen(pdfData: pdfData),
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomExpansionTile(
                title: 'Personal Details',
                initiallyExpanded: true,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    onSaved: (value) => provider.updateFullName(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    onSaved: (value) => provider.updateEmail(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    onSaved: (value) => provider.updatePhone(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              CustomExpansionTile(
                title: 'Work Experience',
                children: _buildWorkExperienceFields(provider),
              ),
              CustomExpansionTile(
                title: 'Education',
                children: _buildEducationFields(provider),
              ),
              CustomExpansionTile(
                title: 'Skills',
                children: _buildSkillsFields(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWorkExperienceFields(CvFormProvider provider) {
    return [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.cvData.workExperience.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Job Title'),
                  onSaved: (value) => provider.cvData.workExperience[index].jobTitle = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Company'),
                  onSaved: (value) => provider.cvData.workExperience[index].company = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dates'),
                  onSaved: (value) => provider.cvData.workExperience[index].dates = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => provider.cvData.workExperience[index].description = value ?? '',
                  maxLines: 3,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => provider.removeWorkExperience(index),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => provider.addWorkExperience(),
          icon: const Icon(Icons.add),
          label: const Text('Add Work Experience'),
        ),
      ),
    ];
  }

  List<Widget> _buildEducationFields(CvFormProvider provider) {
    return [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.cvData.education.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Institution'),
                  onSaved: (value) => provider.cvData.education[index].institution = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Degree'),
                  onSaved: (value) => provider.cvData.education[index].degree = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dates'),
                  onSaved: (value) => provider.cvData.education[index].dates = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => provider.cvData.education[index].description = value ?? '',
                  maxLines: 3,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => provider.removeEducation(index),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => provider.addEducation(),
          icon: const Icon(Icons.add),
          label: const Text('Add Education'),
        ),
      ),
    ];
  }

  List<Widget> _buildSkillsFields(CvFormProvider provider) {
    return [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.cvData.skills.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: provider.cvData.skills[index],
                    decoration: InputDecoration(labelText: 'Skill ${index + 1}'),
                    onSaved: (value) => provider.updateSkill(index, value ?? ''),
                  ),
                ),
                IconButton(
                  onPressed: () => provider.removeSkill(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => provider.addSkill(),
          icon: const Icon(Icons.add),
          label: const Text('Add Skill'),
        ),
      ),
    ];
  }
}
