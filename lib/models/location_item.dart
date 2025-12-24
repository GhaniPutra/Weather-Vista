/// Model untuk item lokasi dalam daftar popular cities
///
/// Dapatmerepresentasikan:
// - Kota regular (Jakarta, Bandung, dll)
// - "Current Location" dengan koordinat GPS
class LocationItem {
  /// Nama lokasi (nama kota atau "Current Location")
  final String name;

  /// Tipe lokasi: true untuk Current Location, false untuk kota regular
  final bool isCurrentLocation;

  /// Label opsional untuk subtitle (nama kota dari GPS)
  final String? subtitle;

  /// Koordinat latitude untuk Current Location (null untuk kota regular)
  final double? latitude;

  /// Koordinat longitude untuk Current Location (null untuk kota regular)
  final double? longitude;

  /// Status apakah GPS tersedia/diizinkan
  final bool isGpsAvailable;

  /// Konstruktor untuk LocationItem
  const LocationItem({
    required this.name,
    this.isCurrentLocation = false,
    this.subtitle,
    this.latitude,
    this.longitude,
    this.isGpsAvailable = true,
  });

  /// Factory constructor untuk kota regular
  factory LocationItem.city(String cityName) {
    return LocationItem(
      name: cityName,
      isCurrentLocation: false,
    );
  }

  /// Factory constructor untuk Current Location
  factory LocationItem.currentLocation({
    String? cityName,
    double? latitude,
    double? longitude,
    bool isGpsAvailable = true,
  }) {
    return LocationItem(
      name: 'Current Location',
      isCurrentLocation: true,
      subtitle: cityName,
      latitude: latitude,
      longitude: longitude,
      isGpsAvailable: isGpsAvailable,
    );
  }

  /// Memeriksa apakah item ini dapat diklik
  bool get isClickable {
    if (!isCurrentLocation) return true;
    return isGpsAvailable;
  }

  /// Mendapatkan display text untuk UI
  String get displayName {
    if (isCurrentLocation) {
      return 'Current Location';
    }
    return name;
  }

  /// Mendapatkan subtitle untuk UI
  String? get displaySubtitle {
    if (isCurrentLocation && subtitle != null) {
      return subtitle;
    }
    return null;
  }

  /// Mendapatkan icon untuk UI
  String get displayIcon {
    if (isCurrentLocation) {
      return '📍';
    }
    return '🏙️';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationItem &&
        other.name == name &&
        other.isCurrentLocation == isCurrentLocation &&
        other.subtitle == subtitle &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isGpsAvailable == isGpsAvailable;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      isCurrentLocation,
      subtitle,
      latitude,
      longitude,
      isGpsAvailable,
    );
  }

  @override
  String toString() {
    return 'LocationItem(name: $name, isCurrentLocation: $isCurrentLocation, subtitle: $subtitle, isGpsAvailable: $isGpsAvailable)';
  }
}
