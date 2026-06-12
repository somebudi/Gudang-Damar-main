import 'package:web/web.dart' as web;

import 'auth_storage.dart';

/// Implementasi AuthStorage untuk web.
/// Pakai browser localStorage.
///
/// CATATAN: localStorage TIDAK terenkripsi & bisa dibaca dari DevTools.
/// Ini risiko inherent dari Flutter web — bukan tempat untuk simpan
/// secret yang sensitif di production publik. Untuk development lokal aman.
class AuthStorageImpl implements AuthStorage {
  @override
  Future<String?> read(String key) async {
    return web.window.localStorage.getItem(key);
  }

  @override
  Future<void> write(String key, String value) async {
    web.window.localStorage.setItem(key, value);
  }

  @override
  Future<void> delete(String key) async {
    web.window.localStorage.removeItem(key);
  }
}

AuthStorage createAuthStorage() => AuthStorageImpl();