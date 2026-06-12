import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_storage.dart';

/// Implementasi AuthStorage untuk mobile (Android/iOS).
/// Pakai EncryptedSharedPreferences (Android) atau Keychain (iOS).
class AuthStorageImpl implements AuthStorage {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

AuthStorage createAuthStorage() => AuthStorageImpl();