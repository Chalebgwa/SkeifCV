import 'dart:convert';

import 'package:cv_generator/models/cv_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

typedef ThemeManifestLoader = Future<String> Function();

class ThemeService {
  static const String _assetPath = 'assets/themes/cv_themes.json';
  static List<CvTheme>? _cache;
  static ThemeManifestLoader? _mockLoader;

  static Future<List<CvTheme>> loadThemes() async {
    if (_cache != null) {
      return _cache!;
    }
    final loader = _mockLoader ?? (() => rootBundle.loadString(_assetPath));
    final raw = await loader();
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    _cache =
        data.map((entry) => CvTheme.fromJson(entry as Map<String, dynamic>)).toList();
    return _cache!;
  }

  @visibleForTesting
  static void setMockLoader(ThemeManifestLoader? loader) {
    _mockLoader = loader;
    clearCache();
  }

  @visibleForTesting
  static void clearCache() {
    _cache = null;
  }
}
