/// -----------------------------------------------------------------------------
/// File: app_colors.dart
/// -----------------------------------------------------------------------------
/// File ini berisi definisi warna-warna utama yang digunakan di aplikasi Simple Weather.
///
/// Penjelasan:
/// - class AppColors: Berisi konstanta warna untuk background, card, teks, dan border.
///   - background: Warna latar utama aplikasi.
///   - cardBeige: Warna card atas (misal untuk suhu utama).
///   - cardDark: Warna card detail (misal untuk detail cuaca).
///   - textWhite, textGrey: Warna teks utama dan sekunder.
///   - borderColor: Warna border tipis pada card atau komponen lain.
///
/// Catatan:
/// - Untuk konsistensi UI, gunakan warna dari AppColors di seluruh widget.
/// - Jika ingin menambah tema atau warna baru, tambahkan di class ini.
/// -----------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------------
/// class AppColors
/// -----------------------------------------------------------------------------
/// Berisi konstanta warna utama yang digunakan di aplikasi Simple Weather.
///
/// - background: Warna latar utama aplikasi.
/// - cardBeige: Warna card atas (misal untuk suhu utama).
/// - cardDark: Warna card detail (misal untuk detail cuaca).
/// - textWhite, textGrey: Warna teks utama dan sekunder.
/// - borderColor: Warna border tipis pada card atau komponen lain.
///
/// Gunakan warna dari AppColors untuk konsistensi UI di seluruh widget.
/// Jika ingin menambah tema atau warna baru, tambahkan di class ini.
/// -----------------------------------------------------------------------------
/// Class yang menyimpan konstanta warna utama aplikasi Simple Weather.
/// Digunakan di seluruh widget untuk menjaga konsistensi UI dan memudahkan perubahan tema.
///
/// Warna-warna yang tersedia:
/// - background: Latar belakang utama (gelap/hitam)
/// - cardBeige: Warna accent untuk card utama
/// - cardDark: Warna untuk card detail dengan background gelap
/// - textWhite: Teks dalam warna putih (utama)
/// - textGrey: Teks dalam warna abu-abu (sekunder/caption)
/// - borderColor: Warna untuk border dan divider (transparan putih)
class AppColors {
  // ========= DARK THEME COLORS =========
  /// Warna background utama untuk dark mode - hitam pekat (#101010)
  static const Color darkBackground = Color(0xFF101010);

  /// Warna card untuk dark mode (#1C1C1E)
  static const Color darkCard = Color(0xFF1C1C1E);

  /// Warna teks utama untuk dark mode - putih
  static const Color darkTextPrimary = Colors.white;

  /// Warna teks sekunder untuk dark mode - abu-abu terang
  static const Color darkTextSecondary = Colors.grey;

  /// Warna border untuk dark mode - putih transparan
  static const Color darkBorder = Colors.white24;

  // ========= LIGHT THEME COLORS =========
  /// Warna background utama untuk light mode (#E7F4FA)
  static const Color lightBackground = Color(0xFFE7F4FA);

  /// Warna card untuk light mode (putih atau terang)
  static const Color lightCard = Colors.white;

  /// Warna teks utama untuk light mode - hitam/abu-abu gelap
  static const Color lightTextPrimary = Color(0xFF1F1F1F);

  /// Warna teks sekunder untuk light mode - abu-abu
  static const Color lightTextSecondary = Color(0xFF757575);

  /// Warna border untuk light mode - abu-abu terang
  static const Color lightBorder = Color(0xFFE0E0E0);

  // ========= ACCENT COLORS =========
  /// Warna accent beige/cream (#CDC2C2) - digunakan di kedua tema
  static const Color cardBeige = Color(0xFFCDC2C2);

  // ========= LEGACY ALIASES (untuk backward compatibility) =========
  static const Color background = darkBackground;
  static const Color cardDark = darkCard;
  static const Color textWhite = darkTextPrimary;
  static const Color textGrey = darkTextSecondary;
  static const Color borderColor = darkBorder;

  // ========= THEME-AWARE HELPERS =========
  /// Dapatkan warna teks utama berdasarkan brightness
  static Color getTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  /// Dapatkan warna teks sekunder berdasarkan brightness
  static Color getSecondaryTextColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// Dapatkan warna border berdasarkan brightness
  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBorder : lightBorder;
  }

  /// Dapatkan warna card berdasarkan brightness
  static Color getCardColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCard : lightCard;
  }

  /// Dapatkan warna background berdasarkan brightness
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }
}
