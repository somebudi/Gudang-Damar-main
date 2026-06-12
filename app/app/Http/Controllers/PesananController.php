<?php

namespace App\Http\Controllers;

use App\Models\Pesanan;
use App\Models\Servis;
use Illuminate\Http\Request;
use Inertia\Inertia;

class PesananController extends Controller
{
    public function index()
    {
        return Inertia::render('pesanan/Index', [
            'pesananList' => Pesanan::orderBy('tanggalpemesanan', 'desc')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_barang' => 'required|string|max:255',
            'bahan'       => 'required|string|max:255',
            'jumlah'      => 'required|integer|min:1',
            'catatan'     => 'nullable|string|max:500',
            'bentuk'      => 'nullable|string|max:255',   // ✨ varchar
            'ukuran'      => 'nullable|numeric|min:0',    // ✨ float
            'ketebalan'   => 'nullable|numeric|min:0',    // ✨ float
            'harga'       => 'nullable|integer|min:0',    // ✨ harga
        ]);

        $data['tanggalpemesanan'] = now();
        $data['tanggalterkirim']  = null;
        $data['id_pesanan']       = (Pesanan::max('id_pesanan') ?? 0) + 1;

        Pesanan::create($data);

        return redirect()->route('pesanan.index')->with('success', 'Pesanan berhasil ditambahkan!');
    }

    public function update(Request $request, $id)
    {
        $pesanan = Pesanan::findOrFail($id);

        $data = $request->validate([
            'nama_barang' => 'required|string|max:255',
            'bahan'       => 'required|string|max:255',
            'jumlah'      => 'required|integer|min:1',
            'catatan'     => 'nullable|string|max:500',
            'bentuk'      => 'nullable|string|max:255',   // ✨ varchar
            'ukuran'      => 'nullable|numeric|min:0',    // ✨ float
            'ketebalan'   => 'nullable|numeric|min:0',    // ✨ float
            'harga'       => 'nullable|integer|min:0',    // ✨ harga
        ]);

        if ($request->is_terkirim && !$pesanan->tanggalterkirim) {
            $data['tanggalterkirim'] = now();
        }

        $pesanan->update($data);
        return redirect()->route('pesanan.index')->with('success', 'Pesanan berhasil diperbarui!');
    }

    public function destroy($id)
    {
        $pesanan = Pesanan::findOrFail($id);

        // CEK RELASI: Jangan hapus jika ada data di tabel servis
        $adaServis = Servis::where('id_pesanan', $pesanan->id_pesanan)->exists();

        if ($adaServis) {
            return redirect()->route('pesanan.index')
                ->with('error', 'Gagal hapus! Masih ada data servis yang terhubung ke pesanan ini.');
        }

        $pesanan->delete();
        return redirect()->route('pesanan.index')->with('success', 'Pesanan berhasil dihapus!');
    }

    public function selesai($id)
    {
        $pesanan = Pesanan::findOrFail($id);

        // Validasi harga wajib diisi
        if (!$pesanan->harga || $pesanan->harga <= 0) {
            return redirect()->route('pesanan.index')
                ->with('error', 'Harga pesanan harus diisi terlebih dahulu!');
        }

        if (!$pesanan->tanggalterkirim) {
            // Hitung pendapatan = harga × jumlah (snapshot saat selesai)
            $pendapatan = $pesanan->harga * $pesanan->jumlah;

            $pesanan->update([
                'tanggalterkirim' => now(),
                'pendapatan'      => $pendapatan,
            ]);
        }

        return redirect()->route('pesanan.index')
            ->with('success', 'Pesanan selesai! Pendapatan Rp ' . number_format($pesanan->pendapatan, 0, ',', '.') . ' tercatat.');
    }

    public function edit($id)
    {
        $pesanan = Pesanan::findOrFail($id);

        // Kirim data ke halaman Edit di Vue
        return Inertia::render('pesanan/Edit', [
            'pesanan' => $pesanan
        ]);
    }
}