/// -----------------------------------------------------------------------------
/// File: location_error.dart
/// -----------------------------------------------------------------------------
/// Custom exception types and error handling for location-related errors.
/// 
/// This file provides:
/// - Custom exception classes for different types of location errors
/// - Error types: LocationNotFound, NetworkError, APIError, InvalidInput
/// - Helper methods to get user-friendly messages and recovery suggestions
/// -----------------------------------------------------------------------------
library;

/// Base class for all location-related exceptions
abstract class LocationException implements Exception {
  final String message;
  final String? code;
  final List<String>? suggestions;

  const LocationException(
    this.message, {
    this.code,
    this.suggestions,
  });

  @override
  String toString() => message;
}

/// Exception thrown when a location cannot be found
class LocationNotFoundException extends LocationException {
  const LocationNotFoundException(
    String locationName, {
    List<String>? suggestions,
  }) : super(
          'Lokasi "$locationName" tidak ditemukan. Periksa kembali ejaan nama kota.',
          code: 'LOCATION_NOT_FOUND',
          suggestions: suggestions,
        );
}

/// Exception thrown for invalid input (empty location, malformed coordinates)
class InvalidLocationInputException extends LocationException {
  const InvalidLocationInputException(super.message)
      : super(
          code: 'INVALID_INPUT',
        );
}

/// Exception thrown when network request fails
class NetworkException extends LocationException {
  const NetworkException(super.message, {String? code})
      : super(code: code ?? 'NETWORK_ERROR');
}

/// Exception thrown when API returns an error response
class ApiException extends LocationException {
  const ApiException(super.message, {super.code, super.suggestions});
}

/// Utility class for handling location errors and providing user-friendly messages
class LocationErrorHandler {
  /// Check if an exception is specifically a location not found error
  static bool isLocationNotFound(dynamic error) {
    if (error is! LocationException) return false;
    
    // Check by code first
    if (error.code == 'LOCATION_NOT_FOUND') return true;
    
    // Check by message content (for legacy compatibility)
    final message = error.message.toLowerCase();
    return message.contains('no matching location') ||
           message.contains('location not found') ||
           message.contains('location does not exist') ||
           message.contains('not found');
  }

  /// Get user-friendly error title
  static String getErrorTitle(dynamic error) {
    if (error is LocationNotFoundException) {
      return 'Lokasi Tidak Ditemukan';
    } else if (error is NetworkException) {
      return 'Masalah Koneksi';
    } else if (error is InvalidLocationInputException) {
      return 'Input Tidak Valid';
    } else if (error is ApiException) {
      return 'Error API';
    } else {
      return 'Terjadi Kesalahan';
    }
  }

  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error is LocationException) {
      return error.message;
    }
    return error.toString();
  }

  /// Get recovery suggestions for the error
  static List<String> getRecoverySuggestions(dynamic error) {
    if (error is LocationNotFoundException) {
      return error.suggestions ?? _defaultLocationSuggestions();
    } else if (error is NetworkException) {
      return [
        'Periksa koneksi internet Anda',
        'Coba lagi dalam beberapa saat',
        'Pastikan GPS/lokasi aktif jika menggunakan GPS',
      ];
    } else if (error is InvalidLocationInputException) {
      return [
        'Pastikan nama kota sudah benar',
        'Coba gunakan nama kota yang lebih umum',
        'Gunakan format koordinat: "latitude,longitude"',
      ];
    } else {
      return [
        'Coba lagi',
        'Restart aplikasi',
        'Hubungi support jika masalah berlanjut',
      ];
    }
  }

  /// Default suggestions for location not found errors
  static List<String> _defaultLocationSuggestions() {
    return [
      'Periksa ejaan nama kota',
      'Coba nama kota yang lebih umum',
      'Gunakan nama kota dalam bahasa Indonesia',
      'Coba dengan nama provinsi atau daerah',
      'Gunakan koordinat GPS (format: latitude,longitude)',
    ];
  }

  /// Parse API error response and return appropriate exception
  static LocationException parseApiError(Map<String, dynamic> errorResponse) {
    final error = errorResponse['error'];
    if (error == null) {
      return const ApiException('Unknown API error');
    }

    final code = error['code']?.toString();
    final message = error['message'] ?? error['massage'] ?? error['msg'] ?? 'Unknown error';

    // Check for specific location not found errors
    if (code == '1006' || 
        message.toLowerCase().contains('no matching location') ||
        message.toLowerCase().contains('location not found')) {
      return LocationNotFoundException(message);
    }

    // Network-related errors
    if (code == '2008' || message.toLowerCase().contains('network')) {
      return NetworkException(message, code: code);
    }

    // Invalid request errors
    if (code == '2002' || code == '2003') {
      return InvalidLocationInputException(message);
    }

    return ApiException(message, code: code);
  }
}
