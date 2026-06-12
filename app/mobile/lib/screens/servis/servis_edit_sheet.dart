import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/inventory_shared.dart';
import '../../services/servis_service.dart';

class ServisEditSheet extends StatefulWidget {
  final Map<String, dynamic> servis;
  final VoidCallback onSaved;

  const ServisEditSheet({
    super.key,
    required this.servis,
    required this.onSaved,
  });

  @override
  State<ServisEditSheet> createState() => _ServisEditSheetState();
}

class _ServisEditSheetState extends State<ServisEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _servisService = ServisService();
  bool _isLoading = false;

  late TextEditingController _namaController;
  late TextEditingController _bahanController;
  late TextEditingController _jumlahController;
  late TextEditingController _kodeController;
  late TextEditingController _hargaController;
  late TextEditingController _catatanController;

  String formatCurrency(int amount) {
    String res = amount.toString();
    String formatted = '';
    for (int i = 0; i < res.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = res[res.length - 1 - i] + formatted;
    }
    return formatted;
  }

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.servis['nama_barang']?.toString());
    _bahanController = TextEditingController(text: widget.servis['bahan']?.toString() ?? '');
    _jumlahController = TextEditingController(text: widget.servis['jumlah']?.toString() ?? '1');
    _kodeController = TextEditingController(text: widget.servis['bentuk']?.toString() ?? '');
    
    final int harga = widget.servis['harga'] != null ? widget.servis['harga'] as int : 0;
    _hargaController = TextEditingController(text: harga > 0 ? formatCurrency(harga) : '');
    
    _catatanController = TextEditingController(text: widget.servis['catatan']?.toString() ?? '');
    _catatanController.addListener(_updateCounter);
  }

  void _updateCounter() {
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final hargaDigits = _hargaController.text.replaceAll(RegExp(r'\D'), '');
      
      final data = {
        'nama_barang': _namaController.text,
        'bahan': _bahanController.text,
        'jumlah': int.tryParse(_jumlahController.text) ?? 1,
        'bentuk_barang': _kodeController.text,
        'harga': hargaDigits.isNotEmpty ? int.parse(hargaDigits) : 0,
        'catatan': _catatanController.text,
      };

      await _servisService.updateServis(widget.servis['id_pesanan'].toString(), data);
      
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context); // Pop the edit sheet
        await showPremiumServisSuccessModal(context, data, isEdit: true); // Show the success modal
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showError(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bahanController.dispose();
    _jumlahController.dispose();
    _kodeController.dispose();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Servis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // Body Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: 'NAMA BARANG',
                      isRequired: false,
                      controller: _namaController,
                      hintText: 'Masukkan nama barang',
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'BAHAN',
                      isRequired: false,
                      controller: _bahanController,
                      hintText: 'Contoh: Besi, Kayu, PVC',
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'JUMLAH',
                            isRequired: false,
                            optionalLabel: '(opsional)',
                            controller: _jumlahController,
                            hintText: '1',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'BENTUK BARANG',
                            isRequired: false,
                            optionalLabel: '(KODE) (opsional)',
                            controller: _kodeController,
                            hintText: 'Contoh: Persegi, Bulat',
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'HARGA',
                      isRequired: false,
                      optionalLabel: '(opsional)',
                      controller: _hargaController,
                      hintText: 'Contoh: 50000',
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp  ',
                      onChanged: (val) {
                        String digits = val.replaceAll(RegExp(r'\D'), '');
                        if (digits.isNotEmpty) {
                          String formatted = formatCurrency(int.parse(digits));
                          _hargaController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        } else {
                          _hargaController.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Catatan Field
                    Row(
                      children: const [
                        Text('CATATAN', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text(' *', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan khusus untuk pesanan ini...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF66ACE6), width: 1.5)),
                        counterText: '', // Sembunyikan counter bawaan
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${_catatanController.text.length} / 1000 karakter',
                          style: TextStyle(
                            fontSize: 12,
                            color: _catatanController.text.length >= 1000 ? AppColors.danger : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
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
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF66ACE6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.save, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildInputField({
    required String label,
    required bool isRequired,
    String? optionalLabel,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            if (isRequired) const Text(' *', style: TextStyle(color: AppColors.danger)),
            if (optionalLabel != null) ...[
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  optionalLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF66ACE6), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.danger, width: 1)),
          ),
        ),
      ],
    );
  }
}


