import 'package:cv_generator/services/theme_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const manifest = '''
[
  {
    "id": "theme_001",
    "name": "Aurora Pulse",
    "category": "Modern",
    "fontFamily": "Montserrat",
    "primaryColor": "#2563EB",
    "accentColor": "#38BDF8",
    "backgroundColor": "#F8FAFC",
    "textColor": "#0F172A",
    "description": "Bright blues with airy spacing."
  },
  {
    "id": "theme_002",
    "name": "Coral Drift",
    "category": "Creative",
    "fontFamily": "Poppins",
    "primaryColor": "#EF4444",
    "accentColor": "#FBBF24",
    "backgroundColor": "#FEF3C7",
    "textColor": "#3C0A00",
    "description": "Warm reeds and orange gradients."
  }
]
''';

  setUp(() {
    ThemeService.setMockLoader(() async => manifest);
  });

  tearDown(() {
    ThemeService.setMockLoader(null);
  });

  test('loadThemes parses manifest and caches results', () async {
    var loaderCalls = 0;
    ThemeService.setMockLoader(() async {
      loaderCalls++;
      return manifest;
    });

    final first = await ThemeService.loadThemes();
    final second = await ThemeService.loadThemes();

    expect(first.length, 2);
    expect(first.first.name, 'Aurora Pulse');
    expect(first.first.primaryColor.value, equals(0xFF2563EB));
    expect(loaderCalls, 1, reason: 'Cached data should avoid reloading manifest');
    expect(identical(first, second), isTrue,
        reason: 'loadThemes should return the cached list instance');
  });

  test('clearCache forces manifest reload', () async {
    var loaderCalls = 0;
    ThemeService.setMockLoader(() async {
      loaderCalls++;
      return manifest;
    });

    await ThemeService.loadThemes();
    ThemeService.clearCache();
    await ThemeService.loadThemes();

    expect(loaderCalls, 2);
  });
}
