import 'package:flutter/material.dart';

class CvTheme {
  final String id;
  final String name;
  final String description;
  final String category;
  final String fontFamily;
  final String primaryColorHex;
  final String accentColorHex;
  final String backgroundColorHex;
  final String textColorHex;

  const CvTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.fontFamily,
    required this.primaryColorHex,
    required this.accentColorHex,
    required this.backgroundColorHex,
    required this.textColorHex,
  });

  factory CvTheme.fromJson(Map<String, dynamic> json) {
    return CvTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      fontFamily: json['fontFamily'] as String,
      primaryColorHex: json['primaryColor'] as String,
      accentColorHex: json['accentColor'] as String,
      backgroundColorHex: json['backgroundColor'] as String,
      textColorHex: json['textColor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'fontFamily': fontFamily,
      'primaryColor': primaryColorHex,
      'accentColor': accentColorHex,
      'backgroundColor': backgroundColorHex,
      'textColor': textColorHex,
    };
  }

  Color get primaryColor => _colorFromHex(primaryColorHex);
  Color get accentColor => _colorFromHex(accentColorHex);
  Color get backgroundColor => _colorFromHex(backgroundColorHex);
  Color get textColor => _colorFromHex(textColorHex);

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    return name.toLowerCase().contains(lower) ||
        category.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower);
  }

  static Color _colorFromHex(String hex) {
    var cleaned = hex.toUpperCase().replaceAll('#', '');
    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }
    return Color(int.parse(cleaned, radix: 16));
  }
}
