import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider yang menyimpan dan menyediakan `ThemeMode` aplikasi.
/// - Menyimpan preferensi pada `SharedPreferences` (key: `_themeKey`).
/// - Default: `ThemeMode.system`.
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Muat theme mode yang tersimpan dari `SharedPreferences`.
  /// Jika tidak ditemukan data, gunakan `ThemeMode.system`.
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  /// Set dan persist `ThemeMode` yang dipilih.
  /// Memanggil `notifyListeners()` agar UI ter-update.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }
}
