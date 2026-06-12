import 'package:flutter/material.dart';
import '../../models/pesanan.dart';
import '../../services/pesanan_service.dart';
import '../../widgets/user_profile_avatar_button.dart';

import '../../widgets/inventory_shared.dart';
import '../barang/barang_list_screen.dart';
import '../riwayat_aktivitas_screen.dart';
import '../servis/servis_list_screen.dart';
import 'pesanan_tambah_sheet.dart';
import 'pesanan_edit_sheet.dart';
import 'pesanan_tandai_selesai_konfirmasi.dart';
import 'pesanan_hapus_konfirmasi.dart';

class PesananListScreen extends StatefulWidget {
  const PesananListScreen({super.key});

  @override
  State<PesananListScreen> createState() => _PesananListScreenState();
}

class _PesananListScreenState extends State<PesananListScreen> {
  final _service = PesananService();
  List<Pesanan> _pesananList = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_pesananList.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await _service.getPesanan();
      if (mounted) {
        setState(() {
          _pesananList = data;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showError(context, 'Gagal memuat data pesanan');
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
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
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white.withValues(alpha: 0.2), height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildIncomeCard(),
                    const SizedBox(height: 24),
                    _buildListPesanan(),
                    const SizedBox(height: 48),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: const Color(0xFF64748B),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      currentIndex: 2, // Orders
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
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RiwayatAktivitasScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
        BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'Service'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: 'Activity'),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
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
              'DATA PESANAN',
              style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Data Pesanan',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Menampilkan seluruh data pesanan barang gudang.',
          style: TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x14001E40), offset: Offset(0, 8), blurRadius: 32)
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PesananTambahSheet(
                    onSaved: _loadData,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Tambah Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final total = _pesananList.length;
    final belumSelesai = _pesananList.where((p) => p.status == 'Belum Selesai').length;
    final selesai = _pesananList.where((p) => p.status == 'Selesai').length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'TOTAL PESANAN',
                value: '$total',
                icon: Icons.shopping_cart,
                iconColor: AppColors.primary,
                bgColor: AppColors.cardBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'SELESAI',
                value: '$selesai',
                icon: Icons.local_shipping,
                iconColor: AppColors.success,
                bgColor: AppColors.cardGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          title: 'BELUM SELESAI',
          value: '$belumSelesai',
          icon: Icons.hourglass_empty,
          iconColor: AppColors.warning,
          bgColor: AppColors.cardOrange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D001E40),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    int totalPendapatan = 0;
    for (var p in _pesananList) {
      if (p.status == 'Selesai') totalPendapatan += p.totalHarga;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFc4c6cf).withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D001E40),
            offset: Offset(0, 4),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL PENDAPATAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rupiah(totalPendapatan),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66ACE6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            Icons.payments,
            size: 48,
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildListPesanan() {
    int totalItems = _pesananList.length;
    int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    if (_currentPage > totalPages) _currentPage = totalPages;
    
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    List<Pesanan> paginatedList = _pesananList.skip(startIndex).take(_itemsPerPage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Pesanan Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
          ],
        ),
        const SizedBox(height: 16),
        if (_pesananList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Belum ada data pesanan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else ...[
          ...paginatedList.map((pesanan) => _buildPesananCard(pesanan)),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Prev Button
                  InkWell(
                    onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentPage > 1 ? const Color(0xFFC4C6CF) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: _currentPage > 1 ? const Color(0xFF0B1C30) : const Color(0xFFC4C6CF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Page Numbers
                  ...List.generate(totalPages, (index) {
                    int pageNumber = index + 1;
                    bool isActive = pageNumber == _currentPage;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => setState(() => _currentPage = pageNumber),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isActive ? AppColors.primary : const Color(0xFFD3E4FE).withValues(alpha: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              '$pageNumber',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isActive ? Colors.white : const Color(0xFF44474E),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Next Button
                  InkWell(
                    onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentPage < totalPages ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: _currentPage < totalPages ? AppColors.primary : const Color(0xFFC4C6CF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPesananCard(Pesanan pesanan) {
    final isSelesai = pesanan.status == 'Selesai';
    final statusBgColor = isSelesai ? AppColors.cardGreen : AppColors.cardOrange;
    final statusTextColor = isSelesai ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFc4c6cf).withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D001E40),
            offset: Offset(0, 4),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pesanan.idPesanan} • ${pesanan.namaBarang}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Bahan: ${pesanan.bahan}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  pesanan.status.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: const Color(0xFFc4c6cf).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem('Jumlah', '${pesanan.jumlah} Unit'),
                ),
                Expanded(
                  child: _buildDetailItem('Harga', rupiah(pesanan.totalHarga), isPrice: true),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFc4c6cf).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pesanan.catatan.isNotEmpty ? pesanan.catatan : '-',
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dipesan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(pesanan.tanggalDipesan),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  if (isSelesai) ...[
                    const SizedBox(height: 8),
                    const Text('Terkirim', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      pesanan.tanggalKirim != null ? _formatDate(pesanan.tanggalKirim!) : '-',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  if (!isSelesai) ...[
                    _buildActionButton(
                      Icons.check,
                      AppColors.success,
                      onTap: () async {
                        final confirm = await showPremiumTandaiSelesaiConfirmModal(
                          context,
                          pesanan.idPesanan,
                          pesanan.namaBarang,
                        );
                        if (confirm && mounted) {
                          try {
                            await _service.tandaiSelesai(pesanan.idPesanan);
                            if (context.mounted) {
                              showSuccess(context, 'Pesanan ditandai selesai');
                            }
                            _loadData();
                          } catch (e) {
                            if (context.mounted) showError(context, e.toString());
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.edit,
                      const Color(0xFFF59E0B), // warning
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PesananEditSheet(
                            pesanan: pesanan,
                            onSaved: _loadData,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildActionButton(
                    Icons.delete,
                      AppColors.danger,
                      onTap: () async {
                        final confirm = await showPremiumPesananHapusConfirmModal(
                          context,
                          pesanan.namaBarang,
                          pesanan.bahan,
                          pesanan.idPesanan,
                        );
                        if (confirm && mounted) {
                        final id = pesanan.idPesanan;
                        final idx = _pesananList.indexWhere((p) => p.idPesanan == id);
                        final deletedItem = idx != -1 ? _pesananList[idx] : null;
                        if (idx != -1) setState(() => _pesananList.removeAt(idx));
                        
                        try {
                          await _service.hapusPesanan(id);
                          if (context.mounted) showSuccess(context, 'Pesanan berhasil dihapus');
                        } catch (e) {
                          if (context.mounted) {
                            if (deletedItem != null) setState(() => _pesananList.insert(idx, deletedItem));
                            showError(context, e.toString());
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isPrice = false, bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color ?? AppColors.primary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Divider(color: Color(0xFFE2E8F0), thickness: 1),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/LogoDamar.jpeg',
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Gudang Damar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003EA8), // on-tertiary-fixed-variant
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 12,
                children: [
                  _buildFooterLink('Kebijakan Privasi'),
                  _buildFooterLink('Syarat & Ketentuan'),
                  _buildFooterLink('Pengiriman'),
                  _buildFooterLink('FAQ'),
                  _buildFooterLink('Report Issue'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2026 Gudang Damar. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xB344474E), // on-surface-variant/70
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF44474E), // on-surface-variant
        ),
      ),
    );
  }
}

