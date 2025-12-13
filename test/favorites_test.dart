import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_weather/screens/weather_home_screen.dart';
import 'package:simple_weather/services/weather_service.dart';

class _FakeWeatherService extends WeatherService {
  @override
  Future<WeatherModel> fetchWeatherWithRetrofit(String location) async =>
      WeatherModel(
        tempC: 25.0,
        conditionText: 'Sunny',
        locationName: location,
        latitude: 0.0,
        longitude: 0.0,
        region: '',
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
}

void main() {
  testWidgets('Long press city adds to favorites and persists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'use_gps': false,
      'selected_location': 'Jakarta',
      'favorites': <String>[],
    });

    final fake = _FakeWeatherService();

    await tester.pumpWidget(
      MaterialApp(
        home: WeatherHomeScreen(
          weatherService: fake,
          onWeatherChanged: (_) {},
          onLocationChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    // Open city selection dialog
    await tester.tap(find.byKey(const Key('location_button')));
    await tester.pumpAndSettle();

    // Long press Bandung to add to favorites
    await tester.longPress(find.text('Bandung'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorites')!.contains('Bandung'), isTrue);

    // Now favorites should show on main screen
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.text('Bandung'), findsWidgets);
  });
}
