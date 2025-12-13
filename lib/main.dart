// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// screens
import 'screens/weather_home_screen.dart';
import 'screens/notification_screen.dart';
import 'models/weather_model.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Gradient global
class AppGradients {
  static const light = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDFF6FA), Color(0xFFF6E8DA)],
  );

  static const dark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F0F), Color(0xFF1B1B1B)],
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isDark = false;

  void _toggleTheme(bool isDark) => setState(() => _isDark = isDark);

  static const _lightPrimary = Color(0xFFEF6C00);
  static const _darkPrimary = Color(0xFFFFA726);

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: Colors.white,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: Colors.black,
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
        ),
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: WelcomeScreen(
        onGetStarted: () {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  MainAppScreen(isDark: _isDark, onThemeChanged: _toggleTheme),
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------------
/// MAIN APP SCREEN
/// ------------------------------
class MainAppScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const MainAppScreen({
    required this.isDark,
    required this.onThemeChanged,
    super.key,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _index = 0;
  bool showAbout = false;
  WeatherModel? _currentWeather;
  String _selectedLocation = 'Jakarta';

  void _openAbout() => setState(() => showAbout = true);
  void _closeAbout() => setState(() => showAbout = false);

  @override
  Widget build(BuildContext context) {
    final pages = [
      WeatherHomeScreen(
        onWeatherChanged: (w) => setState(() {
          _currentWeather = w;
          _selectedLocation = w.locationName;
        }),
        onLocationChanged: (loc) => setState(() => _selectedLocation = loc),
      ),
      NotificationScreen(
        onBack: () => setState(() => _index = 0),
        weather: _currentWeather,
        location: _selectedLocation,
      ),
      SettingsScreen(
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
        onBack: () => setState(() => _index = 0),
        onAboutTap: _openAbout,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? AppGradients.dark
                    : AppGradients.light,
              ),
            ),
          ),

          Positioned.fill(
            child: showAbout
                ? AboutScreen(onBack: _closeAbout, isDark: widget.isDark)
                : pages[_index],
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF202020)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.12 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    index: 0,
                    current: _index,
                    label: "Home",
                    icon: Icons.home,
                    onTap: (i) => setState(() => _index = i),
                  ),
                  _NavItem(
                    index: 1,
                    current: _index,
                    label: "Notification",
                    icon: Icons.notifications,
                    onTap: (i) => setState(() => _index = i),
                  ),
                  _NavItem(
                    index: 2,
                    current: _index,
                    label: "Settings",
                    icon: Icons.settings,
                    onTap: (i) => setState(() => _index = i),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  final IconData icon;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.current,
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
