import 'dart:convert';

import 'package:cv_generator/models/cv_theme.dart';
import 'package:flutter/services.dart' show rootBundle;

class ThemeService {
  static const String _assetPath = 'assets/themes/cv_themes.json';
  static List<CvTheme>? _cache;

  static Future<List<CvTheme>> loadThemes() async {
    if (_cache != null) {
      return _cache!;
    }
    final raw = await rootBundle.loadString(_assetPath);
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    _cache =
        data.map((entry) => CvTheme.fromJson(entry as Map<String, dynamic>)).toList();
    return _cache!;
  }
}
