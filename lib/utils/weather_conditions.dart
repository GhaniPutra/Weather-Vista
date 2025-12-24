import 'package:flutter/material.dart';

/// Class to hold weather condition data: icon and gradient
class WeatherCondition {
  final IconData icon;
  final LinearGradient gradient;

  const WeatherCondition({
    required this.icon,
    required this.gradient,
  });
}

/// Map of weather conditions to their icons and gradients
/// Uses standardized UI condition keys (with underscores) for consistency
const Map<String, WeatherCondition> weatherConditions = {
  // CLEAR
  'clear': WeatherCondition(
    icon: Icons.wb_sunny,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5BA3D0), Color(0xFFE8A87C)],
    ),
  ),

  // PARTLY_CLOUDY
  'partly_cloudy': WeatherCondition(
    icon: Icons.wb_cloudy,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6BA8D8), Color(0xFFD4C5A9)],
    ),
  ),

  // CLOUDY
  'cloudy': WeatherCondition(
    icon: Icons.cloud,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF7B9BAC), Color(0xFFA8B5BE)],
    ),
  ),

  // OVERCAST
  'overcast': WeatherCondition(
    icon: Icons.cloud_queue,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6B7F8F), Color(0xFF8B99A8)],
    ),
  ),

  // DRIZZLE
  'drizzle': WeatherCondition(
    icon: Icons.grain,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6D8693), Color(0xFF8FA3AE)],
    ),
  ),

  // RAIN
  'rain': WeatherCondition(
    icon: Icons.umbrella,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF517A8F), Color(0xFF6B8FA3)],
    ),
  ),

  // HEAVY_RAIN
  'heavy_rain': WeatherCondition(
    icon: Icons.thunderstorm,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3E5F73), Color(0xFF567385)],
    ),
  ),

  // STORM
  'storm': WeatherCondition(
    icon: Icons.flash_on,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3D4E5F), Color(0xFF526175)],
    ),
  ),

  // SNOW
  'snow': WeatherCondition(
    icon: Icons.ac_unit,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6E93AD), Color(0xFFB4D4E1)],
    ),
  ),

  // SLEET
  'sleet': WeatherCondition(
    icon: Icons.ac_unit,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF718A98), Color(0xFF95ADB8)],
    ),
  ),

  // FOG
  'fog': WeatherCondition(
    icon: Icons.blur_on,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF7E8E99), Color(0xFFA3B1BA)],
    ),
  ),

  // WINDY
  'windy': WeatherCondition(
    icon: Icons.air,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5A92B8), Color(0xFF7DACC9)],
    ),
  ),
};

/// Function to normalize raw API weather condition text to UI condition
/// Uses priority-based keyword matching with case-insensitive search
String normalizeWeatherCondition(String conditionText) {
  final lowerCondition = conditionText.toLowerCase().trim();

  // 1. STORM - Highest priority
  if (lowerCondition.contains('thunder') ||
      lowerCondition.contains('storm') ||
      lowerCondition.contains('tornado') ||
      lowerCondition.contains('squall')) {
    return 'storm';
  }

  // 2. HEAVY_RAIN
  if ((lowerCondition.contains('heavy') && lowerCondition.contains('rain')) ||
      lowerCondition.contains('torrential') ||
      lowerCondition.contains('rainstorm')) {
    return 'heavy_rain';
  }

  // 3. SLEET
  if (lowerCondition.contains('sleet') ||
      lowerCondition.contains('hail') ||
      lowerCondition.contains('ice pellets') ||
      lowerCondition.contains('freezing rain')) {
    return 'sleet';
  }

  // 4. SNOW
  if (lowerCondition.contains('snow') ||
      lowerCondition.contains('blizzard') ||
      lowerCondition.contains('flurries')) {
    return 'snow';
  }

  // 5. DRIZZLE
  if (lowerCondition.contains('drizzle') ||
      lowerCondition.contains('light rain') ||
      lowerCondition.contains('patchy light rain')) {
    return 'drizzle';
  }

  // 6. RAIN (excluding conditions already covered by HEAVY_RAIN or DRIZZLE)
  if (lowerCondition.contains('rain') || lowerCondition.contains('shower')) {
    // This will catch rain/shower but not heavy rain or drizzle (already matched above)
    return 'rain';
  }

  // 7. FOG
  if (lowerCondition.contains('fog') ||
      lowerCondition.contains('mist') ||
      lowerCondition.contains('haze')) {
    return 'fog';
  }

  // 8. WINDY
  if (lowerCondition.contains('wind') ||
      lowerCondition.contains('gust') ||
      lowerCondition.contains('gale')) {
    return 'windy';
  }

  // 9. OVERCAST
  if (lowerCondition.contains('overcast')) {
    return 'overcast';
  }

  // 10. CLOUDY
  if (lowerCondition.contains('cloudy')) {
    return 'cloudy';
  }

  // 11. PARTLY_CLOUDY
  if (lowerCondition.contains('partly') ||
      lowerCondition.contains('broken clouds') ||
      lowerCondition.contains('scattered clouds')) {
    return 'partly_cloudy';
  }

  // 12. CLEAR (fallback)
  if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
    return 'clear';
  }

  // Default fallback if no conditions match
  return 'clear';
}

