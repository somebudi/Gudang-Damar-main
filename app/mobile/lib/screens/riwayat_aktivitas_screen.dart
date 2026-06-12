// lib/screens/riwayat_aktivitas_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import '../theme/app_theme.dart';
import '../services/aktivitas_service.dart';
import '../widgets/user_profile_avatar_button.dart';
import 'barang/barang_list_screen.dart';
import 'pesanan/pesanan_list_screen.dart';
import 'servis/servis_list_screen.dart';

class RiwayatAktivitasScreen extends StatefulWidget {
  const RiwayatAktivitasScreen({super.key});

  @override
  State<RiwayatAktivitasScreen> createState() => _RiwayatAktivitasScreenState();
}

class _RiwayatAktivitasScreenState extends State<RiwayatAktivitasScreen> {
  // State variables untuk menyimpan data dari API
  List<dynamic> _transactions = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isExporting = false; // State untuk tombol export

  // State variables untuk filter & pagination
  String _searchQuery = '';
  String _selectedJenis = 'all';
  String _selectedStatus = 'all';
  int _currentPage = 1;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Fungsi mengambil data riwayat aktivitas dari backend Laravel
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final response = await AktivitasService.instance.getRiwayatAktivitas(
      search: _searchQuery,
      jenis: _selectedJenis,
      status: _selectedStatus,
      page: _currentPage,
    );
    if (response != null && mounted) {
      setState(() {
        _transactions = response['transactions']['data'] ?? [];
        _currentPage = response['transactions']['current_page'] ?? 1;
        _stats = response['stats'] ?? {};
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Fungsi untuk menghandle Export Data menggunakan File Saver (Cross-platform)
  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    
    try {
      final csvData = await AktivitasService.instance.exportRiwayatAktivitas(
        search: _searchQuery,
        jenis: _selectedJenis,
        status: _selectedStatus,
      );

      if (!mounted) return;

      if (csvData != null) {
        final bytes = Uint8List.fromList(csvData.codeUnits);
        final fileName = 'GudangDamar_Export_${DateTime.now().millisecondsSinceEpoch}';

        await FileSaver.instance.saveFile(
          name: '$fileName.csv',
          bytes: bytes,
          mimeType: MimeType.csv,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil diexport! File tersimpan.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal melakukan export data dari server.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // --- Helper Warna & Ikon Sesuai Jenis ---
  Color _getJenisColor(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'pesanan': return const Color(0xFF0284C7); 
      case 'barang': return const Color(0xFFD97706);  
      case 'servis': return const Color(0xFF7C3AED);  
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return const Color(0xFF16A34A); 
    if (s == 'stok masuk' || s == 'dibeli') return const Color(0xFF475569); 
    return const Color(0xFFD97706);
  }

  Color _getStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return const Color(0xFFDCFCE7); 
    if (s == 'stok masuk' || s == 'dibeli') return const Color(0xFFE2E8F0); 
    return const Color(0xFFFEF3C7);
  }

  IconData _getJenisIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'pesanan': return Icons.shopping_bag_outlined;
      case 'barang': return Icons.restaurant_outlined;
      case 'servis': return Icons.build_outlined;
      default: return Icons.assignment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/LogoDamar.jpeg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gudang Damar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          const UserProfileAvatarButton(
            fallbackIconColor: Colors.white,
            radius: 14,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Bagian Header Judul & Breadcrumb ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PENYIMPANAN',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        const Text(
                          'RIWAYAT AKTIVITAS',
                          style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Riwayat Aktivitas',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gabungan riwayat Pesanan, Barang, dan Servis.',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),

              // --- Tombol Export Data ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Icon(Icons.vertical_align_bottom, size: 16, color: Colors.white),
                  label: Text(
                    _isExporting ? 'Mengekspor...' : 'Export Data', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006C35),
                    disabledBackgroundColor: Colors.grey,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Horizontal Scroll Summary Cards ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Summary Cards Horizontal Scroll',
                      style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16, right: 8, bottom: 4),
                    child: Row(
                      children: [
                        SummaryCard(
                          icon: Icons.adf_scanner_outlined,
                          title: 'TOTAL TRANSAKSI',
                          value: '${_stats['total_transaksi'] ?? 88}',
                          subtitle: 'Pesanan: ${_stats['total_pesanan'] ?? 18} | Servis: ${_stats['total_servis'] ?? 5}',
                        ),
                        SummaryCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'TOTAL BARANG',
                          value: '${_stats['total_stok_barang'] ?? 38}',
                          subtitle: 'Unit Terdaftar',
                        ),
                        SummaryCard(
                          icon: Icons.payments_outlined,
                          title: 'TOTAL PENDAPATAN',
                          value: 'Rp 1.8B',
                          subtitle: 'Bulan berjalan',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // --- Search Bar & Filter Dropdown ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onSubmitted: (v) {
                        setState(() { _searchQuery = v; _currentPage = 1; });
                        _fetchData();
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama barang...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildDropdown(
                            _selectedJenis,
                            (v) { setState(() { _selectedJenis = v!; _currentPage = 1; }); _fetchData(); },
                            ['all', 'pesanan', 'barang', 'servis'],
                            'Jenis',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 4,
                          child: _buildDropdown(
                            _selectedStatus,
                            (v) { setState(() { _selectedStatus = v!; _currentPage = 1; }); _fetchData(); },
                            ['all', 'Selesai', 'Stok Masuk'],
                            'Status',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune, color: Color(0xFF2563EB), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Bagian List Aktivitas Dinamis ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
                    : _transactions.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Tidak ada riwayat aktivitas ditemukan.')))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _transactions.length,
                            itemBuilder: (ctx, i) {
                              final item = _transactions[i];
                              final String jenis = item['jenis'] ?? 'Barang';
                              final bool isAdjustment = item['sub_jenis'] == 'Stok';
                              final String displayStatus = isAdjustment ? 'STOK MASUK' : (item['status'] ?? 'SELESAI').toString().toUpperCase();

                              return AktivitasCard(
                                type: jenis.toUpperCase(),
                                title: item['nama_barang'] ?? '-',
                                subtitle: isAdjustment
                                    ? '${item['jumlah'] ?? 0} Unit • ${item['catatan'] ?? 'Stok diubah'}'
                                    : '${item['jumlah'] ?? 0} Unit • ${item['catatan'] ?? 'kuat'}',
                                date: item['tanggal_transaksi'] != null
                                    ? item['tanggal_transaksi'].toString().substring(0, 10)
                                    : '26 Apr 2026',
                                price: isAdjustment ? 'Penyesuaian Stok' : 'Rp ${item['total_harga'] ?? item['harga_satuan'] ?? '0'}',
                                status: displayStatus,
                                typeColor: _getJenisColor(jenis),
                                statusColor: _getStatusColor(displayStatus),
                                statusBgColor: _getStatusBgColor(displayStatus),
                                icon: _getJenisIcon(jenis),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 24),

              // --- Footer Copyright ---
              const Center(
                child: Text(
                  '© 2025 GudangDamar. All rights reserved.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        currentIndex: 3, 
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BarangListScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ServisListScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PesananListScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'Service'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: 'Activity'),
        ],
      ),
    );
  }

  /// Builder Dropdown Custom yang Responsif
  Widget _buildDropdown(String value, ValueChanged<String?> onChanged, List<String> items, String label) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, size: 16, color: Color(0xFF64748B)),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              e == 'all' ? 'Semua' : e,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS LAYOUT ---

class SummaryCard extends StatelessWidget {
  final IconData icon; final String title; final String value; final String subtitle;
  const SummaryCard({super.key, required this.icon, required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 16, color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class AktivitasCard extends StatelessWidget {
  final String type; final String title; final String subtitle; final String date; final String price; final String status; final Color typeColor; final Color statusColor; final Color statusBgColor; final IconData icon;
  const AktivitasCard({super.key, required this.type, required this.title, required this.subtitle, required this.date, required this.price, required this.status, required this.typeColor, required this.statusColor, required this.statusBgColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(type, style: TextStyle(fontSize: 9, color: typeColor, fontWeight: FontWeight.bold)),
              ),
              Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL HARGA', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
