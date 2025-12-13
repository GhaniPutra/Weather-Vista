/// -----------------------------------------------------------------------------
/// File: current_weather_card.dart
/// -----------------------------------------------------------------------------
/// Widget sederhana untuk menampilkan cuaca saat ini.
/// Diperlukan: `WeatherModel`, dan `MapScreen` untuk tombol peta.
/// -----------------------------------------------------------------------------
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/weather_model.dart';
import '../screens/map_screen.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  IconData _getWeatherIcon() {
    final condition = weather.conditionText.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.umbrella;
    }
    if (condition.contains('cloud') || condition.contains('overcast')) {
      return Icons.cloud;
    }
    return Icons.wb_sunny;
  }

  LinearGradient _getWeatherGradient() {
    final temp = weather.tempC;
    if (temp < 15) {
      return const LinearGradient(
        colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
      );
    }
    if (temp < 25) {
      return const LinearGradient(
        colors: [Color(0xFF43C6AC), Color(0xFF2FA59A)],
      );
    }
    return const LinearGradient(colors: [Color(0xFFFFA751), Color(0xFFFFE259)]);
  }

  Future<void> _openMapOptions(BuildContext context) async {
    final openUrl =
        'https://www.windy.com/?lat=${weather.latitude.toStringAsFixed(6)}&lon=${weather.longitude.toStringAsFixed(6)}&zoom=8';

    await showModalBottomSheet<void>(
      context: context,
      builder: (bCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Tampilkan di Aplikasi'),
              onTap: () {
                Navigator.of(bCtx).pop();
                if (!kIsWeb) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return MapScreen(
                          latitude: weather.latitude,
                          longitude: weather.longitude,
                        );
                      },
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Peta tidak tersedia di browser, gunakan opsi Buka di Browser',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Buka di Browser'),
              onTap: () async {
                final uri = Uri.parse(openUrl);
                Navigator.of(bCtx).pop();
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak dapat membuka Browser'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Salin Koordinat'),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: '${weather.latitude},${weather.longitude}',
                  ),
                );
                Navigator.of(bCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Koordinat disalin')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if ((weather.latitude == 0 && weather.longitude == 0) ||
            weather.latitude.isNaN ||
            weather.longitude.isNaN) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Koordinat lokasi tidak tersedia')),
          );
          return;
        }
        await _openMapOptions(context);
      },
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          gradient: _getWeatherGradient(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.15 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.topLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${weather.tempC.round()}°',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      _getWeatherIcon(),
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      size: 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.locationName,
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.95 * 255).round()),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              weather.conditionText,
              style: TextStyle(
                color: Colors.white.withAlpha((0.9 * 255).round()),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _statChip(
                  icon: Icons.water_drop,
                  label: '${weather.humidity}%',
                  sub: 'Humidity',
                ),
                _statChip(
                  icon: Icons.air,
                  label: '${weather.windSpeed.round()} km/h',
                  sub: 'Wind',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statChip({
  required IconData icon,
  required String label,
  required String sub,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withAlpha((0.9 * 255).round()),
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CompactHourlyChart extends StatelessWidget {
  final List<HourWeather> hourly;

  const _CompactHourlyChart({required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();
    final temps = hourly.map((h) => h.tempC).toList();
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _CompactChartPainter(
          temps: temps,
          color: Colors.white.withAlpha((0.9 * 255).round()),
        ),
      ),
    );
  }
}

class _CompactChartPainter extends CustomPainter {
  final List<double> temps;
  final Color color;

  _CompactChartPainter({required this.temps, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final min = temps.reduce((a, b) => a < b ? a : b);
    final max = temps.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1 : (max - min);
    final step = size.width / (temps.length - 1);
    final path = Path();
    for (var i = 0; i < temps.length; i++) {
      final x = i * step;
      final y = size.height - ((temps[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
