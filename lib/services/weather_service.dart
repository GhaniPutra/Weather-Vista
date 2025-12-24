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
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/weather_model.dart';
import '../models/location_error.dart';
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

  /// Validate location input and throw appropriate exceptions
  void _validateLocationInput(String location) {
    final trimmed = location.trim();
    
    if (trimmed.isEmpty) {
      throw const InvalidLocationInputException(
        'Lokasi kosong. Masukkan nama kota atau koordinat (contoh: "Jakarta" atau "-6.21,106.85").',
      );
    }
    
    // Check if it looks like coordinates
    if (trimmed.contains(',') && trimmed.split(',').length == 2) {
      final parts = trimmed.split(',');
      try {
        final lat = double.parse(parts[0].trim());
        final lon = double.parse(parts[1].trim());
        
        // Basic coordinate validation
        if (lat < -90 || lat > 90) {
          throw const InvalidLocationInputException(
            'Latitude harus berada di antara -90 dan 90.',
          );
        }
        if (lon < -180 || lon > 180) {
          throw const InvalidLocationInputException(
            'Longitude harus berada di antara -180 dan 180.',
          );
        }
      } catch (e) {
        throw const InvalidLocationInputException(
          'Format koordinat tidak valid. Gunakan format: "latitude,longitude" (contoh: "-6.21,106.85").',
        );
      }
    }
  }

  /// Fungsi untuk mengambil data cuaca menggunakan package http (lebih sederhana).
  ///
  /// Parameter:
  /// - location: Nama kota atau koordinat (contoh: "Jakarta" atau "-6.21,106.85")
  ///
  /// Return: WeatherModel berisi data cuaca (suhu, kondisi, detail, dll)
  ///
  /// Throws: LocationException jika lokasi kosong, request gagal, atau parsing error
  Future<WeatherModel> fetchWeather(String location) async {
    /// Validate and normalize input
    _validateLocationInput(location);
    
    /// Normalize input dengan menghilangkan whitespace
    final loc = location.trim();

    /// Bangun URL dengan paramete query yang benar (Uri.https auto-encode)
    // Bangun URI dengan benar supaya parameter di-encode otomatis
    final uri = Uri.https(apiHost, '/v1/forecast.json', {
      'key': apiKey,
      'q': loc,
      'days': '7', // Ambil prakiraan 7 hari (termasuk hari ini)
      'aqi': 'no', // Tidak perlu data kualitas udara
      'alerts': 'no', // Tidak perlu alert cuaca
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
      /// Handle API errors with proper exception types
      try {
        final bodyJson = jsonDecode(response.body);
        if (bodyJson is Map && bodyJson['error'] != null) {
          // Parse API error using LocationErrorHandler
          throw LocationErrorHandler.parseApiError(bodyJson as Map<String, dynamic>);
        } else {
          // Generic API error for non-JSON responses
          throw ApiException(
            'Gagal mengambil data cuaca. Status: ${response.statusCode}. Response: ${response.body}',
            code: response.statusCode.toString(),
          );
        }
      } catch (e) {
        // If it's already a LocationException, re-throw it
        if (e is LocationException) {
          rethrow;
        }
        
        // For network issues or JSON parsing errors
        debugPrint(
          'Weather API response (${response.statusCode}): ${response.body}',
        );
        
        throw NetworkException(
          'Gagal mengambil data cuaca. Status: ${response.statusCode}. Periksa koneksi internet Anda.',
          code: response.statusCode.toString(),
        );
      }
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
  /// Throws: LocationException jika lokasi kosong atau request gagal
  // Alternative: fetch using Dio + Retrofit-generated `ApiClient`.
  // Requires running `flutter pub run build_runner build` to generate `api_client.g.dart`.
  Future<WeatherModel> fetchWeatherWithRetrofit(String location) async {
    /// Validate and normalize input
    _validateLocationInput(location);
    
    /// Normalize input dengan menghilangkan whitespace
    final loc = location.trim();

    /// Buat instance Dio (HTTP client dengan fitur lebih)
    final dio = Dio();

    /// Buat instance ApiClient dengan Dio (auto-generated by Retrofit)
    final client = ApiClient(dio);

    try {
      /// Call getForecast endpoint dengan parameter yang diperlukan
      /// Retrofit otomatis build URL dan parse response
      final json = await client.getForecast(apiKey, loc, '7', 'no', 'no');

      /// Parse JSON response menjadi WeatherModel
      return WeatherModel.fromJson(json);
    } on DioException catch (e) {
      /// Handle Dio-specific errors
      debugPrint('Retrofit Dio error: $e');
      
      // Check if it's a location not found error
      if (e.response?.statusCode != null) {
        final statusCode = e.response!.statusCode!;
        if (statusCode == 400 || statusCode == 404) {
          // Check response data for location not found
          final responseData = e.response?.data;
          if (responseData is Map && responseData['error'] != null) {
            throw LocationErrorHandler.parseApiError(responseData as Map<String, dynamic>);
          }
          throw LocationNotFoundException(loc);
        }
      }
      
      // Network-related errors
      throw NetworkException(
        'Gagal mengambil data cuaca. Periksa koneksi internet Anda.',
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      /// Log error untuk debugging
      debugPrint('Retrofit error: $e');

      /// Re-throw error agar bisa di-handle oleh caller
      rethrow;
    }
  }
}
