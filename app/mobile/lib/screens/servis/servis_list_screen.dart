import 'package:flutter/material.dart';

import '../../widgets/inventory_shared.dart';
import '../../widgets/user_profile_avatar_button.dart';
import '../../models/servis.dart';
import '../../services/servis_service.dart';
import '../barang/barang_list_screen.dart';
import '../pesanan/pesanan_list_screen.dart';
import '../riwayat_aktivitas_screen.dart';
import 'servis_edit_sheet.dart';
import 'servis_hapus_konfirmasi.dart';
import 'servis_tambah_sheet.dart';
import 'servis_tandai_selesai_konfirmasi.dart';

class ServisListScreen extends StatefulWidget {
  const ServisListScreen({super.key});

  @override
  State<ServisListScreen> createState() => _ServisListScreenState();
}

class _ServisListScreenState extends State<ServisListScreen> {
  final ServisService _service = ServisService();
  List<Servis> _servisList = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getServis();
      if (mounted) {
        setState(() {
          _servisList = data;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showError(context, 'Gagal memuat data servis');
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String formatCurrency(int amount) {
    String res = amount.toString();
    String formatted = '';
    for (int i = 0; i < res.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = res[res.length - 1 - i] + formatted;
    }
    return 'Rp $formatted';
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
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  _buildListServis(),
                  const SizedBox(height: 48),
                  _buildFooter(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
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
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            const Text(
              'DATA SERVIS',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Data Servis',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola data servis barang gudang.',
          style: TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14001E40),
                offset: Offset(0, 8),
                blurRadius: 32,
              ),
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
                  builder: (context) => ServisTambahSheet(onSaved: _loadData),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Servis',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
    int totalSelesai = _servisList
        .where((p) => p.tanggalTerkirim != null)
        .length;
    int totalProses = _servisList
        .where((p) => p.tanggalTerkirim == null)
        .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'TOTAL SERVIS',
                value: '${_servisList.length}',
                icon: Icons.build,
                iconColor: AppColors.primary,
                bgColor: AppColors.cardBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'SELESAI',
                value: '$totalSelesai',
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                bgColor: AppColors.cardGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          title: 'DALAM PROSES',
          value: '$totalProses',
          icon: Icons.pending_actions,
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
    int totalPendapatan = _servisList.fold(0, (sum, p) => sum + p.pendapatan);

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
                    formatCurrency(totalPendapatan),
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

  Widget _buildListServis() {
    int totalItems = _servisList.length;
    int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    if (_currentPage > totalPages) _currentPage = totalPages;

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    List<Servis> paginatedList = _servisList
        .skip(startIndex)
        .take(_itemsPerPage)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Servis Gudang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_servisList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Belum ada data servis',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else ...[
          ...paginatedList.map((servis) => _buildServisCard(servis)),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Prev Button
                  InkWell(
                    onTap: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentPage > 1
                              ? const Color(0xFFC4C6CF)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: _currentPage > 1
                            ? const Color(0xFF0B1C30)
                            : const Color(0xFFC4C6CF),
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
                            color: isActive
                                ? AppColors.primary
                                : const Color(
                                    0xFFD3E4FE,
                                  ).withValues(alpha: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              '$pageNumber',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF44474E),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Next Button
                  InkWell(
                    onTap: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentPage < totalPages
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: _currentPage < totalPages
                            ? AppColors.primary
                            : const Color(0xFFC4C6CF),
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

  Widget _buildServisCard(Servis servis) {
    final isSelesai = servis.tanggalTerkirim != null;
    final status = isSelesai ? 'SELESAI' : 'PROSES';

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
                      Icons.build,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        servis.namaBarang,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Bahan: ${servis.bahan}',
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
                  color: isSelesai ? AppColors.cardGreen : AppColors.cardOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelesai ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: const Color(0xFFc4c6cf).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Jumlah',
                        '${servis.jumlah} Unit',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Harga',
                        formatCurrency(servis.harga),
                        isPrice: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Bentuk', servis.bentukBarang),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Tanggal Pemesanan',
                        _formatDate(servis.tanggalPemesanan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Tanggal Selesai',
                        servis.tanggalTerkirim != null
                            ? _formatDate(servis.tanggalTerkirim!)
                            : '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catatan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            servis.catatan,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isSelesai) ...[
                _buildActionButton(
                  Icons.check,
                  AppColors.success,
                  onTap: () async {
                    final confirm =
                        await showPremiumServisTandaiSelesaiConfirmModal(
                          context,
                          servis.namaBarang,
                          servis.idPesanan.toString(),
                        );
                    if (confirm && mounted) {
                      try {
                        await _service.tandaiSelesai(
                          servis.idPesanan.toString(),
                        );
                        if (mounted) {
                          showSuccess(context, 'Servis ditandai selesai');
                          _loadData();
                        }
                      } catch (e) {
                        if (mounted) showError(context, e.toString());
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
                      builder: (context) => ServisEditSheet(
                        servis: servis.toJson(),
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
                  final confirm = await showPremiumServisHapusConfirmModal(
                    context,
                    servis.namaBarang,
                    servis.bahan,
                    servis.idPesanan.toString(),
                  );
                  if (confirm && mounted) {
                    final id = servis.idPesanan;
                    final idx = _servisList.indexWhere(
                      (p) => p.idPesanan == id,
                    );
                    final deletedItem = idx != -1 ? _servisList[idx] : null;

                    if (idx != -1) {
                      setState(() => _servisList.removeAt(idx));
                    }

                    try {
                      await _service.hapusServis(id.toString());
                      if (mounted) {
                        showSuccess(context, 'Servis berhasil dihapus');
                      }
                    } catch (e) {
                      if (mounted) {
                        if (deletedItem != null) {
                          setState(() => _servisList.insert(idx, deletedItem));
                        }
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
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
            color: isPrice ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, {VoidCallback? onTap}) {
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: const Color(0xFF64748B),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      currentIndex: 1, // Service
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BarangListScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PesananListScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RiwayatAktivitasScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_outlined),
          label: 'Service',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined),
          label: 'Activity',
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
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
