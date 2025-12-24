import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_weather/theme/app_colors.dart';

/// Kumpulan `ThemeData` untuk aplikasi.
/// - `lightTheme`: tema terang yang digunakan sebagai default untuk mode light.
/// - `darkTheme`: variasi tema untuk mode gelap.
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightBackground,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.latoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightTextPrimary,
      secondary: AppColors.lightTextSecondary,
      surface: AppColors.lightBackground,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkBackground,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.latoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkTextPrimary,
      secondary: AppColors.darkTextSecondary,
      surface: AppColors.darkBackground,
    ),
  );
}
