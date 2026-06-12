import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';
import 'storage/auth_storage.dart';
import 'storage/auth_storage_stub.dart'
    if (dart.library.io) 'storage/auth_storage_mobile.dart'
    if (dart.library.js_interop) 'storage/auth_storage_web.dart';

/// Service untuk semua interaksi auth dengan Laravel backend.
/// Akses via `AuthService.instance`.
///
/// Storage backend dipilih otomatis berdasarkan platform:
///   - Mobile (dart.library.io)         → flutter_secure_storage
///   - Web    (dart.library.js_interop) → localStorage
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';
  static const _userKey  = 'auth_user';

  late final AuthStorage _storage = createAuthStorage();

  // Cache di memory biar nggak baca storage tiap request
  String? _cachedToken;
  Map<String, dynamic>? _cachedUser;

  // ─────────────────────────────────────────────────────────
  // Google Sign-In setup
  // ─────────────────────────────────────────────────────────

  /// Web Client ID dari Google Cloud Console → dipakai sebagai serverClientId
  /// agar library bisa meminta idToken yang bisa diverifikasi oleh server Laravel.
  /// PENTING: Ini bukan Android Client ID, melainkan Web Client ID.
  static const _webClientId =
      '1085258754908-fr0no50qlbk5dnujrs4isfn41s05bp6b.apps.googleusercontent.com';

  late final _googleSignIn = GoogleSignIn(
    // serverClientId diperlukan agar auth.idToken tidak null saat dikirim ke backend.
    // Di Android, clientId tidak dipakai — identitas app ditentukan dari SHA-1 keystore.
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  // ─────────────────────────────────────────────────────────
  // Token & User storage
  // ─────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    _cachedToken ??= await _storage.read(_tokenKey);
    return _cachedToken;
  }

  Future<Map<String, dynamic>?> getUser() async {
    if (_cachedUser != null) return _cachedUser;
    final raw = await _storage.read(_userKey);
    if (raw == null) return null;
    _cachedUser = jsonDecode(raw) as Map<String, dynamic>;
    return _cachedUser;
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> _saveAuth(String token, Map<String, dynamic> user) async {
    _cachedToken = token;
    _cachedUser  = user;
    await _storage.write(_tokenKey, token);
    await _storage.write(_userKey,  jsonEncode(user));
  }

  Future<void> _clearAuth() async {
    _cachedToken = null;
    _cachedUser  = null;
    await _storage.delete(_tokenKey);
    await _storage.delete(_userKey);
  }

  // ─────────────────────────────────────────────────────────
  // API calls
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final body = await _post(ApiConfig.register, {
      'name'                  : name,
      'email'                 : email,
      'password'              : password,
      'password_confirmation' : passwordConfirmation,
      'device_name'           : 'flutter-mobile',
    });

    await _saveAuth(body['token'] as String, body['user'] as Map<String, dynamic>);
    return body;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final body = await _post(ApiConfig.login, {
      'email'       : email,
      'password'    : password,
      'device_name' : 'flutter-mobile',
    });

    await _saveAuth(body['token'] as String, body['user'] as Map<String, dynamic>);
    return body;
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _post(ApiConfig.logout, {}, authToken: token);
      } catch (_) {
        // ignore — yang penting local cleared
      }
    }
    await _clearAuth();
    await signOutGoogle();
  }

  // ─────────────────────────────────────────────────────────
  // Google Login
  // ─────────────────────────────────────────────────────────

  /// Sign in dengan Google → kirim idToken ke Laravel → dapat Sanctum token.
  /// Di web (preview Edge) diblokir karena butuh Web Client ID terpisah.
  Future<Map<String, dynamic>> loginWithGoogle({
    String deviceName = 'mobile-google',
  }) async {
    if (kIsWeb) {
      throw ApiException(
        message: 'Google Sign-In hanya tersedia di mobile',
      );
    }

    try {
      // 1. Minta user pilih akun Google (native popup)
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw ApiException(message: 'Login Google dibatalkan');
      }

      // 2. Ambil idToken
      final auth    = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw ApiException(
          message: 'Gagal mendapat idToken dari Google. '
              'Pastikan SHA-1 debug keystore sudah didaftarkan di Google Cloud Console '
              'dan serverClientId adalah Web Client ID yang benar.',
        );
      }

      // 3. Kirim idToken ke Laravel
      final body = await _post(
        '${ApiConfig.apiUrl}/auth/google',
        {
          'id_token'    : idToken,
          'device_name' : deviceName,
        },
      );

      // Inject googleUser photoUrl if not provided by backend
      final userMap = body['user'] as Map<String, dynamic>;
      if (userMap['profile_photo_url'] == null && googleUser.photoUrl != null) {
        userMap['profile_photo_url'] = googleUser.photoUrl;
      }

      // 4. Simpan token & user
      await _saveAuth(body['token'] as String, userMap);
      
      // Update body with injected user
      body['user'] = userMap;
      return body;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(message: 'Tidak bisa terhubung ke server');
    } on PlatformException catch (e) {
      throw ApiException(message: 'Google Sign-In Platform Error: ${e.message}');
    } catch (e) {
      // Tangkap PlatformException dari plugin Google Sign-In (misal: sign_in_failed)
      final msg = e.toString();
      if (msg.contains('sign_in_failed') || msg.contains('ApiException')) {
        throw ApiException(
          message: 'Google Sign-In gagal. '
              'Pastikan SHA-1 debug keystore (7F:2B:47:1B:59:CF:FD:C0:34:1F:D3:FD:02:6D:38:15:D9:9D:01:40) '
              'sudah didaftarkan di Google Cloud Console untuk package com.gudangdamar.app.',
        );
      }
      throw ApiException(message: 'Google Sign-In error: $e');
    }
  }

  /// Sign out dari Google juga saat logout.
  Future<void> signOutGoogle() async {
    if (kIsWeb) return;
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // HTTP helper
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> data, {
    String? authToken,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: {
              'Accept'       : 'application/json',
              'Content-Type' : 'application/json',
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(data),
          )
          .timeout(ApiConfig.timeout);

      return _parseResponse(res);
    } on SocketException {
      throw ApiException(
        message: 'Tidak bisa terhubung ke server. Cek koneksi atau base URL.',
      );
    } on TimeoutException {
      throw ApiException(message: 'Server tidak merespon (timeout).');
    } on FormatException {
      throw ApiException(message: 'Response server tidak valid.');
    } catch (e) {
      throw ApiException(message: 'Error: $e');
    }
  }

  Map<String, dynamic> _parseResponse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    if (res.statusCode == 422) {
      final errors = (body['errors'] as Map<String, dynamic>?) ?? {};
      final mapped = errors.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      );
      throw ApiException(
        message: body['message'] as String? ?? 'Data tidak valid',
        statusCode: 422,
        validationErrors: mapped,
      );
    }

    throw ApiException(
      message: body['message'] as String? ?? 'Terjadi kesalahan',
      statusCode: res.statusCode,
    );
  }
}