/// -----------------------------------------------------------------------------
/// File: details_card.dart
/// -----------------------------------------------------------------------------
/// File ini berisi widget DetailsCard untuk menampilkan detail cuaca harian.
///
/// Penjelasan:
/// - class DetailsCard: Widget utama yang menerima WeatherModel sebagai parameter.
///   - Menampilkan detail seperti sunrise, sunset, suhu minimum/maksimum, kelembapan, tekanan, dan lain-lain.
///   - Menggunakan _DetailItem untuk menampilkan setiap detail dengan ikon dan label.
///
/// Catatan:
/// - Widget ini digunakan di halaman utama untuk menampilkan detail cuaca harian.
/// - Untuk menambah detail lain, tambahkan properti dan tampilan di bagian children.
/// -----------------------------------------------------------------------------
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/weather_model.dart';

/// Widget kartu yang menampilkan detail cuaca harian seperti sunrise, sunset, min/max, kelembapan, dan lain-lain.
class DetailsCard extends StatelessWidget {
  final WeatherModel weather;

  /// Buat instance `DetailsCard` dengan data cuaca harian.
  ///
  /// Parameter:
  /// - `weather`: model cuaca yang menyediakan semua nilai detail yang akan ditampilkan.
  const DetailsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    final borderColor = AppColors.getBorderColor(brightness);

    /// Container utama untuk detail cuaca dengan border dan background transparan
    return Container(
      padding: const EdgeInsets.all(20),

      /// Dekorasi dengan border halus dan border radius untuk tampilan kartu
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Judul "Details" untuk menunjukkan bagian detail cuaca
          Text(
            'Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),

          /// Baris pertama: Sunrise dan Sunset
          Row(
            children: [
              /// Detail waktu matahari terbit
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.sunrise,
                  value: weather.sunrise,
                  label: 'Sunrise',
                  brightness: brightness,
                ),
              ),

              /// Detail waktu matahari terbenam
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.sunset,
                  value: weather.sunset,
                  label: 'Sunset',
                  brightness: brightness,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Baris kedua: Min/Max Suhu dan Feels Like
          Row(
            children: [
              /// Detail suhu minimum dan maksimum dalam format "min | max"
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.thermometer,
                  value:
                      '${weather.minTemp.round()}° | ${weather.maxTemp.round()}°',
                  label: 'Min | Max',
                  brightness: brightness,
                ),
              ),

              /// Detail suhu yang terasa saat ini
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.thermometer,
                  value: '${weather.feelsLike.round()}°',
                  label: 'Feels Like',
                  brightness: brightness,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Baris ketiga: Tekanan Udara dan Kelembapan
          Row(
            children: [
              /// Detail tekanan udara dalam satuan hektopascal (hPa)
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.compass,
                  value: '${weather.pressure.round()} hPa',
                  label: 'Pressure',
                  brightness: brightness,
                ),
              ),

              /// Detail kelembapan udara dalam persentase
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.drop,
                  value: '${weather.humidity}%',
                  label: 'Humidity',
                  brightness: brightness,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Baris keempat: Kecepatan Angin dan Indeks UV
          Row(
            children: [
              /// Detail kecepatan angin dalam satuan km/h
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.wind,
                  value: '${weather.windSpeed} km/h',
                  label: 'Wind Speed',
                  brightness: brightness,
                ),
              ),

              /// Detail indeks UV (radiasi ultraviolet) saat ini
              Expanded(
                child: _DetailItem(
                  icon: CupertinoIcons.eye,
                  value: '${weather.uvIndex}',
                  label: 'UV Index',
                  brightness: brightness,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget private untuk menampilkan satu item detail dengan icon, value, dan label
/// Digunakan untuk mengorganisir tampilan detail cuaca agar terstruktur dan rapi
class _DetailItem extends StatelessWidget {
  /// Icon yang ditampilkan untuk item detail
  final IconData icon;

  /// Nilai dari detail (misal "28°C", "80%", "10 km/h")
  final String value;

  /// Label dari detail (misal "Feels Like", "Humidity", "Wind Speed")
  final String label;

  /// Brightness untuk menentukan warna teks yang sesuai
  final Brightness brightness;

  /// Buat item detail untuk ditampilkan dalam `DetailsCard`.
  ///
  /// Parameter:
  /// - `icon`: ikon yang merepresentasikan jenis detail.
  /// - `value`: nilai utama (mis. "28°C").
  /// - `label`: label penjelas (mis. "Feels Like").
  /// - `brightness`: brightness tema untuk menentukan warna teks.
  const _DetailItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(brightness);
    final secondaryTextColor = AppColors.getSecondaryTextColor(brightness);

    /// Row untuk menampilkan icon di kiri dan teks di kanan
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Icon detail dengan warna sesuai tema
        Icon(icon, color: textColor, size: 28),
        const SizedBox(width: 12),

        /// Kolom yang menampilkan value dan label secara vertikal
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Nilai detail dalam font tebal dan ukuran lebih besar
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// Label detail dalam warna sekunder
            Text(
              label,
              style: TextStyle(color: secondaryTextColor, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
