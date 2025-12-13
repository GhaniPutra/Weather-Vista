/// Model data cuaca lengkap yang merepresentasikan semua informasi cuaca untuk satu lokasi.
/// 
/// Data yang disimpan:
/// - Suhu saat ini, min/max, feels like
/// - Kondisi cuaca (sunny, cloudy, rainy, dll)
/// - Lokasi (nama kota, region, latitude/longitude)
/// - Detail cuaca (kelembapan, tekanan, angin, UV index, sunrise/sunset)
/// - Data cuaca per jam (untuk grafik/timeline)
/// 
/// Model ini digunakan di seluruh aplikasi untuk menampilkan data cuaca di UI.
/// Data berasal dari API response yang di-parse di WeatherService.
class WeatherModel {
  /// Suhu saat ini dalam Celsius
  final double tempC;
  /// Deskripsi kondisi cuaca (contoh: "Partly cloudy", "Rainy", "Sunny")
  final String conditionText;
  /// Nama lokasi (nama kota)
  final String locationName;
  /// Latitude (lintang) dari lokasi
  final double latitude;
  /// Longitude (bujur) dari lokasi
  final double longitude;
  /// Region atau district tempat lokasi berada
  final String region;
  /// Suhu minimum hari ini (dalam Celsius)
  final double minTemp;
  /// Suhu maksimum hari ini (dalam Celsius)
  final double maxTemp;
  /// Suhu yang terasa seperti (wind chill / heat index)
  final double feelsLike;
  /// Tekanan udara dalam milibar (hPa)
  final double pressure;
  /// Kelembapan udara dalam persentase (0-100%)
  final int humidity;
  /// Kecepatan angin dalam km/h
  final double windSpeed;
  /// Indeks UV (0-11+, semakin tinggi semakin berbahaya)
  final double uvIndex;
  /// Waktu matahari terbit dalam format HH:mm (contoh: "05:30")
  final String sunrise;
  /// Waktu matahari terbenam dalam format HH:mm (contoh: "18:45")
  final String sunset;
  /// Daftar data cuaca per jam (untuk timeline/grafik)
  final List<HourWeather> hourly;

  /// Konstruktor dengan semua parameter yang diperlukan
  WeatherModel({
    required this.tempC,
    required this.conditionText,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.region,
    required this.minTemp,
    required this.maxTemp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.hourly,
  });

  /// Factory constructor untuk parsing JSON response dari WeatherAPI menjadi WeatherModel.
  /// 
  /// JSON structure dari WeatherAPI:
  /// {
  ///   "current": { "temp_c": 28, "condition": {...}, "humidity": 80, ...},
  ///   "location": { "name": "Jakarta", "lat": -6.2, "lon": 106.8, ...},
  ///   "forecast": {
  ///     "forecastday": [
  ///       {
  ///         "day": { "mintemp_c": 25, "maxtemp_c": 32, ...},
  ///         "astro": { "sunrise": "05:30", "sunset": "18:45", ...},
  ///         "hour": [ {...}, {...}, ...] // 24 items per hour
  ///       }
  ///     ]
  ///   }
  /// }
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    /// Extract 'current' object (data cuaca saat ini)
    final current = json['current'];
    /// Extract 'location' object (informasi lokasi)
    final location = json['location'];
    /// Extract data untuk 1 hari pertama dari forecast (array forecastday[0])
    final forecastDay = json['forecast']['forecastday'][0];
    /// Extract 'day' object dari forecast (min/max temp, dll)
    final day = forecastDay['day'];
    /// Extract 'astro' object (sunrise/sunset)
    final astro = forecastDay['astro'];

    /// Ambil data per jam dan filter hanya 4 jam (setiap 6 jam) untuk tampilan simplifikasi
    // Ambil data per jam (kita ambil 4 jam ke depan dari waktu sekarang untuk simplifikasi UI)
    List<HourWeather> hours = [];
    /// Array 'hour' berisi 24 item (0:00 - 23:00 setiap jam)
    List<dynamic> hourList = forecastDay['hour'];
    
