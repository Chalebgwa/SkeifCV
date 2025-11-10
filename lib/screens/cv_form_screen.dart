import 'package:cv_generator/providers/cv_form_provider.dart';
import 'package:cv_generator/screens/pdf_preview_screen.dart';
import 'package:cv_generator/services/pdf_generator.dart';
import 'package:cv_generator/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CvFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create CV', style: AppTextStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: PageTransitionSwitcher(
          transitionBuilder: (
            Widget child,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: Stepper(
            key: ValueKey<int>(_currentStep),
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
              final isLastStep = _currentStep == 4;
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (isLastStep) {
                  _generatePdf(provider);
                } else {
                  setState(() {
                    _currentStep += 1;
                  });
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            steps: _buildSteps(provider),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              final isLastStep = _currentStep == 4;
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? 'Finish & Export' : 'Next'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf(CvFormProvider provider) async {
    final pdfData = await PdfGenerator.generateCv(provider.cvData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(pdfData: pdfData),
      ),
    );
  }

  List<Step> _buildSteps(CvFormProvider provider) {
    return [
      Step(
        title: const Text('Personal'),
        content: _buildPersonalDetailsForm(provider),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Experience'),
        content: Column(
          children: _buildWorkExperienceFields(provider),
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Education'),
        content: Column(
          children: _buildEducationFields(provider),
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Skills'),
        content: Column(
          children: _buildSkillsFields(provider),
        ),
        isActive: _currentStep >= 3,
      ),
      Step(
        title: const Text('Review'),
        content: _buildReviewSection(provider),
        isActive: _currentStep >= 4,
      ),
    ];
  }

  Widget _buildPersonalDetailsForm(CvFormProvider provider) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Full Name'),
          initialValue: provider.cvData.fullName,
          onSaved: (value) => provider.updateFullName(value ?? ''),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your full name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Email Address'),
          initialValue: provider.cvData.email,
          onSaved: (value) => provider.updateEmail(value ?? ''),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your email' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Phone Number'),
          initialValue: provider.cvData.phoneNumber,
          onSaved: (value) => provider.updatePhone(value ?? ''),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your phone number' : null,
        ),
      ],
    );
  }

  List<Widget> _buildWorkExperienceFields(CvFormProvider provider) {
    return [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.cvData.workExperience.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Work Experience #${index + 1}', style: AppTextStyles.subtitle),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Job Title'),
                    initialValue: provider.cvData.workExperience[index].jobTitle,
                    onSaved: (value) =>
                        provider.cvData.workExperience[index].jobTitle =
                            value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Company'),
                    initialValue: provider.cvData.workExperience[index].company,
                    onSaved: (value) =>
                        provider.cvData.workExperience[index].company =
                            value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Dates'),
                    initialValue: provider.cvData.workExperience[index].dates,
                    onSaved: (value) =>
                        provider.cvData.workExperience[index].dates =
                            value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    initialValue: provider.cvData.workExperience[index].description,
                    onSaved: (value) =>
                        provider.cvData.workExperience[index].description =
                            value ?? '',
                    maxLines: 3,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => provider.removeWorkExperience(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () => provider.addWorkExperience(),
          icon: const Icon(Icons.add),
          label: const Text('Add Experience'),
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
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Education #${index + 1}', style: AppTextStyles.subtitle),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Institution'),
                    initialValue: provider.cvData.education[index].institution,
                    onSaved: (value) =>
                        provider.cvData.education[index].institution =
                            value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Degree'),
                    initialValue: provider.cvData.education[index].degree,
                    onSaved: (value) =>
                        provider.cvData.education[index].degree = value ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Dates'),
                    initialValue: provider.cvData.education[index].dates,
                    onSaved: (value) =>
                        provider.cvData.education[index].dates = value ?? '',
                  ),
                   const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    initialValue: provider.cvData.education[index].description,
                    onSaved: (value) =>
                        provider.cvData.education[index].description =
                            value ?? '',
                    maxLines: 3,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => provider.removeEducation(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
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
                    decoration:
                        InputDecoration(labelText: 'Skill #${index + 1}'),
                    onSaved: (value) => provider.updateSkill(index, value ?? ''),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => provider.removeSkill(index),
                ),
              ],
            ),
          );
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () => provider.addSkill(),
          icon: const Icon(Icons.add),
          label: const Text('Add Skill'),
        ),
      ),
    ];
  }

  Widget _buildReviewSection(CvFormProvider provider) {
    _formKey.currentState?.save();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Details', style: AppTextStyles.title),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildReviewTile(Icons.person, 'Full Name', provider.cvData.fullName),
              _buildReviewTile(Icons.email, 'Email', provider.cvData.email),
              _buildReviewTile(Icons.phone, 'Phone Number', provider.cvData.phoneNumber),
            ],
          ),
        ),
        const Divider(height: 32, thickness: 1),
        Text('Work Experience', style: AppTextStyles.title),
        ...provider.cvData.workExperience.map((e) => Card(
          margin: const EdgeInsets.only(top: 8),
          child: ListTile(
            leading: Icon(Icons.work, color: AppColors.primary),
            title: Text(e.jobTitle, style: AppTextStyles.subtitle),
            subtitle: Text('${e.company}\n${e.dates}', style: AppTextStyles.body),
            isThreeLine: true,
          ),
        )),
        const Divider(height: 32, thickness: 1),
        Text('Education', style: AppTextStyles.title),
        ...provider.cvData.education.map((e) => Card(
          margin: const EdgeInsets.only(top: 8),
          child: ListTile(
            leading: Icon(Icons.school, color: AppColors.primary),
            title: Text(e.degree, style: AppTextStyles.subtitle),
            subtitle: Text('${e.institution}\n${e.dates}', style: AppTextStyles.body),
            isThreeLine: true,
          ),
        )),
        const Divider(height: 32, thickness: 1),
        Text('Skills', style: AppTextStyles.title),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: provider.cvData.skills
              .map((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.primaryLight.withOpacity(0.5),
                    labelStyle: TextStyle(color: AppColors.primaryDark),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.subtitle),
      subtitle: Text(subtitle, style: AppTextStyles.body),
    );
  }
}
