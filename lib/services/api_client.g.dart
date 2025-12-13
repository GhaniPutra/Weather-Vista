  /// =========================================================================
  /// File: api_client.g.dart (Generated/Implemented File)
  /// =========================================================================
  /// 
  /// File ini berisi implementasi konkret dari abstract class `ApiClient`.
  /// 
  /// PENTING: File ini adalah AUTO-GENERATED oleh Retrofit + Build Runner!
  /// 
  /// Fungsi file ini:
  /// - Mengimplementasikan semua method abstract dari ApiClient
  /// - Membangun URL request dengan base URL dan endpoint
  /// - Menangani query parameters secara otomatis
  /// - Mengirim HTTP request menggunakan Dio
  /// - Parsing response dari API ke Map<String, dynamic>
  /// - Error handling untuk request yang gagal
  /// 
  /// Jangan dihapus atau diedit manual!
  /// - Jika dihapus, regenerate dengan: flutter pub run build_runner build
  /// - Jika diedit manual, perubahan akan ter-overwrite saat re-generate
  /// 
  /// Struktur file:
  /// - class _ApiClient: Implementasi dari ApiClient interface
  ///   - Constructor: Setup Dio dan base URL
  ///   - getForecast(): Implement endpoint /forecast.json
  ///   - getCurrent(): Implement endpoint /current.json

  part of 'api_client.dart';

  /// Implementasi konkret dari ApiClient abstract class.
  /// 
  /// Class ini di-instantiate melalui factory constructor di ApiClient:
  /// ```dart
  /// final dio = Dio();
  /// final client = ApiClient(dio);  // akan create instance _ApiClient
  /// ```
  /// 
  /// Responsibility:
  /// - Menyimpan reference ke Dio instance untuk membuat HTTP request
  /// - Menyimpan base URL dan provide getter untuk akses
  /// - Mengimplementasikan setiap endpoint sebagai async method
  /// - Menangani query parameters dan response parsing
  class _ApiClient implements ApiClient {
    /// Dio instance untuk membuat HTTP request (HTTP client library)
    final Dio _dio;
    /// Base URL untuk semua endpoint (bisa di-override saat instantiate)
    String? baseUrl;

    /// Constructor untuk _ApiClient.
    /// 
    /// Parameter:
    /// - _dio: Dio instance yang sudah dikonfigurasi
    /// - baseUrl: Optional, untuk override default base URL
    /// 
    /// Logic:
    /// - Simpan Dio instance
    /// - Jika baseUrl tidak diberikan, gunakan default: https://api.weatherapi.com/v1
    _ApiClient(this._dio, {this.baseUrl}) {
      /// Jika baseUrl null, gunakan default WeatherAPI base URL
      baseUrl ??= 'https://api.weatherapi.com/v1';
    }

    /// Implementasi endpoint GET /forecast.json - mengambil prakiraan cuaca.
    /// 
    /// HTTP Details:
    /// - Method: GET
    /// - Endpoint: /forecast.json
    /// - Base URL: https://api.weatherapi.com/v1
    /// - Full URL: https://api.weatherapi.com/v1/forecast.json?key=xxx&q=xxx&days=xxx&aqi=xxx&alerts=xxx
    /// 
    /// Parameter (sesuai dengan signature di ApiClient):
    /// - key: API Key untuk authentication ke WeatherAPI
    /// - q: Query lokasi (nama kota atau "lat,lon")
    /// - days: Jumlah hari prakiraan (1-14 hari)
    /// - aqi: Include air quality data ("yes"/"no")
    /// - alerts: Include weather alerts ("yes"/"no")
    /// 
    /// Process:
    /// 1. Build full URL: baseUrl + endpoint
    /// 2. Create query parameters dari semua parameter function
    /// 3. Send GET request via Dio dengan URL dan query parameters
    /// 4. Terima response dari API
    /// 5. Parse response.data menjadi Map<String, dynamic>
    /// 6. Return Map yang berisi JSON structure cuaca
    /// 
    /// Response structure akan di-parse ke WeatherModel di weather_service.dart
    /// 
    /// Throws: DioException jika request gagal (timeout, no internet, API error)
    @override
    Future<Map<String, dynamic>> getForecast(
      String key,
      String q,
      String days,
      String aqi,
      String alerts,
    ) async {
      /// Bangun full URL dengan base URL + endpoint
      final url = '${baseUrl!}/forecast.json';
      
      /// Send GET request via Dio dengan query parameters
      /// Dio otomatis akan:
      /// - Encode parameter sebagai URL query string
      /// - Append ke URL
      /// - Send HTTP GET request
      final response = await _dio.get(
        url,
        /// Query parameters akan di-append ke URL oleh Dio
        /// Contoh final URL: .../forecast.json?key=xxx&q=Jakarta&days=1&aqi=no&alerts=no
        queryParameters: {
          'key': key,
          'q': q,
          'days': days,
          'aqi': aqi,
          'alerts': alerts,
        },
      );

      /// Parse response.data menjadi Map<String, dynamic>
      /// response.data dari Dio adalah hasil parse JSON otomatis
      /// Cek tipe data terlebih dahulu
      if (response.data is Map<String, dynamic>) return response.data as Map<String, dynamic>;
      /// Fallback: convert Map ke Map<String, dynamic> jika tipe berbeda
      return Map<String, dynamic>.from(response.data as Map);
    }

    /// Implementasi endpoint GET /current.json - mengambil data cuaca saat ini.
    /// 
    /// HTTP Details:
    /// - Method: GET
    /// - Endpoint: /current.json
    /// - Base URL: https://api.weatherapi.com/v1
    /// - Full URL: https://api.weatherapi.com/v1/current.json?key=xxx&q=xxx
    /// 
    /// Parameter:
    /// - key: API Key untuk authentication ke WeatherAPI
    /// - q: Query lokasi (nama kota atau "lat,lon")
    /// 
    /// Process:
    /// 1. Build full URL: baseUrl + endpoint
    /// 2. Create query parameters (key dan q saja, lebih sederhana dari getForecast)
    /// 3. Send GET request via Dio
    /// 4. Terima response JSON dari API
    /// 5. Parse response.data menjadi Map<String, dynamic>
    /// 6. Return Map yang berisi data cuaca terkini
    /// 
    /// Difference dengan getForecast:
    /// - getForecast: lebih lengkap, include prakiraan, detail, astro, dll
    /// - getCurrent: hanya data saat ini, lebih ringan dan cepat
    /// 
    /// Throws: DioException jika request gagal
    @override
    Future<Map<String, dynamic>> getCurrent(
      String key,
      String q,
    ) async {
      /// Bangun full URL dengan base URL + endpoint
      final url = '${baseUrl!}/current.json';
      
      /// Send GET request via Dio dengan query parameters
      /// Untuk endpoint /current.json, hanya butuh 2 parameter (key dan q)
      final response = await _dio.get(
        url,
        /// Query parameters akan di-append ke URL oleh Dio
        /// Contoh final URL: .../current.json?key=xxx&q=Jakarta
        queryParameters: {
          'key': key,
          'q': q,
        },
      );

      /// Parse response.data menjadi Map<String, dynamic>
      /// Cek tipe data terlebih dahulu untuk type safety
      if (response.data is Map<String, dynamic>) return response.data as Map<String, dynamic>;
      /// Fallback: convert Map ke Map<String, dynamic> jika tipe berbeda
      return Map<String, dynamic>.from(response.data as Map);
    }
  }
