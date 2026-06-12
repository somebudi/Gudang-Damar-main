import 'auth_storage.dart';

/// Stub fallback yang tidak pernah benar-benar dipakai.
/// Conditional import butuh ini sebagai default.
AuthStorage createAuthStorage() {
  throw UnsupportedError('Platform tidak didukung');
}