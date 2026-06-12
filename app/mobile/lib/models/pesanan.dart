class Pesanan {
  final String idPesanan;
  final String namaBarang;
  final String status; // 'Belum Selesai', 'Selesai'
  final DateTime tanggalDipesan;
  final DateTime? tanggalKirim; // Bisa estimasi atau aktual terkirim
  final String bahan;
  final String jumlah;
  final String bentuk;
  final String ukuran;
  final String ketebalan;
  final int totalHarga;
  final String catatan;

  Pesanan({
    required this.idPesanan,
    required this.namaBarang,
    required this.status,
    required this.tanggalDipesan,
    this.tanggalKirim,
    required this.bahan,
    required this.jumlah,
    required this.bentuk,
    required this.ukuran,
    required this.ketebalan,
    required this.totalHarga,
    required this.catatan,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    final tglTerkirim = json['tanggalterkirim'];
    return Pesanan(
      idPesanan: json['id_pesanan']?.toString() ?? '',
      namaBarang: json['nama_barang']?.toString() ?? '',
      status: tglTerkirim != null ? 'Selesai' : 'Belum Selesai',
      tanggalDipesan: json['tanggalpemesanan'] != null 
          ? DateTime.parse(json['tanggalpemesanan'].toString()) 
          : DateTime.now(),
      tanggalKirim: tglTerkirim != null 
          ? DateTime.parse(tglTerkirim.toString()) 
          : null,
      bahan: json['bahan']?.toString() ?? '',
      jumlah: json['jumlah']?.toString() ?? '',
      bentuk: json['bentuk']?.toString() ?? '',
      ukuran: json['ukuran']?.toString() ?? '',
      ketebalan: json['ketebalan']?.toString() ?? '',
      totalHarga: (json['harga'] as num?)?.toInt() ?? 0,
      catatan: json['catatan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pesanan': idPesanan,
        'nama_barang': namaBarang,
        'status': status,
        'tanggal_dipesan': tanggalDipesan.toIso8601String(),
        'tanggal_kirim': tanggalKirim?.toIso8601String(),
        'bahan': bahan,
        'jumlah': jumlah,
        'bentuk': bentuk,
        'ukuran': ukuran,
        'ketebalan': ketebalan,
        'total_harga': totalHarga,
        'catatan': catatan,
      };
}

