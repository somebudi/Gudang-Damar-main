import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class AiImageService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generate gambar produk via backend Laravel (Pollinations.ai — gratis, no API key)
  /// Returns Uint8List bytes gambar jika berhasil, null jika gagal
  static Future<Uint8List?> generateProductImage({
    required String namaBarang,
    required String bahan,
    String bentuk = '',
    String ukuran = '',
    String ketebalan = '',
    String catatan = '',
  }) async {
    final prompt = _buildPrompt(
      namaBarang: namaBarang,
      bahan: bahan,
      bentuk: bentuk,
      ukuran: ukuran,
      ketebalan: ketebalan,
      catatan: catatan,
    );

    try {
      final uri = Uri.parse('${ApiConfig.apiUrl}/generate-image');
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['base64'] != null) {
          return base64Decode(json['base64'] as String);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _buildPrompt({
    required String namaBarang,
    required String bahan,
    String bentuk = '',
    String ukuran = '',
    String ketebalan = '',
    String catatan = '',
  }) {
    final desc = <String>[];
    if (bahan.isNotEmpty) desc.add(bahan);
    if (bentuk.isNotEmpty) desc.add('$bentuk shape');
    if (ukuran.isNotEmpty) desc.add('$ukuran cm');
    if (ketebalan.isNotEmpty) desc.add('$ketebalan mm thick');
    if (catatan.isNotEmpty) desc.add(catatan);

    final descStr = desc.isNotEmpty ? ', ${desc.join(', ')}' : '';
    return '$namaBarang$descStr';
  }
}

