import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class SevenDayRow extends StatelessWidget {
  final WeatherModel weather;

  const SevenDayRow({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Create pseudo-forecast based on today's min/max
    final double min = weather.minTemp;
    final double max = weather.maxTemp;

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final t = (min + (max - min) * (i / 6)).round();
          return _DayChip(
            day: days[i % days.length],
            temp: t,
            icon: _pickIcon(weather.conditionText),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  IconData _pickIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain')) return Icons.umbrella;
    if (c.contains('cloud')) return Icons.cloud;
    if (c.contains('sun') || c.contains('clear')) return Icons.wb_sunny;
    if (c.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }
}

class _DayChip extends StatelessWidget {
  final String day;
  final int temp;
  final IconData icon;
  const _DayChip({required this.day, required this.temp, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Icon(icon, size: 20, color: theme.colorScheme.primary),
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
