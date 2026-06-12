class Servis {
  final int idPesanan;
  final String namaBarang;
  final String bahan;
  final int jumlah;
  final String bentukBarang;
  final int harga;
  final int pendapatan;
  final String catatan;
  final DateTime tanggalPemesanan;
  final DateTime? tanggalTerkirim;

  Servis({
    required this.idPesanan,
    required this.namaBarang,
    required this.bahan,
    required this.jumlah,
    required this.bentukBarang,
    required this.harga,
    required this.pendapatan,
    required this.catatan,
    required this.tanggalPemesanan,
    this.tanggalTerkirim,
  });

  factory Servis.fromJson(Map<String, dynamic> json) {
    return Servis(
      idPesanan: json['id_pesanan'],
      namaBarang: json['nama_barang']?.toString() ?? '',
      bahan: json['bahan']?.toString() ?? '',
      jumlah: json['jumlah'] != null ? int.tryParse(json['jumlah'].toString()) ?? 1 : 1,
      bentukBarang: json['bentuk_barang']?.toString() ?? '',
      harga: json['harga'] != null ? int.tryParse(json['harga'].toString()) ?? 0 : 0,
      pendapatan: json['pendapatan'] != null ? int.tryParse(json['pendapatan'].toString()) ?? 0 : 0,
      catatan: json['catatan']?.toString() ?? '',
      tanggalPemesanan: DateTime.parse(json['tanggalpemesanan']),
      tanggalTerkirim: (json['tanggalterkirim'] != null && json['tanggalterkirim'] != '1970-01-01T00:00:00.000000Z' && json['tanggalterkirim'] != '0000-00-00 00:00:00')
          ? DateTime.parse(json['tanggalterkirim'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pesanan': idPesanan,
      'nama_barang': namaBarang,
      'bahan': bahan,
      'jumlah': jumlah,
      'bentuk_barang': bentukBarang,
      'harga': harga,
      'pendapatan': pendapatan,
      'catatan': catatan,
      'tanggalpemesanan': tanggalPemesanan.toIso8601String(),
      'tanggalterkirim': tanggalTerkirim?.toIso8601String(),
    };
  }

  // Copy with method useful for local updates
  Servis copyWith({
    int? idPesanan,
    String? namaBarang,
    String? bahan,
    int? jumlah,
    String? bentukBarang,
    int? harga,
    int? pendapatan,
    String? catatan,
    DateTime? tanggalPemesanan,
    DateTime? tanggalTerkirim,
  }) {
    return Servis(
      idPesanan: idPesanan ?? this.idPesanan,
      namaBarang: namaBarang ?? this.namaBarang,
      bahan: bahan ?? this.bahan,
      jumlah: jumlah ?? this.jumlah,
      bentukBarang: bentukBarang ?? this.bentukBarang,
      harga: harga ?? this.harga,
      pendapatan: pendapatan ?? this.pendapatan,
      catatan: catatan ?? this.catatan,
      tanggalPemesanan: tanggalPemesanan ?? this.tanggalPemesanan,
      tanggalTerkirim: tanggalTerkirim ?? this.tanggalTerkirim,
    );
  }
}

