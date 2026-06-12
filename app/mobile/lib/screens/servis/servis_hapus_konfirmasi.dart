import 'dart:ui';
import 'package:flutter/material.dart';

Future<bool> showPremiumServisHapusConfirmModal(
  BuildContext context,
  String namaBarang,
  String bahan,
  String idPesanan,
) async {
  final displayId = 'SRV-${idPesanan.padLeft(4, '0')}';
  
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          // Backdrop with blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: const Color(0xFF0B1C30).withValues(alpha: 0.4),
              ),
            ),
          ),
          // Modal Card
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white, // surface-container-lowest
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC4C6CF).withValues(alpha: 0.3)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 20), blurRadius: 50),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFDAD6), // error-container
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.delete_outline, size: 32, color: Color(0xFFBA1A1A)), // error
                        ),
                      ),
                      
                      // Heading
                      const Text(
                        'Konfirmasi Hapus',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30), // on-surface
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      const Text(
                        'Tindakan ini tidak dapat dibatalkan. Konfirmasi penghapusan layanan.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF44474E), // on-surface-variant
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Detail Card
                      Container(
                        padding: const EdgeInsets.all(20), // p-card-padding
                        decoration: BoxDecoration(
                          color: Colors.white, // transparent inside card, just border
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC4C6CF)), // outline-variant
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCE9FF), // surface-container-high approx
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFC4C6CF).withValues(alpha: 0.5)),
                              ),
                              child: const Center(
                                child: Icon(Icons.build, color: Color(0xFF44474E), size: 28), // text-on-surface-variant
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$namaBarang ',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B1C30),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD3E4FE), // surface-variant
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFC4C6CF)),
                                        ),
                                        child: Text(
                                          displayId,
                                          style: const TextStyle(
                                            fontFamily: 'JetBrains Mono',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF44474E),
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
                      ),
                      const SizedBox(height: 32),
                      
                      // Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF66ACE6), // brand-blue
                                foregroundColor: Colors.white, // on-error/white
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // rounded-xl
                                elevation: 2, // shadow-md
                              ),
                              child: const Text(
                                'Hapus Sekarang',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF44474E), // on-surface-variant
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500), // font-medium
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );

  return result ?? false;
}
