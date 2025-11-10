import 'package:cv_generator/providers/cv_form_provider.dart';
import 'package:cv_generator/screens/home_screen.dart';
import 'package:cv_generator/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CvFormProvider(),
      child: MaterialApp(
        title: 'CV Generator',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
