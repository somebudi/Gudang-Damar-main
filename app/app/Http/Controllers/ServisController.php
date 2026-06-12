<?php
// app/Http/Controllers/ServisController.php

namespace App\Http\Controllers;

use App\Models\Servis;
use App\Models\Pesanan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class ServisController extends Controller
{
    public function index()
    {
        $servis = Servis::orderBy('tanggalpemesanan', 'desc')->get();

        return Inertia::render('servis/Index', [
            'servisList' => $servis,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_barang'   => 'required|string|max:255',
            'bahan'         => 'required|string|max:255',
            'jumlah'        => 'nullable|integer|min:1',
            'bentuk_barang' => 'nullable|integer|min:1',
            'catatan'       => 'required|string|max:1000',
            'harga'         => 'nullable|integer|min:0',   // ✨ harga
        ], [
            'nama_barang.required' => 'Nama barang harus diisi.',
            'bahan.required'       => 'Bahan harus diisi.',
            'catatan.required'     => 'Catatan servis wajib diisi.',
            'catatan.max'          => 'Catatan maksimal 1000 karakter.',
        ]);

        // Default values
        $validated['jumlah']        = $validated['jumlah']        ?? 1;
        $validated['bentuk_barang'] = $validated['bentuk_barang'] ?? 0;
        $validated['harga']         = $validated['harga']         ?? 0;

        // Tanggal pemesanan = sekarang
        $validated['tanggalpemesanan'] = now();

        // ✨ tanggalterkirim diisi dengan sentinel date (1970-01-01)
        // untuk menandai "belum selesai" karena kolom NOT NULL
        $validated['tanggalterkirim'] = '1970-01-01 00:00:00';

        // ✨ FIX FK: id_pesanan di tabel servis ber-foreign key ke tabel pesanan.
        // Jadi sebelum insert servis, kita buat dulu baris induk di pesanan,
        // lalu pakai id_pesanan-nya. Dibungkus transaction biar atomik.
        DB::transaction(function () use ($validated) {
            // 1. Buat induk pesanan dulu agar FK ter-satisfy
            $pesanan = Pesanan::create([
                'nama_barang'      => $validated['nama_barang'],
                'bahan'            => $validated['bahan'],
                'jumlah'           => $validated['jumlah'],
                'catatan'          => $validated['catatan'],
                'tanggalpemesanan' => now(),
                'tanggalterkirim'  => null,
            ]);

            // 2. Pakai id_pesanan yang baru dibuat untuk servis.
            //    Karena di-set manual, hook booted() di model Servis
            //    tidak menjalankan MAX() lagi (hanya jalan kalau empty).
            $validated['id_pesanan'] = $pesanan->id_pesanan;

            Servis::create($validated);
        });

        return redirect()->route('servis.index')
            ->with('success', 'Data servis berhasil ditambahkan.');
    }

    public function update(Request $request, $id)
    {
        $servis = Servis::findOrFail($id);

        $validated = $request->validate([
            'nama_barang'   => 'required|string|max:255',
            'bahan'         => 'required|string|max:255',
            'jumlah'        => 'nullable|integer|min:1',
            'bentuk_barang' => 'nullable|integer|min:1',
            'catatan'       => 'required|string|max:1000',
            'harga'         => 'nullable|integer|min:0',   // ✨ harga
        ]);

        $validated['jumlah']        = $validated['jumlah']        ?? 1;
        $validated['bentuk_barang'] = $validated['bentuk_barang'] ?? 0;
        $validated['harga']         = $validated['harga']         ?? 0;

        $servis->update($validated);

        return redirect()->route('servis.index')
            ->with('success', 'Data servis berhasil diperbarui.');
    }

    public function selesai($id)
    {
        $servis = Servis::findOrFail($id);

        if (!$servis->harga || $servis->harga <= 0) {
            return redirect()->route('servis.index')
                ->with('error', 'Harga servis harus diisi terlebih dahulu!');
        }

        $pendapatan = $servis->harga * ($servis->jumlah ?? 1);

        $servis->update([
            'tanggalterkirim' => now(),
            'pendapatan'      => $pendapatan,
        ]);

        return redirect()->route('servis.index')
            ->with('success', 'Servis selesai! Pendapatan Rp ' . number_format($servis->pendapatan, 0, ',', '.') . ' tercatat.');
    }

    public function destroy($id)
    {
        $servis = Servis::findOrFail($id);

        $servis->delete();

        return redirect()->route('servis.index')
            ->with('success', 'Data servis berhasil dihapus!');
    }
}