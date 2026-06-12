import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../services/barang_service.dart';
import '../../widgets/inventory_shared.dart';

Future<Barang?> showTambahBarangDialog(BuildContext context) async {
  return showModalBottomSheet<Barang>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _TambahBarangSheet(),
  );
}

class _TambahBarangSheet extends StatefulWidget {
  const _TambahBarangSheet();

  @override
  State<_TambahBarangSheet> createState() => _TambahBarangSheetState();
}

class _TambahBarangSheetState extends State<_TambahBarangSheet> {
  final _service = BarangService();
  bool _loading = false;

  final _nama = TextEditingController();
  final _merek = TextEditingController();
  final _ukuran = TextEditingController();
  final _ketebalan = TextEditingController();
  final _bentuk = TextEditingController();
  final _bahan = TextEditingController();
  final _harga = TextEditingController();
  final _jumlah = TextEditingController(text: '1');

  String? _namaError;
  String? _merekError;
  String? _ukuranError;
  String? _ketebalanError;
  String? _bentukError;
  String? _bahanError;
  String? _hargaError;
  String? _jumlahError;

  @override
  void dispose() {
    for (final c in [
      _nama, _merek, _ukuran, _ketebalan, _bentuk, _bahan, _harga, _jumlah
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _namaError = _nama.text.trim().isEmpty ? 'Wajib diisi' : null;
      _merekError = _merek.text.trim().isEmpty ? 'Wajib diisi' : null;
      _ukuranError = _ukuran.text.trim().isEmpty ? 'Wajib diisi' : null;
      _ketebalanError = _ketebalan.text.trim().isEmpty ? 'Wajib diisi' : null;
      _bentukError = _bentuk.text.trim().isEmpty ? 'Wajib diisi' : null;
      _bahanError = _bahan.text.trim().isEmpty ? 'Wajib diisi' : null;
      _hargaError = _harga.text.trim().isEmpty ? 'Wajib diisi' : null;
      _jumlahError = _jumlah.text.trim().isEmpty ? 'Wajib diisi' : null;
    });

    if (_namaError != null ||
        _merekError != null ||
        _ukuranError != null ||
        _ketebalanError != null ||
        _bentukError != null ||
        _bahanError != null ||
        _hargaError != null ||
        _jumlahError != null) {
      return;
    }
    setState(() => _loading = true);
    try {
      final barang = await _service.create(
        nama: _nama.text.trim(),
        gunaMerek: _merek.text.trim(),
        ukuran: int.tryParse(_ukuran.text) ?? 0,
        ketebalan: _ketebalan.text.trim(),
        bentuk: _bentuk.text.trim(),
        bahan: _bahan.text.trim(),
        harga: int.tryParse(_harga.text) ?? 0,
        jumlah: int.tryParse(_jumlah.text) ?? 1,
      );
      if (mounted) Navigator.pop(context, barang);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return LoadingOverlay(
      isLoading: _loading,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20, bottom: bottom + 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add_box_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text('Tambah Barang',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ]),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(label: 'Nama Barang', controller: _nama,
                  hint: 'cth: Besi Hollow 4x4', errorText: _namaError),
              const SizedBox(height: 12),
              AppTextField(label: 'Merek / Guna', controller: _merek,
                  hint: 'cth: Konstruksi', errorText: _merekError),
              const SizedBox(height: 16),

              const SectionDivider(title: 'Harga & Stok'),
              Row(children: [
                Expanded(
                  child: AppTextField(
                      label: 'Harga (Rp)',
                      controller: _harga,
                      isNumber: true,
                      hint: '0', errorText: _hargaError),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                      label: 'Jumlah',
                      controller: _jumlah,
                      isNumber: true,
                      hint: '1', errorText: _jumlahError),
                ),
              ]),
              const SizedBox(height: 16),

              const SectionDivider(title: 'Kategori'),
              Row(children: [
                Expanded(
                  child: AppTextField(
                      label: 'Ukuran',
                      controller: _ukuran,
                      isNumber: true,
                      hint: '0', errorText: _ukuranError),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: AppTextField(
                        label: 'Bentuk',
                        controller: _bentuk,
                        hint: 'cth: Hollow', errorText: _bentukError)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: AppTextField(
                        label: 'Ketebalan',
                        controller: _ketebalan,
                        hint: 'cth: 1.2mm', errorText: _ketebalanError)),
                const SizedBox(width: 12),
                Expanded(
                    child: AppTextField(
                        label: 'Bahan',
                        controller: _bahan,
                        hint: 'cth: Besi', errorText: _bahanError)),
              ]),
              const SizedBox(height: 24),

              Row(children: [
                Expanded(
                  child: AppButton(
                    label: 'Simpan',
                    onPressed: _submit,
                    color: AppColors.primary,
                    icon: Icons.save_rounded,
                    isLoading: _loading,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.border,
                    textColor: AppColors.textSecondary,
                    width: double.infinity,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

