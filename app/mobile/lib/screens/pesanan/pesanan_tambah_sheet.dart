import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/inventory_shared.dart';
import '../../services/pesanan_service.dart';
import '../../services/ai_image_service.dart';
import 'pesanan_success_konfirmasi.dart';

class PesananTambahSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const PesananTambahSheet({super.key, required this.onSaved});

  @override
  State<PesananTambahSheet> createState() => _PesananTambahSheetState();
}

class _PesananTambahSheetState extends State<PesananTambahSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = PesananService();
  bool _isLoading = false;

  // AI Image Generation
  Uint8List? _aiImageBytes;
  bool _isGeneratingImage = false;
  String? _aiErrorMsg;

  final _namaController = TextEditingController();
  final _bahanController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _bentukController = TextEditingController();
  final _ukuranController = TextEditingController();
  final _ketebalanController = TextEditingController();
  final _hargaController = TextEditingController();
  final _catatanController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'nama_barang': _namaController.text,
        'bahan': _bahanController.text,
        'jumlah': int.parse(_jumlahController.text),
        'bentuk': _bentukController.text,
        'ukuran': double.tryParse(_ukuranController.text),
        'ketebalan': double.tryParse(_ketebalanController.text),
        'harga': int.tryParse(_hargaController.text),
        'catatan': _catatanController.text,
      };

      final pesananBaru = await _service.tambahPesanan(data);

      if (mounted) {
        Navigator.pop(context);
        showPesananSuccessModal(context, pesananBaru, isEdit: false);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bahanController.dispose();
    _jumlahController.dispose();
    _bentukController.dispose();
    _ukuranController.dispose();
    _ketebalanController.dispose();
    _hargaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tambah Pesanan Baru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDataUtama(),
                    const SizedBox(height: 24),
                    _buildSpesifikasi(),
                    const SizedBox(height: 24),
                    _buildAIPreview(),
                    const SizedBox(height: 80), // Padding for bottom footer
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.only(
                left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [BoxShadow(color: Color(0x0D001E40), offset: Offset(0, -4), blurRadius: 24)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Batal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF66ACE6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Tambah Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataUtama() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DATA UTAMA', style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textSecondary, letterSpacing: 1)),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          _buildInput(label: 'Nama Barang', controller: _namaController, placeholder: 'Contoh: Piring', isRequired: true),
          const SizedBox(height: 12),
          _buildInput(label: 'Bahan', controller: _bahanController, placeholder: 'Contoh: Besi, Kayu, PVC', isRequired: true),
          const SizedBox(height: 12),
          _buildInput(
            label: 'Jumlah', 
            controller: _jumlahController, 
            placeholder: '0', 
            isRequired: true, 
            isNumber: true, 
            suffixText: 'Pcs',
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildSpesifikasi() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SPESIFIKASI', style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textSecondary, letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                child: const Text('Opsional', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              )
            ],
          ),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'Bentuk', 
                  controller: _bentukController, 
                  placeholder: 'Lembaran',
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInput(
                  label: 'Ukuran', 
                  controller: _ukuranController, 
                  placeholder: '0', 
                  isNumber: true, 
                  suffixText: 'mm',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'Ketebalan', 
                  controller: _ketebalanController, 
                  placeholder: '0.0', 
                  isNumber: true, 
                  suffixText: 'mm',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInput(
                  label: 'Harga', 
                  controller: _hargaController, 
                  placeholder: '0', 
                  isRequired: true, 
                  isNumber: true, 
                  prefixText: 'Rp',
                  onChanged: (val) {
                    String digits = val.replaceAll(RegExp(r'\D'), '');
                    if (digits.isNotEmpty) {
                      String formatted = rupiah(int.parse(digits));
                      _hargaController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    } else {
                      _hargaController.clear();
                    }
                  },
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _catatanController,
                maxLines: 4,
                maxLength: 1000,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan khusus...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF66ACE6))),
                  counterText: '',
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _catatanController,
                    builder: (context, value, child) {
                      return Text(
                        '${value.text.length} / 1000 karakter',
                        style: TextStyle(
                          fontSize: 12,
                          color: value.text.length >= 1000 ? AppColors.danger : AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateAiImage() async {
    final nama = _namaController.text.trim();
    final bahan = _bahanController.text.trim();

    if (nama.isEmpty) {
      showError(context, 'Isi Nama Barang terlebih dahulu untuk generate gambar');
      return;
    }

    setState(() {
      _isGeneratingImage = true;
      _aiErrorMsg = null;
      _aiImageBytes = null;
    });

    final imageBytes = await AiImageService.generateProductImage(
      namaBarang: nama,
      bahan: bahan,
      bentuk: _bentukController.text.trim(),
      ukuran: _ukuranController.text.trim(),
      ketebalan: _ketebalanController.text.trim(),
      catatan: _catatanController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isGeneratingImage = false;
        if (imageBytes != null) {
          _aiImageBytes = imageBytes;
        } else {
          _aiErrorMsg = 'Gagal generate gambar. Pastikan server Laravel menyala dan coba lagi.';
        }
      });
    }
  }

  void _openImageFullscreen(BuildContext context, Uint8List bytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenImageViewer(imageBytes: bytes),
      ),
    );
  }

  Widget _buildAIPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDBEAFE), Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC4C6CF).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFF66ACE6), size: 16),
              SizedBox(width: 6),
              Text('Pratinjau Gambar AI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(' (opsional)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Visualisasi produk otomatis berdasarkan data yang diisi.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Image Preview Area
          if (_aiImageBytes != null) ...[
            GestureDetector(
              onTap: () => _openImageFullscreen(context, _aiImageBytes!),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _aiImageBytes!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Lihat', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF1F2937), size: 13),
                const SizedBox(width: 4),
                const Text('Berhasil dibuat', style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w500)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openImageFullscreen(context, _aiImageBytes!),
                  child: const Text('Lihat penuh →', style: TextStyle(fontSize: 12, color: Color(0xFF66ACE6), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ] else if (_isGeneratingImage) ...[
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(color: Color(0xFF66ACE6), strokeWidth: 3),
                  ),
                  SizedBox(height: 12),
                  Text('AI sedang membuat gambar...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('Mohon tunggu ±30 detik', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ] else if (_aiErrorMsg != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_aiErrorMsg!, style: const TextStyle(fontSize: 12, color: Color(0xFFB71C1C)))),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGeneratingImage ? null : _generateAiImage,
              icon: _isGeneratingImage
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary))
                  : Icon(
                      _aiImageBytes != null ? Icons.refresh : Icons.auto_awesome,
                      size: 16,
                      color: const Color(0xFF66ACE6),
                    ),
              label: Text(
                _isGeneratingImage
                    ? 'Sedang generate...'
                    : _aiImageBytes != null
                        ? 'Generate Ulang'
                        : 'Generate Gambar AI',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: Color(0xFF66ACE6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('Powered by Pollinations AI', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool isRequired = false,
    bool isNumber = false,
    String? prefixText,
    String? suffixText,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            if (isRequired) const Text(' *', style: TextStyle(color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: isRequired ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null : null,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixText: prefixText != null ? '$prefixText ' : null,
            prefixStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            suffixIcon: suffixText != null
                ? Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                    child: Text(suffixText, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF66ACE6))),
            errorStyle: const TextStyle(height: 0), // hide text, just red border
          ),
        ),
      ],
    );
  }
}

class _FullscreenImageViewer extends StatefulWidget {
  final Uint8List imageBytes;

  const _FullscreenImageViewer({required this.imageBytes});

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  final TransformationController _controller = TransformationController();
  bool _isZoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
    setState(() => _isZoomed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Pratinjau Gambar AI',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          if (_isZoomed)
            IconButton(
              icon: const Icon(Icons.zoom_out_map, color: Colors.white),
              tooltip: 'Reset Zoom',
              onPressed: _resetZoom,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 5.0,
              onInteractionEnd: (details) {
                final scale = _controller.value.getMaxScaleOnAxis();
                setState(() => _isZoomed = scale > 1.05);
              },
              child: Center(
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF1F2937),
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 14,
              bottom: MediaQuery.of(context).padding.bottom + 14,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pinch, size: 14, color: Colors.white54),
                SizedBox(width: 6),
                Text(
                  'Cubit untuk zoom • Ketuk dua kali untuk zoom',
                  style: TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



