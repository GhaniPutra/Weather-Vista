import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:simple_weather/screens/weather_home_screen.dart';
import 'package:simple_weather/services/weather_service.dart';
import 'package:simple_weather/models/weather_model.dart';

void main() {
  testWidgets('Selected location persists across reload', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'use_gps': false,
      'selected_location': 'Jakarta',
    });

    // Provide a fake weather service that returns immediately so UI renders
    final fakeService = _FakeWeatherService();
    await tester.pumpWidget(
      MaterialApp(
        home: WeatherHomeScreen(
          onWeatherChanged: (_) {},
          onLocationChanged: (_) {},
          weatherService: fakeService,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Open city selection dialog
    await tester.tap(find.byKey(const Key('location_button')));
    await tester.pumpAndSettle();

    // Tap Bandung
    await tester.tap(find.text('Bandung'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Read prefs
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_location'), 'Bandung');
    expect(prefs.getBool('use_gps'), false);

    // Recreate widget to simulate app restart
    await tester.pumpWidget(Container());
    await tester.pumpWidget(
      MaterialApp(
        home: WeatherHomeScreen(
          onWeatherChanged: (_) {},
          onLocationChanged: (_) {},
          weatherService: fakeService,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Check that the UI shows Bandung as current location (label or in card)
    expect(find.text('Bandung'), findsWidgets);
  });
}

class _FakeWeatherService extends WeatherService {
  @override
  Future<WeatherModel> fetchWeatherWithRetrofit(String location) async {
    return WeatherModel(
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
}
