import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/barang.dart';
import '../../services/barang_service.dart';
import '../../widgets/inventory_shared.dart';

class BarangEditSheet extends StatefulWidget {
  final Barang barang;
  const BarangEditSheet({super.key, required this.barang});

  @override
  State<BarangEditSheet> createState() => _BarangEditSheetState();
}

class _BarangEditSheetState extends State<BarangEditSheet>
    with SingleTickerProviderStateMixin {
  final _service = BarangService();
  bool _loading = false;
  bool _hasChanges = false;

  // Tab state: 'add' (Set Stok) or 'sell' (Catat Penjualan)
  String _activeTab = 'add';

  late Barang _currentBarang;

  late final TextEditingController _nama;
  late final TextEditingController _merek;
  late final TextEditingController _ukuran;
  late final TextEditingController _ketebalan;
  late final TextEditingController _bentuk;
  late final TextEditingController _bahan;
  late final TextEditingController _harga;

  late final TextEditingController _stokAdd;
  late final TextEditingController _stokSell;

  // Formatted harga
  String _displayHarga = '';

  @override
  void initState() {
    super.initState();
    _currentBarang = widget.barang;
    _nama = TextEditingController(text: _currentBarang.nama);
    _merek = TextEditingController(text: _currentBarang.gunaMerek);
    _ukuran = TextEditingController(text: _currentBarang.ukuran.toString());
    _ketebalan = TextEditingController(text: _currentBarang.ketebalan);
    _bentuk = TextEditingController(text: _currentBarang.bentuk);
    _bahan = TextEditingController(text: _currentBarang.bahan);
    _displayHarga = _formatCurrencyDisplay(_currentBarang.harga);
    _harga = TextEditingController(text: _displayHarga);
    _stokAdd = TextEditingController(text: '0');
    _stokSell = TextEditingController(text: '0');
  }

  String _formatCurrencyDisplay(int amount) {
    String res = amount.toString();
    String formatted = '';
    for (int i = 0; i < res.length; i++) {
      if (i > 0 && i % 3 == 0) formatted = '.$formatted';
      formatted = res[res.length - 1 - i] + formatted;
    }
    return formatted;
  }

  @override
  void dispose() {
    _nama.dispose();
    _merek.dispose();
    _ukuran.dispose();
    _ketebalan.dispose();
    _bentuk.dispose();
    _bahan.dispose();
    _harga.dispose();
    _stokAdd.dispose();
    _stokSell.dispose();
    super.dispose();
  }

  Future<void> _submitMainForm() async {
    if (_nama.text.trim().isEmpty || _harga.text.trim().isEmpty) {
      showError(context, 'Nama dan Harga wajib diisi');
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.update(
        _currentBarang.idBarang,
        nama: _nama.text.trim(),
        gunaMerek: _merek.text.trim(),
        ukuran: int.tryParse(_ukuran.text) ?? 0,
        ketebalan: _ketebalan.text.trim(),
        bentuk: _bentuk.text.trim(),
        bahan: _bahan.text.trim(),
        harga: int.tryParse(_harga.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        jumlah: _currentBarang.jumlah,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitStok() async {
    final val = int.tryParse(_stokAdd.text) ?? 0;
    if (val == 0) return;

    final targetStok = _currentBarang.jumlah + val;
    if (targetStok < 0) {
      showError(context, 'Stok akhir tidak boleh negatif');
      return;
    }

    setState(() => _loading = true);
    try {
      final updated =
          await _service.updateStok(_currentBarang.idBarang, targetStok);
      if (mounted) {
        setState(() {
          _currentBarang = updated;
          _hasChanges = true;
          _stokAdd.text = '0';
        });
        showPremiumSuccessModal(context,
            title: 'Stok Diperbarui',
            subtitle: 'Stok berhasil diperbarui secara manual.');
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitPenjualan() async {
    final val = int.tryParse(_stokSell.text) ?? 0;
    if (val <= 0) return;

    if (val > _currentBarang.jumlah) {
      showError(context, 'Stok tidak mencukupi');
      return;
    }

    setState(() => _loading = true);
    try {
      final updated =
          await _service.catatPenjualan(_currentBarang.idBarang, val);
      if (mounted) {
        setState(() {
          _currentBarang = updated;
          _hasChanges = true;
          _stokSell.text = '0';
        });
        showPremiumSuccessModal(context,
            title: 'Penjualan Dicatat',
            subtitle: 'Penjualan $val unit berhasil dicatat.');
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateStokAdd(int change) {
    int currentVal = int.tryParse(_stokAdd.text) ?? 0;
    int newVal = currentVal + change;
    if (_currentBarang.jumlah + newVal < 0) newVal = -_currentBarang.jumlah;
    setState(() => _stokAdd.text = newVal.toString());
  }

  void _updateStokSell(int change) {
    int currentVal = int.tryParse(_stokSell.text) ?? 0;
    int newVal = currentVal + change;
    if (newVal < 0) newVal = 0;
    if (newVal > _currentBarang.jumlah) newVal = _currentBarang.jumlah;
    setState(() => _stokSell.text = newVal.toString());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      margin: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFC0C7D1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF66ACE6), Color(0xFF006398)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      Text(
                        _currentBarang.nama,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF66ACE6),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context, _hasChanges),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF0B1C30), size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: const Color(0xFFE6EEFF)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info Barang Section ──────────────────────────────
                  _buildSectionLabel('Informasi Barang', Icons.inventory_2_outlined, const Color(0xFF006398)),
                  const SizedBox(height: 12),

                  _buildStyledInput(
                    label: 'Nama Barang',
                    controller: _nama,
                    icon: Icons.label_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildStyledInput(
                    label: 'Guna / Merek',
                    controller: _merek,
                    icon: Icons.branding_watermark_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStyledInput(
                          label: 'Bentuk',
                          controller: _bentuk,
                          icon: Icons.category_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStyledInput(
                          label: 'Bahan',
                          controller: _bahan,
                          icon: Icons.texture_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStyledInput(
                          label: 'Ukuran',
                          controller: _ukuran,
                          icon: Icons.straighten_outlined,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStyledInput(
                          label: 'Ketebalan',
                          controller: _ketebalan,
                          icon: Icons.height_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Harga
                  _buildHargaInput(),

                  const SizedBox(height: 20),

                  // ── Stok Card ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE6EEFF), Color(0xFFCDE5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF66ACE6).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF006398),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stok Saat Ini',
                                style: TextStyle(fontSize: 12, color: Color(0xFF40474F)),
                              ),
                              Text(
                                '${_currentBarang.jumlah} Unit',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006398),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Nilai',
                              style: TextStyle(fontSize: 11, color: Color(0xFF40474F)),
                            ),
                            Text(
                              rupiah(_currentBarang.harga * _currentBarang.jumlah),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Kelola Stok Section ──────────────────────────────
                  _buildSectionLabel('Kelola Stok', Icons.tune_rounded, const Color(0xFF855300)),
                  const SizedBox(height: 12),

                  // Tab Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(
                          label: 'Set Stok',
                          icon: Icons.add_box_rounded,
                          tabKey: 'add',
                          activeColor: const Color(0xFF10B981),
                          activeBg: const Color(0xFFD1FAE5),
                        ),
                        _buildTabButton(
                          label: 'Catat Penjualan',
                          icon: Icons.sell_rounded,
                          tabKey: 'sell',
                          activeColor: const Color(0xFFF97316),
                          activeBg: const Color(0xFFFFEDD5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Active Panel
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                    child: _activeTab == 'add'
                        ? _buildAddPanel()
                        : _buildSellPanel(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE6EEFF), width: 1.5)),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, _hasChanges),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    side: const BorderSide(color: Color(0xFFC0C7D1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: const Color(0xFF40474F),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitMainForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF006398),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF006398).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // Helper Widgets
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF40474F),
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0B1C30),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF66ACE6)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD9E3F6), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD9E3F6), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF66ACE6), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHargaInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'Harga Satuan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF40474F),
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextFormField(
          controller: _harga,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006398),
          ),
          onChanged: (val) {
            final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
            if (digits.isEmpty) {
              _harga.value = const TextEditingValue(text: '');
              return;
            }
            final formatted = _formatCurrencyDisplay(int.parse(digits));
            _harga.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.payments_outlined, size: 18, color: Color(0xFF66ACE6)),
            prefixText: 'Rp ',
            prefixStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006398),
            ),
            filled: true,
            fillColor: const Color(0xFFE6EEFF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF66ACE6), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF66ACE6), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF006398), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required String tabKey,
    required Color activeColor,
    required Color activeBg,
  }) {
    final isActive = _activeTab == tabKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = tabKey),
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: isActive
                ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 17,
                  color: isActive ? activeColor : const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? activeColor : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPanel() {
    int val = int.tryParse(_stokAdd.text) ?? 0;
    int target = _currentBarang.jumlah + val;
    return Container(
      key: const ValueKey('add'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              _buildStokBadge('Saat ini: ${_currentBarang.jumlah}', const Color(0xFF10B981).withValues(alpha: 0.1), const Color(0xFF059669)),
              const Spacer(),
              if (val != 0)
                _buildStokBadge(
                  val > 0 ? '+$val → $target Unit' : '$val → $target Unit',
                  val > 0
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2),
                  val > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Counter
          Row(
            children: [
              _buildCounterBtn(
                icon: Icons.remove,
                color: const Color(0xFF10B981),
                onTap: () => _updateStokAdd(-1),
                filled: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: TextFormField(
                    controller: _stokAdd,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildCounterBtn(
                icon: Icons.add,
                color: const Color(0xFF10B981),
                onTap: () => _updateStokAdd(1),
                filled: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '💡 Angka positif = tambah stok · Angka negatif = kurangi stok (tidak tercatat penjualan)',
            style: TextStyle(fontSize: 11, color: Color(0xFF059669), height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submitStok,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan Stok',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellPanel() {
    int val = int.tryParse(_stokSell.text) ?? 0;
    int target = _currentBarang.jumlah - val;
    return Container(
      key: const ValueKey('sell'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStokBadge('Stok: ${_currentBarang.jumlah}', const Color(0xFFF97316).withValues(alpha: 0.1), const Color(0xFFF97316)),
              const Spacer(),
              if (val > 0)
                _buildStokBadge('Sisa: $target Unit',
                    target < 5 ? const Color(0xFFFEE2E2) : const Color(0xFFFFEDD5),
                    target < 5 ? const Color(0xFFDC2626) : const Color(0xFFF97316)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCounterBtn(
                icon: Icons.remove,
                color: const Color(0xFFF97316),
                onTap: () => _updateStokSell(-1),
                filled: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFF97316).withValues(alpha: 0.4)),
                  ),
                  child: TextFormField(
                    controller: _stokSell,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) {
                      int? parsed = int.tryParse(v);
                      if (parsed != null && parsed > _currentBarang.jumlah) {
                        _stokSell.text = _currentBarang.jumlah.toString();
                      }
                      setState(() {});
                    },
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF97316),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: Color(0xFFF97316)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildCounterBtn(
                icon: Icons.add,
                color: const Color(0xFFF97316),
                onTap: () => _updateStokSell(1),
                filled: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submitPenjualan,
              icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
              label: const Text('Konfirmasi Penjualan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shadowColor: const Color(0xFFF97316).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: filled ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon,
            color: filled ? Colors.white : color, size: 22),
      ),
    );
  }

  Widget _buildStokBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
