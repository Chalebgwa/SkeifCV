import 'package:cv_generator/providers/cv_form_provider.dart';
import 'package:cv_generator/screens/cv_builder_screen.dart';
import 'package:cv_generator/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  const manifest = '''
[
  {
    "id": "theme_001",
    "name": "Nova Grid",
    "category": "Modern",
    "fontFamily": "Inter",
    "primaryColor": "#1D4ED8",
    "accentColor": "#22D3EE",
    "backgroundColor": "#F0F9FF",
    "textColor": "#0F172A",
    "description": "Clean grid-based aesthetic."
  },
  {
    "id": "theme_002",
    "name": "Retro Beam",
    "category": "Creative",
    "fontFamily": "Poppins",
    "primaryColor": "#EA580C",
    "accentColor": "#FACC15",
    "backgroundColor": "#FFFBEB",
    "textColor": "#3C0A00",
    "description": "Warm retro-inspired display."
  }
]
''';

  setUp(() {
    ThemeService.setMockLoader(() async => manifest);
    ThemeService.clearCache();
  });

  tearDown(() {
    ThemeService.setMockLoader(null);
    ThemeService.clearCache();
  });

  Future<void> _pumpBuilder(
    WidgetTester tester,
    CvFormProvider provider,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CvFormProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: CvBuilderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder _fieldWithLabel(String label) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextFormField &&
          widget.decoration?.labelText != null &&
          widget.decoration!.labelText == label,
      description: 'TextFormField with label "$label"',
    );
  }

  testWidgets('renders theme cards and supports searching', (tester) async {
    final provider = CvFormProvider();
    await _pumpBuilder(tester, provider);

    expect(find.text('Nova Grid'), findsWidgets);
    expect(find.text('Retro Beam'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'Retro');
    await tester.pumpAndSettle();

    expect(find.text('Retro Beam'), findsWidgets);
    expect(find.text('Nova Grid'), findsNothing);
  });

  testWidgets('editing personal info updates provider state', (tester) async {
    final provider = CvFormProvider();
    await _pumpBuilder(tester, provider);

    await tester.enterText(_fieldWithLabel('Full name'), 'Charlie Delta');
    await tester.enterText(_fieldWithLabel('Email address'), 'charlie@example.com');
    await tester.enterText(_fieldWithLabel('Phone number'), '+1 555 0100');
    await tester.pump();

    expect(provider.cvData.fullName, equals('Charlie Delta'));
    expect(provider.cvData.email, equals('charlie@example.com'));
    expect(provider.cvData.phoneNumber, equals('+1 555 0100'));
  });

  testWidgets('adding an experience entry shows the new card', (tester) async {
    final provider = CvFormProvider();
    await _pumpBuilder(tester, provider);

    expect(find.text('No work experience added yet.'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Add experience'));
    await tester.pumpAndSettle();

    expect(find.text('Experience #1'), findsOneWidget);
  });
}
