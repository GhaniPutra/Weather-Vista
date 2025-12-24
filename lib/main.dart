// lib/main.dart
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:simple_weather/theme/app_theme.dart';
import 'package:simple_weather/theme/theme_provider.dart';
import 'services/notification_service.dart';

// screens
import 'screens/weather_home_screen.dart';
import 'screens/notification_screen.dart';
import 'models/weather_model.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/welcome_screen.dart';

/// Fungsi entrypoint aplikasi.
/// Inisialisasi plugin dan provider (NotificationService, ThemeProvider) sebelum menjalankan app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// Root widget aplikasi yang menangani tema dan navigasi.
///
/// - Menggunakan `ThemeProvider` untuk mengontrol `themeMode`.
/// - Membungkus `MaterialApp` dengan `OverlaySupport.global` untuk menampilkan
///   in-app overlay (banner notifikasi).
/// - Menyediakan `navigatorKey` global untuk navigasi yang dipicu dari luar
///   context (digunakan pada Welcome -> Main transition).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Navigator key so we can navigate from contexts outside the MaterialApp widget tree
  static final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return OverlaySupport.global(
          child: MaterialApp(
            navigatorKey: _navKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: WelcomeScreen(
              onGetStarted: () {
                _navKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainAppScreen()),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Layar utama aplikasi setelah welcome.
/// Menyusun halaman Home, Notification, dan Settings serta menampilkan
/// bottom navigation untuk berpindah antar halaman.
/// Properti `showAbout` digunakan untuk menampilkan layar About sebagai overlay.
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

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
        onBack: () => setState(() => _index = 0),
        onAboutTap: _openAbout,
      ),
    ];

    // Scaffold utama dengan background gradient dan bottom navigation
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          Positioned.fill(
            child: showAbout
                ? AboutScreen(
                    onBack: _closeAbout,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  )
                : pages[_index],
          ),
          if (!showAbout)
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

/// Item untuk navigasi bottom bar (ikon + label)
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
