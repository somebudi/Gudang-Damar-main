import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../services/barang_service.dart';
import '../../widgets/inventory_shared.dart';
import '../../widgets/user_profile_avatar_button.dart';
import '../pesanan/pesanan_list_screen.dart';
import '../servis/servis_list_screen.dart';
import 'barang_tambah_sheet.dart';
import 'barang_edit_sheet.dart';
import 'barang_hapus_konfirmasi.dart';
import '../riwayat_aktivitas_screen.dart';

class BarangListScreen extends StatefulWidget {
  const BarangListScreen({super.key});

  @override
  State<BarangListScreen> createState() => _BarangListScreenState();
}

class _BarangListScreenState extends State<BarangListScreen> {
  final _service = BarangService();
  List<Barang> _barangList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _currentSort = 'Nama (A-Z)';
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAll(search: _searchQuery);
      if (mounted) {
        setState(() {
          _barangList = data;
          _applySorting();
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySorting() {
    if (_currentSort == 'Nama (A-Z)') {
      _barangList.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
    } else if (_currentSort == 'Harga Tertinggi') {
      _barangList.sort((a, b) => b.harga.compareTo(a.harga));
    } else if (_currentSort == 'Harga Terendah') {
      _barangList.sort((a, b) => a.harga.compareTo(b.harga));
    } else if (_currentSort == 'Stok Terendah') {
      _barangList.sort((a, b) => a.jumlah.compareTo(b.jumlah));
    } else if (_currentSort == 'Stok Tertinggi') {
      _barangList.sort((a, b) => b.jumlah.compareTo(a.jumlah));
    }
  }

  Future<void> _hapusBarang(Barang barang) async {
    final confirm = await showPremiumBarangHapusConfirmModal(
      context,
      barang.nama,
      barang.bahan,
      barang.idBarang.toString(),
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      await _service.delete(barang.idBarang);
      if (mounted) {
        showSuccess(context, 'Barang berhasil dihapus');
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        showError(context, e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Text(
                'List Barang',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola data barang, pantau ketersediaan stok, dan perbarui informasi gudang secara efisien dalam satu tempat.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                controller: _searchController,
                onSubmitted: (v) {
                  _searchQuery = v;
                  _fetchData();
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF66ACE6)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final res = await showTambahBarangDialog(context);
                    if (res != null && context.mounted) {
                      showPremiumSuccessModal(context);
                      _fetchData();
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'Tambah Barang',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66ACE6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sorting
              Row(
                children: [
                  const Text(
                    'Urutkan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentSort,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF64748B),
                            size: 16,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          items:
                              [
                                'Nama (A-Z)',
                                'Harga Tertinggi',
                                'Harga Terendah',
                                'Stok Tertinggi',
                                'Stok Terendah',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _currentSort = val;
                                _applySorting();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Inventory List
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF66ACE6)),
                )
              else if (_barangList.isEmpty)
                const Center(
                  child: Text(
                    'Tidak ada barang ditemukan.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final startIndex = (_currentPage - 1) * _itemsPerPage;
                    final endIndex =
                        (startIndex + _itemsPerPage > _barangList.length)
                        ? _barangList.length
                        : startIndex + _itemsPerPage;
                    final displayedList = _barangList.sublist(
                      startIndex,
                      endIndex,
                    );
                    final totalPages = (_barangList.length / _itemsPerPage)
                        .ceil();

                    return Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedList.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 16),
                          itemBuilder: (ctx, i) {
                            final b = displayedList[i];
                            final isLowStock = b.jumlah < 5;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF3F4F6),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      b.bentuk.isEmpty ? 'Umum' : b.bentuk,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    b.nama,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    rupiah(b.harga),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF66ACE6),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isLowStock
                                              ? 'Stok: ${b.jumlah} Unit (Low)'
                                              : 'Stok: ${b.jumlah} Unit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isLowStock
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isLowStock
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                highlightColor: const Color(
                                                  0xFF3B82F6,
                                                ).withValues(alpha: 0.2),
                                                splashColor: const Color(
                                                  0xFF3B82F6,
                                                ).withValues(alpha: 0.3),
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    barrierColor: Colors.black.withValues(alpha: 0.4),
                                                    builder: (_) =>
                                                        _DetailBarangSheet(
                                                          barang: b,
                                                        ),
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons
                                                        .remove_red_eye_outlined,
                                                    size: 18,
                                                    color: Color(0xFF3B82F6),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                highlightColor: const Color(
                                                  0xFFF59E0B,
                                                ).withValues(alpha: 0.2),
                                                splashColor: const Color(
                                                  0xFFF59E0B,
                                                ).withValues(alpha: 0.3),
                                                onTap: () async {
                                                  final res =
                                                      await showModalBottomSheet<
                                                        bool
                                                      >(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (_) =>
                                                            BarangEditSheet(
                                                              barang: b,
                                                            ),
                                                      );
                                                  if (res == true &&
                                                      context.mounted) {
                                                    showEditSuccessModal(
                                                      context,
                                                    );
                                                    _fetchData();
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: Color(0xFFF59E0B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                highlightColor: const Color(
                                                  0xFFF87171,
                                                ).withValues(alpha: 0.2),
                                                splashColor: const Color(
                                                  0xFFF87171,
                                                ).withValues(alpha: 0.3),
                                                onTap: () => _hapusBarang(b),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Color(0xFFEF4444),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Previous Button
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
                                            ? AppColors.primary.withValues(alpha: 0.3)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 18,
                                      color: _currentPage > 1
                                          ? AppColors.primary
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
                    );
                  },
                ),

              // Footer
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
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: 0, // Inventory
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ServisListScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PesananListScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RiwayatAktivitasScreen(),
              ),
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
      ),
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

// ─── Detail Popup ─────────────────────────────────────────────────────────────
class _DetailBarangSheet extends StatelessWidget {
  final Barang barang;
  const _DetailBarangSheet({required this.barang});

  Widget _buildDetailRow(String label, String value, {Color valueColor = const Color(0xFF121C2A)}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF), // surface-container-low
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC0C7D1).withValues(alpha: 0.2)), // outline-variant/20
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF40474F), // on-surface-variant
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12, // label-md
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF717880), // outline
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFC0C7D1).withValues(alpha: 0.3), // outline-variant/30
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white, // surface-container-lowest
          borderRadius: BorderRadius.circular(12), // rounded-xl
          border: Border.all(color: const Color(0xFFC0C7D1).withValues(alpha: 0.3)), // outline-variant/30
          boxShadow: const [
            BoxShadow(color: Colors.black12, offset: Offset(0, 10), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFC0C7D1).withValues(alpha: 0.3), // outline-variant/30
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Barang',
                    style: TextStyle(
                      fontSize: 20, // title-lg
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121C2A), // on-surface
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.close, color: Color(0xFF40474F)), // on-surface-variant
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info List
                    _buildDetailRow('Nama Barang', barang.nama),
                    const SizedBox(height: 12),
                    _buildDetailRow('Guna/Merek', barang.gunaMerek.isNotEmpty ? barang.gunaMerek : '-'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Bahan', barang.bahan.isNotEmpty ? barang.bahan : '-'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Bentuk', barang.bentuk.isNotEmpty ? barang.bentuk : '-'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Ukuran', '${barang.ukuran}'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Ketebalan', barang.ketebalan.isNotEmpty ? barang.ketebalan : '-'),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Stok & Harga'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Harga Satuan', rupiah(barang.harga), valueColor: const Color(0xFF66ACE6)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Stok Tersedia', '${barang.jumlah} Unit', valueColor: const Color(0xFF66ACE6)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Total Nilai Stok', rupiah(barang.total)),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Statistik Penjualan'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Terjual', '${barang.jumlahTerjual} Unit'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Pendapatan', rupiah(barang.pendapatan), valueColor: const Color(0xFFE79400)), // tertiary-container
                  ],
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66ACE6), // primary-container
                  foregroundColor: const Color(0xFF003F63), // on-primary-container
                  elevation: 2, // shadow-md
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // rounded-xl
                  ),
                  minimumSize: const Size(double.infinity, 56), // py-4
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
