  /// File ini berisi definisi REST API client menggunakan Retrofit dan Dio.
  /// 
  /// Retrofit adalah library yang mengubah HTTP client menjadi type-safe interface.
  /// Keuntungan:
  /// - Deklaratif: method signature langsung define endpoint dan parameter
  /// - Type-safe: compiler catch error di compile time, bukan saat runtime
  /// - Auto-parsing: Dio + Retrofit auto-convert JSON response ke object
  /// 
  /// API yang di-define:
  /// - GET /forecast.json: Ambil prakiraan cuaca (4-14 hari)
  /// - GET /current.json: Ambil data cuaca saat ini
  /// 
  /// Catatan:
  /// - File ini sudah memiliki companion file api_client.g.dart (generated)
  /// - Jika edit file ini, jalankan: flutter pub run build_runner build
  import 'package:dio/dio.dart';
  import 'package:retrofit/retrofit.dart';

  part 'api_client.g.dart';

  /// Retrofit REST API client untuk WeatherAPI.com
  /// 
  /// Dengan dekorator @RestApi, kita define base URL dan Retrofit auto-generate
  /// implementasi class dengan nama _ApiClient yang bisa membuat HTTP request.
  /// 
  /// Contoh usage:
  /// ```dart
  /// final dio = Dio();
  /// final client = ApiClient(dio);
  /// final data = await client.getForecast('api_key', 'Jakarta', '1', 'no', 'no');
  /// ```
  @RestApi(baseUrl: "https://api.weatherapi.com/v1")
  abstract class ApiClient {
    /// Factory constructor untuk membuat instance ApiClient.
    /// Retrofit auto-generate implementasi dengan nama _ApiClient.
    factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

    /// Endpoint untuk mengambil prakiraan cuaca (forecast).
    /// 
    /// HTTP Method: GET
    /// Endpoint: /forecast.json
    /// 
    /// Parameter:
    /// - @Query('key'): API Key untuk authentication
    /// - @Query('q'): Location (nama kota atau "lat,lon")
    /// - @Query('days'): Berapa hari prakiraan (1-14 hari)
    /// - @Query('aqi'): Include air quality data? ('yes'/'no')
    /// - @Query('alerts'): Include weather alerts? ('yes'/'no')
    /// 
    /// Return: Map yang berisi JSON response dari API (bisa di-parse ke WeatherModel)
    @GET('/forecast.json')
    Future<Map<String, dynamic>> getForecast(
      /// Kunci API untuk mengakses WeatherAPI
      @Query('key') String key,
      /// Lokasi yang di-query (nama kota atau koordinat lat,lon)
      @Query('q') String q,
      /// Jumlah hari untuk prakiraan (1 hari, 3 hari, 7 hari, dst)
      @Query('days') String days,
      /// Apakah include data kualitas udara dalam response
      @Query('aqi') String aqi,
      /// Apakah include alert cuaca dalam response
      @Query('alerts') String alerts,
    );

    /// Endpoint untuk mengambil data cuaca saat ini (current weather).
    /// 
    /// HTTP Method: GET
    /// Endpoint: /current.json
    /// 
    /// Parameter:
    /// - @Query('key'): API Key untuk authentication
    /// - @Query('q'): Location (nama kota atau "lat,lon")
    /// 
    /// Return: Map yang berisi JSON response dengan data cuaca terkini
    @GET('/current.json')
    Future<Map<String, dynamic>> getCurrent(
      /// Kunci API untuk mengakses WeatherAPI
      @Query('key') String key,
      /// Lokasi yang di-query (nama kota atau koordinat lat,lon)
      @Query('q') String q,
    );
  }
