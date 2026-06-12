import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/barang.dart';
import 'auth_service.dart';

class BarangService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Barang>> getAll({String search = ''}) async {
    final queryParams = <String, String>{};
    if (search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('${ApiConfig.apiUrl}/barang')
        .replace(queryParameters: queryParams);
    final response = await http
        .get(uri, headers: await _getHeaders())
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'] ?? [];
      return data.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat barang: ${response.statusCode}');
    }
  }

  Future<Barang> create({
    required String nama,
    required String gunaMerek,
    required int ukuran,
    required String ketebalan,
    required String bentuk,
    required String bahan,
    required int harga,
    required int jumlah,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/barang');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'nama': nama,
        'harga': {'harga': harga, 'jumlah': jumlah},
        'kategori': {
          'ukuran': ukuran,
          'ketebalan': ketebalan,
          'bentuk': bentuk,
          'bahan': bahan,
          'merek': gunaMerek,
        }
      }),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Barang.fromJson(json['data']);
    } else {
      final errorMsg = _parseError(response.body);
      throw Exception('Gagal menambah barang: $errorMsg');
    }
  }

  Future<Barang> update(int idBarang, {
    required String nama,
    required String gunaMerek,
    required int ukuran,
    required String ketebalan,
    required String bentuk,
    required String bahan,
    required int harga,
    required int jumlah,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/barang/$idBarang');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'nama': nama,
        'harga': {'harga': harga, 'jumlah': jumlah},
        'kategori': {
          'ukuran': ukuran,
          'ketebalan': ketebalan,
          'bentuk': bentuk,
          'bahan': bahan,
          'merek': gunaMerek,
        }
      }),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Barang.fromJson(json['data']);
    } else {
      final errorMsg = _parseError(response.body);
      throw Exception('Gagal mengubah barang: $errorMsg');
    }
  }

  Future<Barang> updateStok(int idBarang, int jumlahBaru) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/barang/$idBarang/stok');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({'jumlah': jumlahBaru}),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Barang.fromJson(json['data']);
    } else {
      final errorMsg = _parseError(response.body);
      throw Exception('Gagal update stok: $errorMsg');
    }
  }

  Future<Barang> catatPenjualan(int idBarang, int jumlahTerjual) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/barang/$idBarang/penjualan');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({'jumlah_terjual': jumlahTerjual}),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Barang.fromJson(json['data']);
    } else {
      final errorMsg = _parseError(response.body);
      throw Exception('Gagal catat penjualan: $errorMsg');
    }
  }

  Future<void> delete(int idBarang) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/barang/$idBarang');
    final response = await http
        .delete(uri, headers: await _getHeaders())
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final errorMsg = _parseError(response.body);
      throw Exception('Gagal menghapus barang: $errorMsg');
    }
  }

  String _parseError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? 'Kesalahan tidak diketahui';
    } catch (_) {
      return 'Response tidak valid';
    }
  }
}

