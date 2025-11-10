import 'package:cv_generator/models/cv_theme.dart';
import 'package:cv_generator/providers/cv_form_provider.dart';
import 'package:cv_generator/screens/pdf_preview_screen.dart';
import 'package:cv_generator/services/pdf_generator.dart';
import 'package:cv_generator/services/theme_service.dart';
import 'package:cv_generator/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CvBuilderScreen extends StatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<CvTheme>> _themesFuture;
  String _searchQuery = '';
  String? _categoryFilter;
  final List<String> _activeSectionIds = _componentLibrary
      .where((component) => component.isDefault)
      .map((component) => component.id)
      .toList();

  @override
  void initState() {
    super.initState();
    _themesFuture = ThemeService.loadThemes();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CvFormProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Visual CV Builder'),
            actions: [
              IconButton(
                tooltip: 'Export as PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => _handleExport(provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _handleExport(provider),
            icon: const Icon(Icons.download),
            label: const Text('Export CV'),
          ),
          body: FutureBuilder<List<CvTheme>>(
            future: _themesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(
                  message: 'Unable to load themes',
                  details: snapshot.error.toString(),
                );
              }

              final themes = snapshot.data ?? [];
              if (themes.isEmpty) {
                return const _ErrorView(
                  message: 'No themes found',
                  details: 'Add JSON themes under assets/themes/cv_themes.json.',
                );
              }

              final filteredThemes = _filterThemes(themes);
              final selectedTheme = _resolveSelectedTheme(themes, provider);

              return Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                      child: Column(
                        children: [
                          _buildThemeSelector(
                            themes,
                            filteredThemes,
                            selectedTheme,
                            provider,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _buildSectionsCanvas(
                              provider,
                              selectedTheme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildComponentTray(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleExport(CvFormProvider provider) async {
    _formKey.currentState?.save();
    final pdfData = await PdfGenerator.generateCv(provider.cvData);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(pdfData: pdfData),
      ),
    );
  }

  Widget _buildThemeSelector(
    List<CvTheme> allThemes,
    List<CvTheme> filteredThemes,
    CvTheme selectedTheme,
    CvFormProvider provider,
  ) {
    final categories = {
      for (final theme in allThemes) theme.category,
    }.toList()
      ..sort();
    final hasActiveFilter =
        _searchQuery.isNotEmpty || (_categoryFilter != null);
    final showEmptyState = filteredThemes.isEmpty && hasActiveFilter;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pick a theme (${allThemes.length} available)',
                    style: AppTextStyles.subtitle,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear filters',
                  onPressed: hasActiveFilter
                      ? () {
                          setState(() {
                            _searchController.clear();
                            _categoryFilter = null;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.filter_list_off),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search themes, categories, descriptions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _categoryFilter == null,
                    onSelected: (value) {
                      setState(() => _categoryFilter = null);
                    },
                  ),
                  const SizedBox(width: 12),
                  ...categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _categoryFilter == category,
                        onSelected: (value) {
                          setState(() {
                            _categoryFilter = value ? category : null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: showEmptyState
                  ? Center(
                      child: Text(
                        'No themes match your filters.',
                        style: AppTextStyles.body,
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredThemes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final theme = filteredThemes[index];
                        final isSelected =
                            theme.id == provider.cvData.selectedThemeId;
                        return _ThemeCard(
                          theme: theme,
                          isSelected: isSelected,
                          onTap: () {
                            provider.updateSelectedTheme(theme.id);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            _ThemePreview(theme: selectedTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsCanvas(
    CvFormProvider provider,
    CvTheme selectedTheme,
  ) {
    if (_activeSectionIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No sections on the board.\nUse the component tray to add them back.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: AppColors.white,
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 220),
          buildDefaultDragHandles: false,
          physics: const BouncingScrollPhysics(),
          itemCount: _activeSectionIds.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final id = _activeSectionIds[index];
            final component = _componentById(id);
            return Card(
              key: ValueKey(id),
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Icon(component.icon, color: AppColors.primary),
                      title: Text(component.label, style: AppTextStyles.subtitle),
                      subtitle: Text(component.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!component.isCore)
                            IconButton(
                              tooltip: 'Remove section',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => _toggleSection(id, false),
                            ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_indicator),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildSectionContent(
                        id,
                        provider,
                        selectedTheme,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContent(
    String id,
    CvFormProvider provider,
    CvTheme selectedTheme,
  ) {
    switch (id) {
      case 'personal':
        return _buildPersonalSection(provider);
      case 'experience':
        return _buildExperienceSection(provider);
      case 'education':
        return _buildEducationSection(provider);
      case 'skills':
        return _buildSkillsSection(provider);
      case 'review':
        return _buildReviewSection(provider, selectedTheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalSection(CvFormProvider provider) {
    return Column(
      children: [
        TextFormField(
          initialValue: provider.cvData.fullName,
          decoration: const InputDecoration(labelText: 'Full name'),
          onChanged: provider.updateFullName,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: provider.cvData.email,
          decoration: const InputDecoration(labelText: 'Email address'),
          onChanged: provider.updateEmail,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: provider.cvData.phoneNumber,
          decoration: const InputDecoration(labelText: 'Phone number'),
          onChanged: provider.updatePhone,
        ),
      ],
    );
  }

  Widget _buildExperienceSection(CvFormProvider provider) {
    final experiences = provider.cvData.workExperience;

    if (experiences.isEmpty) {
      return _EmptySection(
        message: 'No work experience added yet.',
        actionLabel: 'Add experience',
        onPressed: provider.addWorkExperience,
      );
    }

    return Column(
      children: [
        ...List.generate(experiences.length, (index) {
          final experience = experiences[index];
          return _SubCard(
            title: 'Experience #${index + 1}',
            onRemove: () => provider.removeWorkExperience(index),
            children: [
              TextFormField(
                initialValue: experience.jobTitle,
                decoration: const InputDecoration(labelText: 'Job title'),
                onChanged: (value) => provider.updateWorkExperience(
                  index,
                  experience.copyWith(jobTitle: value),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: experience.company,
                decoration: const InputDecoration(labelText: 'Company'),
                onChanged: (value) => provider.updateWorkExperience(
                  index,
                  experience.copyWith(company: value),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: experience.dates,
                decoration: const InputDecoration(labelText: 'Dates'),
                onChanged: (value) => provider.updateWorkExperience(
                  index,
                  experience.copyWith(dates: value),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: experience.description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => provider.updateWorkExperience(
                  index,
                  experience.copyWith(description: value),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: provider.addWorkExperience,
            icon: const Icon(Icons.add),
            label: const Text('Add experience'),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSection(CvFormProvider provider) {
    final education = provider.cvData.education;
    if (education.isEmpty) {
      return _EmptySection(
        message: 'No education history yet.',
        actionLabel: 'Add education',
        onPressed: provider.addEducation,
      );
    }

    return Column(
      children: [
        ...List.generate(education.length, (index) {
          final entry = education[index];
          return _SubCard(
            title: 'Education #${index + 1}',
            onRemove: () => provider.removeEducation(index),
            children: [
              TextFormField(
                initialValue: entry.institution,
                decoration: const InputDecoration(labelText: 'Institution'),
                onChanged: (value) => provider.updateEducation(
                  index,
                  entry.copyWith(institution: value),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: entry.degree,
                decoration: const InputDecoration(labelText: 'Degree / Program'),
                onChanged: (value) => provider.updateEducation(
                  index,
                  entry.copyWith(degree: value),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: entry.dates,
                decoration: const InputDecoration(labelText: 'Dates'),
                onChanged: (value) => provider.updateEducation(
                  index,
                  entry.copyWith(dates: value),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: entry.description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => provider.updateEducation(
                  index,
                  entry.copyWith(description: value),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: provider.addEducation,
            icon: const Icon(Icons.add),
            label: const Text('Add education'),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(CvFormProvider provider) {
    final skills = provider.cvData.skills;
    if (skills.isEmpty) {
      return _EmptySection(
        message: 'No skills added yet.',
        actionLabel: 'Add skill',
        onPressed: provider.addSkill,
      );
    }

    return Column(
      children: [
        ...List.generate(skills.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: skills[index],
                    decoration: InputDecoration(
                      labelText: 'Skill #${index + 1}',
                    ),
                    onChanged: (value) => provider.updateSkill(index, value),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove skill',
                  icon: Icon(Icons.remove_circle, color: AppColors.error),
                  onPressed: () => provider.removeSkill(index),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: provider.addSkill,
            icon: const Icon(Icons.add),
            label: const Text('Add skill'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(CvFormProvider provider, CvTheme selectedTheme) {
    final data = provider.cvData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(data.fullName, style: AppTextStyles.subtitle),
          subtitle: Text('${data.email}\n${data.phoneNumber}'),
          leading: CircleAvatar(
            backgroundColor: selectedTheme.accentColor.withOpacity(0.2),
            child: Icon(Icons.person, color: selectedTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 12),
        Text('Theme', style: AppTextStyles.subtitle),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [selectedTheme.primaryColor, selectedTheme.accentColor],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedTheme.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    selectedTheme.category,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Chip(
                backgroundColor: Colors.white,
                label: Text(
                  selectedTheme.fontFamily,
                  style: TextStyle(color: selectedTheme.primaryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SummaryList(
          icon: Icons.work_outline,
          title: 'Experience',
          items: data.workExperience
              .map((e) => '${e.jobTitle} • ${e.company}')
              .toList(),
        ),
        _SummaryList(
          icon: Icons.school_outlined,
          title: 'Education',
          items: data.education
              .map((e) => '${e.degree} • ${e.institution}')
              .toList(),
        ),
        _SummaryList(
          icon: Icons.star_outline,
          title: 'Skills',
          items: data.skills,
        ),
      ],
    );
  }

  Widget _buildComponentTray() {
    return DraggableScrollableSheet(
      minChildSize: 0.08,
      initialChildSize: 0.12,
      maxChildSize: 0.4,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Components',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 8),
              Text(
                'Slide this tray to enable or disable sections, then drag them above to reorder.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _componentLibrary.map((component) {
                  final isActive = _activeSectionIds.contains(component.id);
                  return FilterChip(
                    avatar: Icon(
                      component.icon,
                      size: 16,
                    ),
                    label: Text(component.label),
                    selected: isActive,
                    onSelected: component.isCore
                        ? null
                        : (selected) => _toggleSection(
                              component.id,
                              selected,
                            ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<CvTheme> _filterThemes(List<CvTheme> themes) {
    return themes.where((theme) {
      final matchesQuery = theme.matchesQuery(_searchQuery);
      final matchesCategory =
          _categoryFilter == null || theme.category == _categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  CvTheme _resolveSelectedTheme(
    List<CvTheme> themes,
    CvFormProvider provider,
  ) {
    final selectedId = provider.cvData.selectedThemeId;
    return themes.firstWhere(
      (theme) => theme.id == selectedId,
      orElse: () => themes.first,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _activeSectionIds.removeAt(oldIndex);
      _activeSectionIds.insert(newIndex, item);
    });
  }

  void _toggleSection(String id, bool enabled) {
    setState(() {
      if (enabled) {
        if (!_activeSectionIds.contains(id)) {
          _activeSectionIds.add(id);
        }
      } else {
        _activeSectionIds.remove(id);
      }
    });
  }

  _BuilderComponent _componentById(String id) {
    return _componentLibrary.firstWhere((component) => component.id == id);
  }
}

class _ThemeCard extends StatelessWidget {
  final CvTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              theme.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              backgroundColor: Colors.white.withOpacity(0.9),
              label: Text(
                theme.category,
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
            const Spacer(),
            Text(
              theme.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final CvTheme theme;

  const _ThemePreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.backgroundColor,
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  theme.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _ColorDot(color: theme.primaryColor, label: 'Primary'),
                    _ColorDot(color: theme.accentColor, label: 'Accent'),
                    _ColorDot(color: theme.textColor, label: 'Text'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const Text('Font'),
              Chip(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                label: Text(
                  theme.fontFamily,
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  const _EmptySection({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            message,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _SubCard extends StatelessWidget {
  final String title;
  final VoidCallback onRemove;
  final List<Widget> children;

  const _SubCard({
    required this.title,
    required this.onRemove,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                IconButton(
                  tooltip: 'Remove',
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _SummaryList({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.subtitle),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 32.0, bottom: 4),
            child: Text('• $item', style: AppTextStyles.body),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String details;

  const _ErrorView({required this.message, required this.details});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            Text(details, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _BuilderComponent {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  final bool isCore;
  final bool isDefault;

  const _BuilderComponent({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
    this.isCore = false,
    this.isDefault = true,
  });
}

const List<_BuilderComponent> _componentLibrary = [
  _BuilderComponent(
    id: 'personal',
    label: 'Personal',
    icon: Icons.person_outline,
    description: 'Contact information and hero details.',
    isCore: true,
    isDefault: true,
  ),
  _BuilderComponent(
    id: 'experience',
    label: 'Experience',
    icon: Icons.work_outline,
    description: 'Roles, impact, and timelines.',
    isCore: true,
    isDefault: true,
  ),
  _BuilderComponent(
    id: 'education',
    label: 'Education',
    icon: Icons.school_outlined,
    description: 'Academic background and achievements.',
    isDefault: true,
  ),
  _BuilderComponent(
    id: 'skills',
    label: 'Skills',
    icon: Icons.star_outline,
    description: 'Technical and soft skills.',
    isDefault: true,
  ),
  _BuilderComponent(
    id: 'review',
    label: 'Review',
    icon: Icons.visibility_outlined,
    description: 'Snapshot of everything selected.',
    isDefault: true,
  ),
];
