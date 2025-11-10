import 'package:flutter/material.dart';

class AppColors {
  static final Color primary = Colors.blue[400]!;
  static final Color primaryLight = Colors.blue[200]!;
  static final Color primaryDark = Colors.blue[600]!;
  static const Color white = Colors.white;
  static final Color grey = Colors.grey[400]!;
  static final Color lightGrey = Colors.grey[200]!;
  static final Color darkGrey = Colors.grey[600]!;
  static final Color background = Colors.grey[100]!;
  static final Color error = Colors.red[400]!;
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    hintColor: AppColors.grey,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      labelStyle: TextStyle(color: AppColors.darkGrey),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    stepperTheme: StepperThemeData(
      backgroundColor: AppColors.background,
      elevation: 0,
      connectorColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.grey;
      }),
      stepIconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: AppColors.primary, size: 24);
        }
        return IconThemeData(color: AppColors.grey, size: 24);
      }),
    ),
  );
}

class AppDecorations {
  static final BoxDecoration glossyCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(16.0),
    gradient: LinearGradient(
      colors: [
        AppColors.white.withOpacity(0.8),
        AppColors.white.withOpacity(0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class AppTextStyles {
  static final TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  static final TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGrey,
  );

  static final TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.darkGrey,
  );
}
