import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  const base = TextTheme(
    bodyLarge: TextStyle(color: AppColors.text, fontFamily: 'Georgia'),
    bodyMedium: TextStyle(color: AppColors.text, fontFamily: 'Georgia'),
    titleMedium: TextStyle(color: AppColors.text, fontFamily: 'Georgia'),
  );

  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accentBlue,
      surface: AppColors.card,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 0.9),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    ),
  );
}
