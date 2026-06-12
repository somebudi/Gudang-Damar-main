import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pesanan.dart';
import 'auth_service.dart';

class PesananService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Pesanan>> getPesanan() async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/pesanan');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => Pesanan.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat pesanan');
    }
  }

  Future<Pesanan> tambahPesanan(Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/pesanan');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return Pesanan.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Gagal menambah pesanan');
    }
  }

  Future<Pesanan> updatePesanan(String idPesanan, Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/pesanan/$idPesanan');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Pesanan.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Gagal mengupdate pesanan');
    }
  }

  Future<void> tandaiSelesai(String idPesanan) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/pesanan/$idPesanan');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({'selesai': true}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai pesanan selesai');
    }
  }

  Future<void> hapusPesanan(String idPesanan) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/pesanan/$idPesanan');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pesanan');
    }
  }
}

