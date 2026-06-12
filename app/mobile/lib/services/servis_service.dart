import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/servis.dart';
import 'auth_service.dart';

class ServisService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Servis>> getServis() async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/servis');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => Servis.fromJson(item)).toList();
    } else {
      final msg = jsonDecode(response.body)['message'] ?? 'Gagal memuat servis';
      throw Exception(msg);
    }
  }

  Future<Servis> tambahServis(Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/servis');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return Servis.fromJson(jsonResponse['data']);
    } else {
      final msg = jsonDecode(response.body)['message'] ?? 'Gagal menambah servis';
      throw Exception(msg);
    }
  }

  Future<Servis> updateServis(String idPesanan, Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/servis/$idPesanan');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Servis.fromJson(jsonResponse['data']);
    } else {
      final msg = jsonDecode(response.body)['message'] ?? 'Gagal mengupdate servis';
      throw Exception(msg);
    }
  }

  Future<void> tandaiSelesai(String idPesanan) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/servis/$idPesanan');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({'selesai': true}),
    );

    if (response.statusCode != 200) {
      final msg = jsonDecode(response.body)['message'] ?? 'Gagal menandai servis selesai';
      throw Exception(msg);
    }
  }

  Future<void> hapusServis(String idPesanan) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}/servis/$idPesanan');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      final msg = jsonDecode(response.body)['message'] ?? 'Gagal menghapus servis';
      throw Exception(msg);
    }
  }
}

