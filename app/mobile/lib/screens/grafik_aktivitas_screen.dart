import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/aktivitas_service.dart';
import '../widgets/user_profile_avatar_button.dart';
import 'barang/barang_list_screen.dart';
import 'pesanan/pesanan_list_screen.dart';
import 'servis/servis_list_screen.dart';
import 'riwayat_aktivitas_screen.dart';

class GrafikAktivitasScreen extends StatefulWidget {
  const GrafikAktivitasScreen({super.key});

  @override
  State<GrafikAktivitasScreen> createState() => _GrafikAktivitasScreenState();
}

class _GrafikAktivitasScreenState extends State<GrafikAktivitasScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String _selectedPeriode = 'Bulan Ini';

  @override
  void initState() {
    super.initState();
    _fetchGrafikData();
  }

  Future<void> _fetchGrafikData() async {
    setState(() => _isLoading = true);
    // Memanggil API yang sama atau API khusus statistik dari AktivitasService
    final response = await AktivitasService.instance.getRiwayatAktivitas(page: 1);
    if (response != null && mounted) {
      setState(() {
        _stats = response['stats'] ?? {};
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dinamis dari API atau gunakan fallback data mockup jika kosong
    final int totalPesanan = _stats['total_pesanan'] ?? 18;
    final int totalServis = _stats['total_servis'] ?? 5;
    final int totalBarang = _stats['total_stok_barang'] ?? 38;
    final int totalTransaksi = totalPesanan + totalServis + totalBarang;

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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          const UserProfileAvatarButton(fallbackIconColor: Colors.white, radius: 14),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchGrafikData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Breadcrumb & Header ---
                    Row(
                      children: [
                        Text('PENYIMPANAN', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        const Text('GRAFIK ANALISIS', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Visualisasi & Grafik',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        // Dropdown Filter Periode
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPeriode,
                              items: ['Hari Ini', 'Bulan Ini', 'Tahun Ini'].map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() => _selectedPeriode = newValue!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- 1. BAR CHART: Tren Aktivitas Mingguan/Bulanan ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tren Volume Aktivitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text('Jumlah komparasi transaksi masuk per kategori', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 40,
                                barTouchData: BarTouchData(enabled: true),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        switch (value.toInt()) {
                                          case 0: return const Text('Pesanan', style: TextStyle(fontSize: 11));
                                          case 1: return const Text('Barang', style: TextStyle(fontSize: 11));
                                          case 2: return const Text('Servis', style: TextStyle(fontSize: 11));
                                          default: return const Text('');
                                        }
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalPesanan.toDouble(), color: const Color(0xFF0284C7), width: 22, borderRadius: BorderRadius.circular(4))]),
                                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalBarang.toDouble(), color: const Color(0xFFD97706), width: 22, borderRadius: BorderRadius.circular(4))]),
                                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: totalServis.toDouble(), color: const Color(0xFF7C3AED), width: 22, borderRadius: BorderRadius.circular(4))]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 2. PIE CHART: Distribusi Persentase ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Persentase Distribusi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 140,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 35,
                                      sections: [
                                        PieChartSectionData(color: const Color(0xFF0284C7), value: totalPesanan.toDouble(), title: '${((totalPesanan/totalTransaksi)*100).toStringAsFixed(0)}%', radius: 25, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                        PieChartSectionData(color: const Color(0xFFD97706), value: totalBarang.toDouble(), title: '${((totalBarang/totalTransaksi)*100).toStringAsFixed(0)}%', radius: 25, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                        PieChartSectionData(color: const Color(0xFF7C3AED), value: totalServis.toDouble(), title: '${((totalServis/totalTransaksi)*100).toStringAsFixed(0)}%', radius: 25, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Legend Indikator Warna
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLegendRow('Pesanan', const Color(0xFF0284C7), '$totalPesanan Unit'),
                                    const SizedBox(height: 8),
                                    _buildLegendRow('Barang', const Color(0xFFD97706), '$totalBarang Unit'),
                                    const SizedBox(height: 8),
                                    _buildLegendRow('Servis', const Color(0xFF7C3AED), '$totalServis Unit'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: const Color(0xFF64748B),
        currentIndex: 3, // Tetap aktif di menu Activity / Grafik
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BarangListScreen()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ServisListScreen()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PesananListScreen()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RiwayatAktivitasScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'Service'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart_rounded), label: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, Color color, String value) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
      ],
    );
  }
}