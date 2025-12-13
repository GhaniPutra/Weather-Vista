import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/weather_model.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback onBack;
  final WeatherModel? weather;
  final String? location;

  const NotificationScreen({
    required this.onBack,
    this.weather,
    this.location,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);

    final lightGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFDFF6FA), Color(0xFFF6E8DA)],
    );
    final darkGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F0F0F), Color(0xFF1B1B1B)],
    );

    final grad = brightness == Brightness.dark ? darkGradient : lightGradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: onBack,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hari ini',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer
                        .withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Pagi !',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              weather != null
                                  ? 'Hari ini ${weather!.conditionText.toLowerCase()} di ${weather!.locationName}. Suhu mencapai ${weather!.tempC.round()}°C.'
                                  : (location != null
                                        ? 'Hari ini di $location. Periksa detail cuaca di halaman utama.'
                                        : 'Hari ini cerah di Yogyakarta. Suhu mencapai 32°C. Jangan lupa minum air!'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha((0.85 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        // show sun or umbrella based on weather condition
                        weather != null &&
                                weather!.conditionText.toLowerCase().contains(
                                  'rain',
                                )
                            ? Icons.umbrella
                            : Icons.wb_sunny,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 36,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Prediksi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: brightness == Brightness.dark
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade800,
                              Colors.grey.shade700,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade200,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Besok',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              weather != null
                                  ? 'Besok diperkirakan ${weather!.conditionText.toLowerCase()}. Suhu antara ${weather!.minTemp.round()}°C - ${weather!.maxTemp.round()}°C.'
                                  : 'Besok diperkirakan hujan deras. Siapkan payung sebelum berangkat berakti.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha((0.85 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.umbrella,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 36,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 88),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
