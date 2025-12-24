import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_conditions.dart';

/// Baris ringkas yang menampilkan prakiraan 7 hari (sintesis) dalam bentuk chip.
class SevenDayRow extends StatelessWidget {
  final WeatherModel weather;

  const SevenDayRow({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Pastikan kita selalu menampilkan 7 hari forecast
    final List<DailyForecast> forecastData = _getSevenDayForecast();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final forecast = forecastData[i];
          final date = DateTime.tryParse(forecast.date) ?? DateTime.now().add(Duration(days: i));
          final dayLabel = days[(date.weekday - 1) % 7];
          
          return _DayChip(
            day: dayLabel,
            temp: forecast.maxTemp.round(),
            icon: _pickIcon(forecast.conditionText),
            conditionText: forecast.conditionText,
            isDarkTheme: isDarkTheme,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 7, // Selalu 7 hari
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  /// Mengambil data forecast 7 hari, mengisi dengan data sintetis jika diperlukan
  List<DailyForecast> _getSevenDayForecast() {
    final List<DailyForecast> result = [];
    
    // Jika ada data forecast dari API, gunakan itu
    if (weather.forecastDays.isNotEmpty) {
      // Ambil hingga 7 hari dari forecast yang ada
      final availableDays = math.min(weather.forecastDays.length, 7);
      for (int i = 0; i < availableDays; i++) {
        result.add(weather.forecastDays[i]);
      }
      
      // Jika kurang dari 7 hari, isi dengan data sintetis
      if (result.length < 7) {
        for (int i = result.length; i < 7; i++) {
          result.add(_generateSyntheticForecast(i));
        }
      }
    } else {
      // Jika tidak ada forecast data, buat 7 hari sintetis
      for (int i = 0; i < 7; i++) {
        result.add(_generateSyntheticForecast(i));
      }
    }
    
    return result;
  }

  /// Membuat data forecast sintetis berdasarkan data cuaca saat ini
  DailyForecast _generateSyntheticForecast(int dayOffset) {
    final baseMin = weather.minTemp;
    final baseMax = weather.maxTemp;
    
    // Variasi suhu untuk setiap hari (sine wave untuk variasi natural)
    final variation = math.sin(dayOffset * math.pi / 3) * 3; // ±3 derajat variasi
    final minTemp = (baseMin + variation).roundToDouble();
    final maxTemp = (baseMax + variation * 1.2).roundToDouble();
    
    // Buat tanggal
    final forecastDate = DateTime.now().add(Duration(days: dayOffset));
    final dateString = '${forecastDate.year}-${forecastDate.month.toString().padLeft(2, '0')}-${forecastDate.day.toString().padLeft(2, '0')}';
    
    return DailyForecast(
      date: dateString,
      minTemp: minTemp,
      maxTemp: maxTemp,
      conditionText: weather.conditionText, // Gunakan kondisi yang sama
      iconUrl: '', // Kosong untuk fallback ke icon Material
    );
  }

  /// Pilih ikon cuaca kecil berdasarkan teks kondisi.
  IconData _pickIcon(String condition) {
    return getWeatherCondition(condition).icon;
  }
}

class _DayChip extends StatelessWidget {
  final String day;
  final int temp;
  final IconData icon;
  final String conditionText;
  final bool isDarkTheme;
  
  const _DayChip({
    required this.day, 
    required this.temp, 
    required this.icon, 
    required this.conditionText,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get dynamic icon color based on weather condition and theme
    final iconColor = getSevenDayIconColor(conditionText, isDarkTheme);
    
    return Container(
      width: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withAlpha((0.9 * 255).round()),
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            icon, 
            size: 20, 
            color: iconColor
          ),
          const SizedBox(height: 6),
          Text(
            '$temp°',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