/// Function to get WeatherCondition based on conditionText
/// Uses the new normalization system with priority-based matching
WeatherCondition getWeatherCondition(String conditionText) {
  final normalizedCondition = normalizeWeatherCondition(conditionText);
  
  // Direct match with normalized condition
  if (weatherConditions.containsKey(normalizedCondition)) {
    return weatherConditions[normalizedCondition]!;
  }

  // Fallback to clear if normalized condition not found (shouldn't happen with current implementation)
  return weatherConditions['clear']!;
}

/// Extract accent color from gradient (first color)
/// Used for dynamic icon coloring in seven_day_row
Color getAccentColorFromCondition(String conditionText) {
  final weatherCondition = getWeatherCondition(conditionText);
  return weatherCondition.gradient.colors.first;
}

/// Lighten color for dark theme compatibility
/// Uses HSL color space for consistent lightening
Color lightenColorForTheme(Color color, bool isDarkTheme) {
  if (!isDarkTheme) {
    return color; // Use original color for light theme
  }
  
  // Convert to HSL for consistent lightening
  final hslColor = HSLColor.fromColor(color);
  final lightened = hslColor.withLightness(
    (hslColor.lightness + 0.3).clamp(0.0, 1.0)
  );
  
  return lightened.toColor();
}

/// Check if color contrast is sufficient for readability
/// Only applies contrast checking for dark theme to preserve accent colors in light theme
Color getReadableIconColor(Color color, Color backgroundColor, bool isDarkTheme) {
  // In light theme, always use the accent color (no white fallback)
  if (!isDarkTheme) {
    return color;
  }
  
  // For dark theme, check contrast and fallback to white if insufficient
  final luminance = color.computeLuminance();
  final backgroundLuminance = backgroundColor.computeLuminance();
  
  // Calculate contrast ratio (simplified)
  final contrastRatio = (luminance + 0.05) / (backgroundLuminance + 0.05);
  
  // If contrast is too low (less than 2.0), use white
  if (contrastRatio < 2.0) {
    return Colors.white;
  }
  
  return color;
}

/// Get theme-appropriate icon color for seven_day_row
/// Implements the new rules:
/// 1. Light Theme: Always use accent color (no white fallback)
/// 2. Dark Theme: Use lightened accent color with contrast checking
/// 3. White only as absolute last resort
Color getSevenDayIconColor(String conditionText, bool isDarkTheme) {
  final accentColor = getAccentColorFromCondition(conditionText);
  
  // For light theme, always use the accent color directly
  if (!isDarkTheme) {
    return accentColor;
  }
  
  // For dark theme, apply lightening and then check contrast
  final themeAdaptedColor = lightenColorForTheme(accentColor, isDarkTheme);
  
  // For seven_day_row, the background is typically surface color
  final surfaceColor = const Color(0xFF1E1E1E);
  
  return getReadableIconColor(themeAdaptedColor, surfaceColor, isDarkTheme);
}
