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
import '../models/location_error.dart';
import '../models/location_item.dart';
import '../services/notification_service.dart';

/// Layar utama aplikasi.
/// - Menampilkan cuaca saat ini, kontrol lokasi (GPS / pilih kota), dan ringkasan harian.
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

  /// Muat preferensi pengguna (favorit, preferensi GPS) dan inisialisasi data cuaca.
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

  /// Tambah/hapus kota pada daftar favorit pengguna dan simpan ke SharedPreferences.
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

  /// Inisialisasi pengambilan data cuaca berdasarkan lokasi GPS saat ini.
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

  /// Ganti lokasi secara manual (kota) dan hentikan update GPS hingga user mengaktifkannya kembali.
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

  /// Aktifkan kembali tracking GPS dan ambil data cuaca berdasarkan koordinat terkini.
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

  /// Membuat daftar item lokasi untuk dialog pemilihan kota
  /// Including "Current Location" as the first item
  List<LocationItem> _buildLocationItems(ThemeData theme) {
    final List<LocationItem> items = [];
    
    // Add Current Location as first item
    final currentLocationItem = LocationItem.currentLocation(
      cityName: _useGPS ? _currentLocation : null,
      isGpsAvailable: true, // You can add logic to check GPS availability
    );
    items.add(currentLocationItem);
    
    // Add popular cities
    const popularCities = [
      'Jakarta',
      'Bandung',
      'Surabaya',
      'Yogyakarta',
      'Medan',
      'Makassar',
      'Denpasar',
      'Palembang',
    ];
    
    for (final city in popularCities) {
      items.add(LocationItem.city(city));
    }
    
    return items;
  }

  /// Build a user-friendly error widget based on error type
  Widget _buildErrorWidget(dynamic error) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    
    final isLocationNotFound = LocationErrorHandler.isLocationNotFound(error);
    final errorTitle = LocationErrorHandler.getErrorTitle(error);
    final errorMessage = LocationErrorHandler.getErrorMessage(error);
    final suggestions = LocationErrorHandler.getRecoverySuggestions(error);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              isLocationNotFound ? Icons.location_off : Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            
            // Error title
            Text(
              errorTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Error message
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Action buttons based on error type
            _buildActionButtons(error, colorScheme),
            
            const SizedBox(height: 24),
            
            // Suggestions section
            if (suggestions.isNotEmpty)
              _buildSuggestionsSection(suggestions, colorScheme, brightness),
          ],
        ),
      ),
    );
  }

  /// Build action buttons based on error type
  Widget _buildActionButtons(dynamic error, ColorScheme colorScheme) {
    if (LocationErrorHandler.isLocationNotFound(error)) {
      return Column(
        children: [
          // Retry with same location
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _weatherFuture = _weatherService.fetchWeatherWithRetrofit(_currentLocation);
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Try different location
          OutlinedButton.icon(
            onPressed: () => _showCitySelectionDialog(context),
            icon: const Icon(Icons.search),
            label: const Text('Cari Lokasi Lain'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          
          // Use GPS
          if (!_useGPS)
            TextButton.icon(
              onPressed: _useGPSLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Gunakan GPS'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
        ],
      );
    } else if (error is NetworkException) {
      return Column(
        children: [
          // Retry for network errors
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _weatherFuture = _weatherService.fetchWeatherWithRetrofit(_currentLocation);
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Use GPS if available
          if (!_useGPS)
            TextButton.icon(
              onPressed: _useGPSLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Gunakan GPS'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
        ],
      );
    } else {
      // Generic retry button
      return ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _weatherFuture = _weatherService.fetchWeatherWithRetrofit(_currentLocation);
          });
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Coba Lagi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      );
    }
  }

  /// Build suggestions section
  Widget _buildSuggestionsSection(List<String> suggestions, ColorScheme colorScheme, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.getSecondaryTextColor(brightness),
            ),
          ),
          const SizedBox(height: 8),
          ...suggestions.take(3).map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getSecondaryTextColor(brightness),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
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
                children: _buildLocationItems(theme).map((locationItem) {
                  return GestureDetector(
                    onLongPress: locationItem.isCurrentLocation 
                        ? null 
                        : () async {
                            await _toggleFavorite(locationItem.name);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _favorites.contains(locationItem.name)
                                      ? 'Ditambahkan ke favorit: ${locationItem.name}'
                                      : 'Dihapus dari favorit: ${locationItem.name}',
                                ),
                              ),
                            );
                          },
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: locationItem.isCurrentLocation 
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        foregroundColor: locationItem.isCurrentLocation 
                            ? theme.colorScheme.onSecondary
                            : theme.colorScheme.onPrimary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: locationItem.isClickable 
                          ? () {
                              if (locationItem.isCurrentLocation) {
                                Navigator.of(dialogContext).pop();
                                _useGPSLocation();
                              } else {
                                _changeLocation(locationItem.name);
                                Navigator.of(dialogContext).pop();
                              }
                            }
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            locationItem.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (locationItem.displaySubtitle != null)
                            Text(
                              locationItem.displaySubtitle!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: (locationItem.isCurrentLocation 
                                    ? theme.colorScheme.onSecondary
                                    : theme.colorScheme.onPrimary).withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
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
              child: const Text('Tutup'),
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
                      return _buildErrorWidget(snapshot.error!);
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

                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          if (!mounted) return;
                          widget.onWeatherChanged?.call(weather);
                          // if using GPS, update location display using weather.locationName
                          if (_useGPS) {
                            setState(
                              () => _currentLocation = weather.locationName,
                            );
                            widget.onLocationChanged?.call(_currentLocation);
                          }
                          // show an in-app and system weather notification
                          // (WhatsApp-like banner + optional system notification)
                          if (mounted) {
                            NotificationService().showWeatherNotification(
                              weather,
                            );
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
                                              shrinkWrap: true,
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
