// lib/screens/weather_home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/details_card.dart';
import '../widgets/hourly_weather_card.dart';
import '../widgets/seven_day_row.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class WeatherHomeScreen extends StatefulWidget {
  final ValueChanged<WeatherModel>? onWeatherChanged;
  final ValueChanged<String>? onLocationChanged;

  final WeatherService? weatherService;

  const WeatherHomeScreen({
    this.onWeatherChanged,
    this.onLocationChanged,
    this.weatherService,
    super.key,
  });

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  late final WeatherService _weatherService;
  Future<WeatherModel>? _weatherFuture;
  StreamSubscription<Position>? _positionStreamSub;
  String _currentLocation = 'Jakarta';
  bool _useGPS = true;

  /// When true, ignore incoming GPS stream updates (set when user manually selects a city)
  bool _ignoreGpsUpdates = false;

  /// User saved favorite locations
  List<String> _favorites = [];
  WeatherModel? _lastNotifiedWeather;
  static const _prefSelectedLocation = 'selected_location';
  static const _prefUseGps = 'use_gps';

  @override
  void initState() {
    super.initState();
    _weatherService = widget.weatherService ?? WeatherService();
    _loadPreferencesAndInit();
  }

  Future<void> _loadPreferencesAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final useGps = prefs.getBool(_prefUseGps) ?? true;
    final savedLocation = prefs.getString(_prefSelectedLocation) ?? 'Jakarta';
    _favorites = prefs.getStringList('favorites') ?? [];
    if (!mounted) return;
    if (useGps) {
      _initWeather();
    } else {
      // Use saved location
      setState(() {
        _useGPS = false;
        _currentLocation = savedLocation;
        _weatherFuture = _weatherService.fetchWeatherWithRetrofit(
          savedLocation,
        );
        _ignoreGpsUpdates = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onLocationChanged?.call(_currentLocation);
      });
    }
  }

  Future<void> _toggleFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(city)) {
        _favorites.remove(city);
      } else {
        _favorites.add(city);
      }
    });
    await prefs.setStringList('favorites', _favorites);
  }

  Future<void> _initWeather() async {
    try {
      final pos = await _determinePosition();
      final loc = '${pos.latitude},${pos.longitude}';
      if (!mounted) return;
      setState(() {
        _weatherFuture = _weatherService.fetchWeatherWithRetrofit(loc);
        _currentLocation = 'Menggunakan GPS...';
        _useGPS = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onLocationChanged?.call(_currentLocation);
      });

      final settings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 200,
      );
      // allow GPS updates
      _ignoreGpsUpdates = false;
      await _positionStreamSub?.cancel();
      _positionStreamSub =
          Geolocator.getPositionStream(locationSettings: settings).listen((
            Position p,
          ) {
            // ignore any GPS events if user manually selected a city
            if (_ignoreGpsUpdates) return;
            final newLoc = '${p.latitude},${p.longitude}';
            if (!mounted) return;
            setState(() {
              _weatherFuture = _weatherService.fetchWeatherWithRetrofit(newLoc);
            });
          });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherFuture = _weatherService.fetchWeatherWithRetrofit('Jakarta');
        _currentLocation = 'Jakarta';
        _useGPS = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onLocationChanged?.call(_currentLocation);
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tidak dapat mengambil lokasi. Menampilkan cuaca untuk Jakarta.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor:
                  Theme.of(context).snackBarTheme.backgroundColor ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[200]),
              duration: const Duration(seconds: 4),
            ),
          );
        });
      }
    }
  }

  Future<void> _changeLocation(String city) async {
    // When user manually selects a city, ignore any pending GPS updates
    _ignoreGpsUpdates = true;
    setState(() {
      _currentLocation = city;
      _useGPS = false;
      _weatherFuture = _weatherService.fetchWeatherWithRetrofit(city);
    });
    await _positionStreamSub?.cancel();
    _positionStreamSub = null;
    // persist selection
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSelectedLocation, city);
    await prefs.setBool(_prefUseGps, false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onLocationChanged?.call(_currentLocation);
    });
  }

  void _useGPSLocation() {
    // re-enable GPS updates and (re)start tracking
    _ignoreGpsUpdates = false;
    setState(() {
      _useGPS = true;
      _currentLocation = 'Menggunakan GPS...';
    });
    // persist preference
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setBool(_prefUseGps, true);
    });
    _initWeather();
  }

  void _showCitySelectionDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pilih Kota/Daerah',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kota...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.6 * 255).round(),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withAlpha(
                    ((isDark ? 0.06 : 0.08) * 255).round(),
                  ),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kota Populer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                      'Jakarta',
                      'Bandung',
                      'Surabaya',
                      'Yogyakarta',
                      'Medan',
                      'Makassar',
                      'Denpasar',
                      'Palembang',
                    ].map((city) {
                      return GestureDetector(
                        onLongPress: () async {
                          await _toggleFavorite(city);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                _favorites.contains(city)
                                    ? 'Ditambahkan ke favorit: $city'
                                    : 'Dihapus dari favorit: $city',
                              ),
                            ),
                          );
                        },
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            _changeLocation(city);
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(city),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  _changeLocation(searchController.text.trim());
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Cari'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pengaturan Lokasi',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lokasi saat ini: $_currentLocation',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              const Text('Pilih opsi:'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showCitySelectionDialog(context);
              },
              child: const Text('Pilih Kota Lain'),
            ),
            if (!_useGPS)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _useGPSLocation();
                },
                child: const Text('Gunakan GPS'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Layanan lokasi dimatikan. Aktifkan GPS/Location pada perangkat.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final lightGradient = const LinearGradient(
      colors: [Color(0xFFDFF6FA), Color(0xFFF6E8DA)],
    );
    final darkGradient = const LinearGradient(
      colors: [Color(0xFF0F0F0F), Color(0xFF1B1B1B)],
    );
    final grad = brightness == Brightness.dark ? darkGradient : lightGradient;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: SafeArea(
          child: _weatherFuture == null
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                )
              : FutureBuilder<WeatherModel>(
                  future: _weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final weather = snapshot.data!;
                      // notify parent only when weather has changed
                      final shouldNotify =
                          _lastNotifiedWeather == null ||
                          _lastNotifiedWeather!.locationName !=
                              weather.locationName ||
                          _lastNotifiedWeather!.tempC != weather.tempC ||
                          _lastNotifiedWeather!.conditionText !=
                              weather.conditionText;

                      if (shouldNotify) {
                        // mark as handled immediately to avoid duplicate scheduling
                        _lastNotifiedWeather = weather;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          widget.onWeatherChanged?.call(weather);
                          // if using GPS, update location display using weather.locationName
                          if (_useGPS) {
                            setState(
                              () => _currentLocation = weather.locationName,
                            );
                            widget.onLocationChanged?.call(_currentLocation);
                          }
                        });
                      }
                      return Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 20.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lokasi:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppColors.getSecondaryTextColor(
                                                  brightness,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          _currentLocation,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.getTextColor(
                                              brightness,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Favorites row
                                        if (_favorites.isNotEmpty)
                                          SizedBox(
                                            height: 36,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _favorites.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(width: 8),
                                              itemBuilder: (context, i) {
                                                final c = _favorites[i];
                                                return ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape:
                                                        const StadiumBorder(),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    foregroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                  ),
                                                  onPressed: () =>
                                                      _changeLocation(c),
                                                  child: Text(c),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                    GestureDetector(
                                      key: const Key('location_button'),
                                      onTap: () =>
                                          _showCitySelectionDialog(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface.withAlpha(
                                            (0.18 * 255).round(),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.location_on,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                CurrentWeatherCard(weather: weather),
                                const SizedBox(height: 12),
                                // Seven day small forecast row (styled like mockup)
                                SizedBox(
                                  height: 100,
                                  child: SevenDayRow(weather: weather),
                                ),
                                const SizedBox(height: 12),
                                DetailsCard(weather: weather),
                                const SizedBox(height: 12),
                                HourlyWeatherCard(hourlyData: weather.hourly),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 18,
                            bottom: 28,
                            child: FloatingActionButton(
                              backgroundColor: colorScheme.primary,
                              child: Icon(
                                Icons.settings,
                                color: colorScheme.onPrimary,
                              ),
                              onPressed: () => _showSettingsDialog(context),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
        ),
      ),
    );
  }
}
