  /// -----------------------------------------------------------------------------
  /// File: weather_service.dart
  /// -----------------------------------------------------------------------------
  /// File ini berisi layanan (service) untuk mengambil data cuaca dari API.
  ///
  /// Penjelasan:
  /// - class WeatherService: Berisi fungsi untuk mengambil data cuaca dari WeatherAPI.
  ///   - fetchWeather: Mengambil data cuaca menggunakan http dan mengembalikan WeatherModel.
  ///   - fetchWeatherWithRetrofit: (jika ada) Mengambil data cuaca menggunakan Dio + Retrofit.
  ///   - Mengatur API key dan host API.
  ///   - Menangani error dan parsing data JSON dari API.
  ///
  /// Catatan:
  /// - Service ini digunakan oleh widget utama untuk mendapatkan data cuaca berdasarkan lokasi.
  /// - Untuk menambah endpoint atau fitur lain, tambahkan fungsi baru di class ini.
  /// -----------------------------------------------------------------------------
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:flutter/foundation.dart';
  import 'package:dio/dio.dart';
  import 'api_client.dart';
  import '../models/weather_model.dart';
  import '../config.dart';

  /// -----------------------------------------------------------------------------
  /// class WeatherService
  /// -----------------------------------------------------------------------------
  /// Berisi fungsi untuk mengambil data cuaca dari WeatherAPI.
  /// - fetchWeather: Mengambil data cuaca menggunakan http dan mengembalikan WeatherModel.
  /// - fetchWeatherWithRetrofit: (jika ada) Mengambil data cuaca menggunakan Dio + Retrofit.
  /// - Mengatur API key dan host API.
  /// - Menangani error dan parsing data JSON dari API.
  ///
  /// Service ini digunakan oleh widget utama untuk mendapatkan data cuaca berdasarkan lokasi.
  /// Untuk menambah endpoint atau fitur lain, tambahkan fungsi baru di class ini.
  /// -----------------------------------------------------------------------------
  /// Class yang berisi semua fungsi untuk mengambil data cuaca dari WeatherAPI.
  /// 
  /// Fungsi yang tersedia:
  /// - fetchWeather: Menggunakan package http (lebih sederhana)
  /// - fetchWeatherWithRetrofit: Menggunakan Dio + Retrofit (lebih modern dan tipe-aman)
  ///
  /// Kedua fungsi melakukan hal yang sama: fetch data cuaca dan return WeatherModel.
  /// Service ini digunakan oleh halaman utama untuk mendapatkan data cuaca berdasarkan lokasi.
  class WeatherService {
    /// API Key untuk WeatherAPI.com - diambil dari file config.dart
    /// Ini adalah kunci untuk mengakses API mereka (jangan bagikan ke publik!)
    static const String apiKey = weatherApiKey;
    
    /// Host API WeatherAPI tanpa skema (http/https)
    /// Contoh request lengkap: https://api.weatherapi.com/v1/forecast.json?key=xxx&q=Jakarta
    static const String apiHost = 'api.weatherapi.com';

    /// Fungsi untuk mengambil data cuaca menggunakan package http (lebih sederhana).
    /// 
    /// Parameter:
    /// - location: Nama kota atau koordinat (contoh: "Jakarta" atau "-6.21,106.85")
    /// 
    /// Return: WeatherModel berisi data cuaca (suhu, kondisi, detail, dll)
    /// 
    /// Throws: Exception jika lokasi kosong, request gagal, atau parsing error
    Future<WeatherModel> fetchWeather(String location) async {
      /// Normalize input dengan menghilangkan whitespace
      final loc = location.trim();
      if (loc.isEmpty) {
        throw Exception('Lokasi kosong. Masukkan nama kota atau koordinat (contoh: "Jakarta" atau "-6.21,106.85").');
      }

      /// Bangun URL dengan paramete query yang benar (Uri.https auto-encode)
      // Bangun URI dengan benar supaya parameter di-encode otomatis
      final uri = Uri.https(apiHost, '/v1/forecast.json', {
        'key': apiKey,
        'q': loc,
        'days': '1',          // Ambil prakiraan 1 hari (termasuk hari ini)
        'aqi': 'no',          // Tidak perlu data kualitas udara
        'alerts': 'no',       // Tidak perlu alert cuaca
      });

      /// Print URI untuk debugging (aktifkan jika ada masalah)
      // Debug: cetak uri yang dipanggil (opsional) — aktifkan untuk membantu debugging
      debugPrint('WeatherService request URI: $uri');

      /// Kirim GET request ke API
      final response = await http.get(uri);

      /// Cek status code response
      if (response.statusCode == 200) {
        /// Jika sukses (200), parse JSON response menjadi WeatherModel
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else {
        /// Jika error, coba extract pesan error dari API untuk ditampilkan ke user
        // Coba parse body untuk mengambil pesan error yang spesifik dari API
        String apiMessage = 'Unknown error';
        try {
          final bodyJson = jsonDecode(response.body);
          if (bodyJson is Map && bodyJson['error'] != null) {
            final err = bodyJson['error'];
            /// WeatherAPI return error dengan berbagai nama field (message, massage, msg)
            apiMessage = err['message'] ?? err['massage'] ?? err['msg'] ?? apiMessage;
          } else if (bodyJson is String) {
            apiMessage = bodyJson;
          } else {
            apiMessage = response.body;
          }
        } catch (_) {
          apiMessage = response.body;
        }

        /// Log error untuk debugging
        // Logging singkat untuk membantu debugging (bisa dinonaktifkan di produksi)
        debugPrint('Weather API response (${response.statusCode}): ${response.body}');

        /// Throw exception dengan pesan error lengkap
        throw Exception('Gagal mengambil data cuaca. Status: ${response.statusCode}. Pesan: $apiMessage');
      }
    }

    /// Fungsi alternatif untuk mengambil data cuaca menggunakan Dio + Retrofit.
    /// 
    /// Keuntungan Retrofit:
    /// - Type-safe: validasi parameter saat compile time
    /// - Auto-parsing: JSON response otomatis di-convert ke object
    /// - Interceptors: mudah menambah authentication, logging, dll
    /// 
    /// Catatan:
    /// - Pastikan sudah generate file api_client.g.dart dengan menjalankan:
    ///   flutter pub run build_runner build
    /// 
    /// Parameter:
    /// - location: Nama kota atau koordinat (contoh: "Jakarta" atau "-6.21,106.85")
    /// 
    /// Return: WeatherModel berisi data cuaca
    /// 
    /// Throws: Exception jika lokasi kosong atau request gagal
    // Alternative: fetch using Dio + Retrofit-generated `ApiClient`.
    // Requires running `flutter pub run build_runner build` to generate `api_client.g.dart`.
    Future<WeatherModel> fetchWeatherWithRetrofit(String location) async {
      /// Normalize input dengan menghilangkan whitespace
      final loc = location.trim();
      if (loc.isEmpty) {
        throw Exception('Lokasi kosong. Masukkan nama kota atau koordinat.');
      }

      /// Buat instance Dio (HTTP client dengan fitur lebih)
      final dio = Dio();
      /// Buat instance ApiClient dengan Dio (auto-generated by Retrofit)
      final client = ApiClient(dio);

      try {
        /// Call getForecast endpoint dengan parameter yang diperlukan
        /// Retrofit otomatis build URL dan parse response
        final json = await client.getForecast(apiKey, loc, '1', 'no', 'no');
        /// Parse JSON response menjadi WeatherModel
        return WeatherModel.fromJson(json);
      } catch (e) {
        /// Log error untuk debugging
        debugPrint('Retrofit error: $e');
        /// Re-throw error agar bisa di-handle oleh caller
        rethrow;
      }
    }
  }