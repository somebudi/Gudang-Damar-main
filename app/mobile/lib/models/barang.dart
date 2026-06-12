class Barang {
  final int idBarang;
  String nama;
  String gunaMerek;
  int ukuran;
  String ketebalan;
  String bentuk;
  String bahan;
  int harga;
  int jumlah;
  int total;
  int pendapatan;
  int jumlahTerjual;

  Barang({
    required this.idBarang,
    required this.nama,
    required this.gunaMerek,
    required this.ukuran,
    required this.ketebalan,
    required this.bentuk,
    required this.bahan,
    required this.harga,
    required this.jumlah,
    required this.total,
    this.pendapatan = 0,
    this.jumlahTerjual = 0,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      idBarang: json['id_barang'] as int,
      nama: json['nama'] as String,
      gunaMerek: json['guna_merek'] as String? ?? '',
      ukuran: json['ukuran'] as int? ?? 0,
      ketebalan: json['ketebalan'] as String? ?? '',
      bentuk: json['bentuk'] as String? ?? '',
      bahan: json['bahan'] as String? ?? '',
      harga: json['harga'] as int? ?? 0,
      jumlah: json['jumlah'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      pendapatan: json['pendapatan'] as int? ?? 0,
      jumlahTerjual: json['jumlah_terjual'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_barang': idBarang,
        'nama': nama,
        'guna_merek': gunaMerek,
        'ukuran': ukuran,
        'ketebalan': ketebalan,
        'bentuk': bentuk,
        'bahan': bahan,
        'harga': harga,
        'jumlah': jumlah,
        'total': total,
        'pendapatan': pendapatan,
        'jumlah_terjual': jumlahTerjual,
      };

  Barang copyWith({
    String? nama,
    String? gunaMerek,
    int? ukuran,
    String? ketebalan,
    String? bentuk,
    String? bahan,
    int? harga,
    int? jumlah,
    int? total,
    int? pendapatan,
    int? jumlahTerjual,
  }) {
    return Barang(
      idBarang: idBarang,
      nama: nama ?? this.nama,
      gunaMerek: gunaMerek ?? this.gunaMerek,
      ukuran: ukuran ?? this.ukuran,
      ketebalan: ketebalan ?? this.ketebalan,
      bentuk: bentuk ?? this.bentuk,
      bahan: bahan ?? this.bahan,
      harga: harga ?? this.harga,
      jumlah: jumlah ?? this.jumlah,
      total: total ?? this.total,
      pendapatan: pendapatan ?? this.pendapatan,
      jumlahTerjual: jumlahTerjual ?? this.jumlahTerjual,
    );
  }
}

class AktivitasBarang {
  final int idAktivitas;
  final int idBarang;
  final String namaBarang;
  final String jenis; // 'jual' | 'ubah_stok'
  final int jumlah;
  final int stokSebelum;
  final int stokSesudah;
  final int hargaSatuan;
  final int pendapatan;
  final String catatan;
  final DateTime tanggal;

  AktivitasBarang({
    required this.idAktivitas,
    required this.idBarang,
    required this.namaBarang,
    required this.jenis,
    required this.jumlah,
    required this.stokSebelum,
    required this.stokSesudah,
    required this.hargaSatuan,
    required this.pendapatan,
    required this.catatan,
    required this.tanggal,
  });

  factory AktivitasBarang.fromJson(Map<String, dynamic> json) {
    return AktivitasBarang(
      idAktivitas: json['id_aktivitas'] as int,
      idBarang: json['id_barang'] as int,
      namaBarang: json['nama_barang'] as String? ?? '',
      jenis: json['jenis'] as String? ?? '',
      jumlah: json['jumlah'] as int? ?? 0,
      stokSebelum: json['stok_sebelum'] as int? ?? 0,
      stokSesudah: json['stok_sesudah'] as int? ?? 0,
      hargaSatuan: json['harga_satuan'] as int? ?? 0,
      pendapatan: json['pendapatan'] as int? ?? 0,
      catatan: json['catatan'] as String? ?? '',
      tanggal: DateTime.parse(json['tanggal'] as String),
    );
  }
}