    /// Loop dengan step 6: ambil jam 0, 6, 12, 18 (max 4 item)
    for (int i = 0; i < hourList.length; i+=6) { 
        if(hours.length < 4) {
           /// Parse setiap item jam menjadi HourWeather object
           hours.add(HourWeather.fromJson(hourList[i]));
        }
    }

    /// Return WeatherModel yang sudah lengkap dengan semua data yang di-extract
    return WeatherModel(
      /// Suhu saat ini dari object 'current'
      tempC: current['temp_c'].toDouble(),
      /// Deskripsi kondisi dari nested object current.condition.text
      conditionText: current['condition']['text'],
      /// Latitude dari location object (default 0 jika tidak ada)
      latitude: (location['lat'] ?? 0).toDouble(),
      /// Longitude dari location object (default 0 jika tidak ada)
      longitude: (location['lon'] ?? 0).toDouble(),
      /// Nama kota/lokasi
      locationName: location['name'],
      /// Region atau district
      region: location['region'],
      /// Suhu minimum dari object day
      minTemp: day['mintemp_c'].toDouble(),
      /// Suhu maksimum dari object day
      maxTemp: day['maxtemp_c'].toDouble(),
      /// Suhu yang terasa (wind chill atau heat index)
      feelsLike: current['feelslike_c'].toDouble(),
      /// Tekanan dalam milibar
      pressure: current['pressure_mb'].toDouble(),
      /// Kelembapan (0-100%)
      humidity: current['humidity'].toInt(),
      /// Kecepatan angin dalam km/h
      windSpeed: current['wind_kph'].toDouble(),
      /// Indeks UV
      uvIndex: current['uv'].toDouble(),
      /// Waktu sunrise
      sunrise: astro['sunrise'],
      /// Waktu sunset
      sunset: astro['sunset'],
      /// Daftar data cuaca per jam yang sudah di-filter
      hourly: hours,
    );
  }
}

/// Model data cuaca per jam (untuk timeline atau grafik).
/// 
/// Digunakan dalam HourlyWeatherCard untuk menampilkan detail cuaca di setiap jam.
class HourWeather {
  /// Suhu di jam ini (Celsius)
  final double tempC;
  /// URL icon cuaca dari WeatherAPI
  final String iconUrl;
  /// Waktu dalam format "2023-10-10 10:00"
  final String time;
  /// Kecepatan angin di jam ini (km/h)
  final double windKph;
  /// Indeks UV di jam ini
  final double uv;
  /// Kelembapan di jam ini (0-100%)
  final int humidity;

  /// Konstruktor HourWeather
  HourWeather({
    required this.tempC,
    required this.iconUrl,
    required this.time,
    required this.windKph,
    required this.uv,
    required this.humidity,
  });

  /// Factory constructor untuk parsing JSON dari hourly data.
  /// 
  /// JSON structure satu item jam:
  /// {
  ///   "temp_c": 28,
  ///   "condition": { "icon": "//cdn.weatherapi.com/weather/128x128/day/113.png", ...},
  ///   "time": "2023-10-10 10:00",
  ///   "wind_kph": 15,
  ///   "uv": 8,
  ///   "humidity": 65
  /// }
  factory HourWeather.fromJson(Map<String, dynamic> json) {
    return HourWeather(
      /// Suhu Celsius saat jam ini
      tempC: json['temp_c'].toDouble(),
      /// Lengkapi URL icon dengan scheme (API return tanpa https)
      iconUrl: 'https:${json['condition']['icon']}',
      /// Waktu dalam format "2023-10-10 10:00"
      time: json['time'],
      /// Kecepatan angin (default 0 jika tidak ada)
      windKph: (json['wind_kph'] ?? 0).toDouble(),
      /// Indeks UV (default 0 jika tidak ada)
      uv: (json['uv'] ?? 0).toDouble(),
      /// Kelembapan (default 0 jika tidak ada)
      humidity: (json['humidity'] ?? 0).toInt(),
    );
  }
}