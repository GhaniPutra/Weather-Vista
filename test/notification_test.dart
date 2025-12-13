import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_weather/screens/notification_screen.dart';
import 'package:simple_weather/models/weather_model.dart';

void main() {
  testWidgets('NotificationScreen displays weather and location', (
    WidgetTester tester,
  ) async {
    final sample = WeatherModel(
      tempC: 25.0,
      conditionText: 'Sunny',
      locationName: 'Bandung',
      latitude: 0.0,
      longitude: 0.0,
      region: 'Jawa Barat',
      minTemp: 20.0,
      maxTemp: 30.0,
      feelsLike: 25.0,
      pressure: 1010.0,
      humidity: 80,
      windSpeed: 10.0,
      uvIndex: 5.0,
      sunrise: '05:30',
      sunset: '18:00',
      hourly: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationScreen(
          onBack: () {},
          weather: sample,
          location: 'Bandung',
        ),
      ),
    );

    // Should display location name and temperature
    expect(find.textContaining('Bandung', findRichText: false), findsOneWidget);
    expect(find.textContaining('25°C', findRichText: false), findsOneWidget);
  });
}
