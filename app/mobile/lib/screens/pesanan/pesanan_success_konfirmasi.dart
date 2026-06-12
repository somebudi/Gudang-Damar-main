import 'package:flutter/material.dart';
import '../../models/pesanan.dart';
import '../../widgets/inventory_shared.dart';

Future<void> showPesananSuccessModal(
  BuildContext context,
  Pesanan pesanan, {
  bool isEdit = false,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Success',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC4C6CF).withValues(alpha: 0.3)),
              boxShadow: const [BoxShadow(color: Color(0x14001E40), offset: Offset(0, 8), blurRadius: 32)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F3FD),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isEdit)
                              const BoxShadow(color: Color(0x3366ACE6), blurRadius: 40)
                          ],
                        ),
                        child: Center(
                          child: Icon(isEdit ? Icons.check : Icons.check_circle, size: isEdit ? 32 : 48, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEdit ? 'Berhasil Diperbarui! 🥳' : 'Berhasil Dipesan! 🎉',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEdit ? 'Data pesanan telah berhasil diperbarui dalam sistem.' : 'Pesanan barang telah berhasil ditambahkan ke dalam sistem.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                
                // Details Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC4C6CF).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text('DETAIL PESANAN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0x4DC4C6CF)),
                        ),
                        _buildDetailRow('Nama Barang', pesanan.namaBarang, bold: true, valueColor: AppColors.primary),
                        const SizedBox(height: 12),
                        _buildDetailRow('Bahan', pesanan.bahan.isNotEmpty ? pesanan.bahan : '-'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Jumlah', '${pesanan.jumlah} Pcs'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Bentuk', pesanan.bentuk.isNotEmpty ? pesanan.bentuk : '-'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Ukuran', pesanan.ukuran.isNotEmpty ? '${pesanan.ukuran} mm' : '-'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Ketebalan', pesanan.ketebalan.isNotEmpty ? '${pesanan.ketebalan} mm' : '-'),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0x33C4C6CF)),
                        ),
                        _buildDetailRow('Harga', rupiah(pesanan.totalHarga), bold: true, valueColor: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text('CATATAN', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFC4C6CF).withValues(alpha: 0.3)),
                          ),
                          child: Text(pesanan.catatan.isEmpty ? '-' : pesanan.catatan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: Color(0x33C4C6CF))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Mengerti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}

Widget _buildDetailRow(String label, String value, {bool bold = false, Color? valueColor}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
      const Text(':', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}
