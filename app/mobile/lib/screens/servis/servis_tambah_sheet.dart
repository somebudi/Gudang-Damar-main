import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/inventory_shared.dart';
import '../../services/servis_service.dart';

class ServisTambahSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const ServisTambahSheet({super.key, required this.onSaved});

  @override
  State<ServisTambahSheet> createState() => _ServisTambahSheetState();
}

class _ServisTambahSheetState extends State<ServisTambahSheet> {
  final _formKey = GlobalKey<FormState>();
  final _servisService = ServisService();
  bool _isLoading = false;

  final _namaController = TextEditingController();
  final _bahanController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');
  final _kodeController = TextEditingController();
  final _hargaController = TextEditingController();
  final _catatanController = TextEditingController();

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
    _catatanController.addListener(_updateCounter);
  }

  void _updateCounter() {
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    showLoadingModal(context);
    
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

      await _servisService.tambahServis(data);
      
      if (mounted) {
        Navigator.pop(context); // Pop loading modal
        setState(() => _isLoading = false);
        
        widget.onSaved(); // Refresh list background
        
        await showPremiumServisSuccessModal(context, data); // Wait for user to dismiss success modal
        
        if (mounted) {
          Navigator.pop(context); // Pop bottom sheet
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading modal
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
                const Text('Tambah Servis',
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
                      label: 'Nama Barang',
                      isRequired: true,
                      controller: _namaController,
                      hintText: 'Contoh: Panci',
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Bahan',
                      isRequired: true,
                      controller: _bahanController,
                      hintText: 'Contoh: Alumunium',
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Jumlah',
                            isRequired: true,
                            controller: _jumlahController,
                            hintText: '1',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (val) => val == null || val.isEmpty || int.tryParse(val) == 0 ? 'Wajib diisi (>0)' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'Bentuk Barang',
                            isRequired: false,
                            optionalLabel: '(kode)',
                            controller: _kodeController,
                            hintText: '001',
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Harga',
                      isRequired: true,
                      controller: _hargaController,
                      hintText: '0',
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
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    // Catatan Field
                    Row(
                      children: const [
                        Text('Catatan', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text(' *', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        hintText: 'Detail servis yang diperlukan...',
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
                              Icon(Icons.add, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Tambah Servis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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


