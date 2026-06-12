import 'package:flutter/material.dart';
import '../../models/pesanan.dart';
import '../../widgets/inventory_shared.dart';
import '../../services/pesanan_service.dart';
import 'pesanan_success_konfirmasi.dart';

class PesananEditSheet extends StatefulWidget {
  final Pesanan pesanan;
  final VoidCallback onSaved;

  const PesananEditSheet({super.key, required this.pesanan, required this.onSaved});

  @override
  State<PesananEditSheet> createState() => _PesananEditSheetState();
}

class _PesananEditSheetState extends State<PesananEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = PesananService();
  bool _isLoading = false;

  late TextEditingController _namaController;
  late TextEditingController _bahanController;
  late TextEditingController _jumlahController;
  late TextEditingController _bentukController;
  late TextEditingController _ukuranController;
  late TextEditingController _ketebalanController;
  late TextEditingController _hargaController;
  late TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.pesanan.namaBarang);
    _bahanController = TextEditingController(text: widget.pesanan.bahan);
    _jumlahController = TextEditingController(text: widget.pesanan.jumlah.replaceAll(RegExp(r'[^0-9]'), ''));
    _bentukController = TextEditingController(text: widget.pesanan.bentuk);
    _ukuranController = TextEditingController(text: widget.pesanan.ukuran);
    _ketebalanController = TextEditingController(text: widget.pesanan.ketebalan);
    _hargaController = TextEditingController(text: widget.pesanan.totalHarga.toString());
    _catatanController = TextEditingController(text: widget.pesanan.catatan);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'nama_barang': _namaController.text,
        'bahan': _bahanController.text,
        'jumlah': int.tryParse(_jumlahController.text) ?? 1,
        'bentuk': _bentukController.text,
        'ukuran': double.tryParse(_ukuranController.text),
        'ketebalan': double.tryParse(_ketebalanController.text),
        'harga': int.tryParse(_hargaController.text),
        'catatan': _catatanController.text,
      };

      final updatedPesanan = await _service.updatePesanan(widget.pesanan.idPesanan, data);

      if (mounted) {
        Navigator.pop(context);
        showPesananSuccessModal(context, updatedPesanan, isEdit: true);
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
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('#${widget.pesanan.idPesanan}', style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textSecondary)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(backgroundColor: AppColors.background),
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
                    _buildInput(label: 'Nama Barang', controller: _namaController, isRequired: true),
                    const SizedBox(height: 16),
                    _buildInput(label: 'Bahan', controller: _bahanController, isRequired: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInput(label: 'Jumlah', controller: _jumlahController, isRequired: true, isNumber: true, suffixText: 'Pcs')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput(label: 'Bentuk', controller: _bentukController, suffixLabel: '(Opt)')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInput(label: 'Ukuran', controller: _ukuranController, isNumber: true, suffixText: 'cm', suffixLabel: '(Opt)')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput(label: 'Ketebalan', controller: _ketebalanController, isNumber: true, suffixText: 'mm', suffixLabel: '(Opt)')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInput(label: 'Harga', controller: _hargaController, isRequired: true, isNumber: true, prefixText: 'Rp'),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Catatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                            const SizedBox(width: 4),
                            Text('(Opt)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withValues(alpha: 0.5))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _catatanController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
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
                      backgroundColor: const Color(0xFF1F2937), // Secondary
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.save, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool isNumber = false,
    String? prefixText,
    String? suffixText,
    String? suffixLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            if (isRequired) const Text(' *', style: TextStyle(color: AppColors.danger)),
            if (suffixLabel != null) ...[
              const SizedBox(width: 4),
              Text(suffixLabel, style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withValues(alpha: 0.5))),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: isRequired ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null : null,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: prefixText != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8, top: 12),
                    child: Text(prefixText, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixText != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12, top: 12),
                    child: Text(suffixText, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            errorStyle: const TextStyle(height: 0),
          ),
        ),
      ],
    );
  }
}


