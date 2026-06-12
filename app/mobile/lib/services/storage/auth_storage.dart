/// Interface untuk penyimpanan token & user data.
/// Implementasi berbeda dipilih otomatis berdasarkan platform:
///   - Web    → localStorage (lihat auth_storage_web.dart)
///   - Mobile → flutter_secure_storage (lihat auth_storage_mobile.dart)
abstract class AuthStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}