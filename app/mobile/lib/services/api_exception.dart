/// Exception terstruktur untuk error dari Mobile API.
/// Memudahkan UI nampilin pesan error sesuai jenis kesalahan.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Laravel-style validation errors:
  /// { "email": ["Email sudah digunakan"], "password": ["..."] }
  final Map<String, List<String>>? validationErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.validationErrors,
  });

  /// Helper buat ambil error pertama dari field tertentu.
  String? firstErrorFor(String field) {
    final errs = validationErrors?[field];
    if (errs == null || errs.isEmpty) return null;
    return errs.first;
  }

  /// Kategori error
  bool get isUnauthorized => statusCode == 401;
  bool get isValidation   => statusCode == 422;
  bool get isNetwork      => statusCode == null;

  @override
  String toString() => 'ApiException($statusCode): $message';
}