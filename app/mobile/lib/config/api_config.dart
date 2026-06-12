import 'package:flutter/foundation.dart' show kIsWeb;

/// Konfigurasi Mobile API endpoint.
///
/// Base URL bisa di-override saat run/build pakai:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000
///
/// Default-nya dipilih otomatis:
///   - Web                   → http://localhost:8000  (browser di mesin yang sama)
///   - Android Emulator      → http://10.0.2.2:8000   (alias host dari emulator)
///   - iOS Simulator/Desktop → http://localhost:8000
///   - HP fisik via WiFi     → harus override pakai --dart-define
class ApiConfig {
  static const String _override = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  }

  /// Prefix mobile API sesuai konfigurasi di bootstrap/app.php Laravel.
  static String get apiUrl => '$baseUrl/mobile-api';

  // Endpoints
  static String get register => '$apiUrl/register';
  static String get login    => '$apiUrl/login';
  static String get logout   => '$apiUrl/logout';
  static String get me       => '$apiUrl/me';

  static const Duration timeout = Duration(seconds: 30);
}