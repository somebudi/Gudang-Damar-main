// lib/services/aktivitas_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class AktivitasService {
  static final AktivitasService instance = AktivitasService._init();
  AktivitasService._init();

  /// Mengambil data riwayat aktivitas dan statistik dari backend
  Future<Map<String, dynamic>?> getRiwayatAktivitas({
    String? search,
    String? jenis,
    String? status,
    int page = 1,
  }) async {
    // Ambil token yang tersimpan di device lewat AuthService
    final token = await AuthService.instance.getToken();
    if (token == null) return null;

    // Susun Query Parameters sesuai kebutuhan filter di Laravel
    final Map<String, String> queryParams = {
      'page': page.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (jenis != null && jenis != 'all') queryParams['jenis'] = jenis.toLowerCase();
    if (status != null && status != 'all') queryParams['status'] = status;

    // Buat URI dengan query parameters
    final uri = Uri.parse('${ApiConfig.apiUrl}/riwayat')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('Gagal memuat data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error koneksi ApiService: $e');
      return null;
    }
  }

  /// Mengekspor riwayat aktivitas menjadi string CSV
  Future<String?> exportRiwayatAktivitas({
    String? search,
    String? jenis,
    String? status,
  }) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return null;

    final Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (jenis != null && jenis != 'all') queryParams['jenis'] = jenis.toLowerCase();
    if (status != null && status != 'all') queryParams['status'] = status;

    final uri = Uri.parse('${ApiConfig.apiUrl}/riwayat/export')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return response.body; 
      } else {
        debugPrint('Gagal export data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error koneksi export: $e');
      return null;
    }
  }
}
