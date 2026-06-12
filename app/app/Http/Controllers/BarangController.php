<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use App\Models\AktivitasBarang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class BarangController extends Controller
{
    public function index()
    {
        return Inertia::render('barang/Index', [
            'barangList' => Barang::all(),
        ]);
    }

    public function create()
    {
        return Inertia::render('barang/Create');
    }

    public function store(Request $request)
    {
        $data = $this->validateData($request, true);
        $idBaru = Barang::max('id_barang') + 1;
        Barang::create($this->mapData($data, $idBaru));

        return redirect()->route('barang.index')->with('success', 'Barang berhasil ditambahkan!');
    }

    public function show(string $id)
    {
        return Inertia::render('barang/Detail', ['barang' => Barang::findOrFail($id)]);
    }

    public function edit(string $id)
    {
        return Inertia::render('barang/Edit', ['barang' => Barang::findOrFail($id)]);
    }

    /**
     * Update barang. Jika stok berubah → catat log 'ubah_stok'.
     */
    public function update(Request $request, string $id)
    {
        $barang     = Barang::findOrFail($id);
        $jumlahBaru = (int) $request->input('harga.jumlah');
        $jumlahLama = $barang->jumlah;

        DB::transaction(function () use ($barang, $request, $jumlahBaru, $jumlahLama) {
            $updateData = [
                'nama'       => $request->nama,
                'harga'      => $request->input('harga.harga'),
                'jumlah'     => $jumlahBaru,
                'total'      => $request->input('harga.harga') * $jumlahBaru,
                'ukuran'     => $request->input('kategori.ukuran'),
                'bentuk'     => $request->input('kategori.bentuk'),
                'ketebalan'  => $request->input('kategori.ketebalan'),
                'bahan'      => $request->input('kategori.bahan'),
                'guna_merek' => $request->input('kategori.merek'),
            ];

            // Kalau stok berubah → update tanggal_restok & catat log
            if ($jumlahBaru !== $jumlahLama) {
                $updateData['tanggal_restok'] = now();
            }

            $barang->update($updateData);

            // ✨ Catat log HANYA kalau stok berubah
            if ($jumlahBaru !== $jumlahLama) {
                AktivitasBarang::create([
                    'id_barang'    => $barang->id_barang,
                    'nama_barang'  => $barang->nama,
                    'jenis'        => 'ubah_stok',
                    'jumlah'       => $jumlahBaru,                 // stok setelah diubah
                    'stok_sebelum' => $jumlahLama,
                    'stok_sesudah' => $jumlahBaru,
                    'harga_satuan' => $request->input('harga.harga'),
                    'pendapatan'   => 0,
                    'catatan'      => "Stok diubah dari {$jumlahLama} menjadi {$jumlahBaru} unit",
                    'tanggal'      => now(),
                ]);
            }
        });

        return redirect()->route('barang.index')
                         ->with('success', 'Barang berhasil diupdate!');
    }

    /**
     * ✨ Jual barang → kurangi stok + catat log 'jual' + tambah pendapatan akumulasi.
     */
    public function jual(Request $request, string $id)
    {
        $data = $request->validate([
            'jumlah'     => 'required|integer|min:1',
            'harga_jual' => 'nullable|integer|min:0',
        ]);

        $barang = Barang::findOrFail($id);

        if ($barang->jumlah < $data['jumlah']) {
            return redirect()->back()
                ->with('error', "Stok tidak cukup! Stok tersedia: {$barang->jumlah}");
        }

        DB::transaction(function () use ($barang, $data) {
            $hargaJual      = $data['harga_jual'] ?? $barang->harga;
            $pendapatanAksi = $hargaJual * $data['jumlah'];
            $stokSebelum    = $barang->jumlah;
            $stokSesudah    = $stokSebelum - $data['jumlah'];

            // Update barang (stok turun + pendapatan akumulasi)
            $barang->update([
                'jumlah'                => $stokSesudah,
                'total'                 => $stokSesudah * $barang->harga,
                'jumlah_terjual'        => $data['jumlah'],                        // aksi terakhir
                'pendapatan'            => ($barang->pendapatan ?? 0) + $pendapatanAksi,
                'tanggal_terakhir_jual' => now(),
            ]);

            // ✨ Catat log jual
            AktivitasBarang::create([
                'id_barang'    => $barang->id_barang,
                'nama_barang'  => $barang->nama,
                'jenis'        => 'jual',
                'jumlah'       => $data['jumlah'],
                'stok_sebelum' => $stokSebelum,
                'stok_sesudah' => $stokSesudah,
                'harga_satuan' => $hargaJual,
                'pendapatan'   => $pendapatanAksi,
                'catatan'      => "Terjual {$data['jumlah']} unit @ Rp " . number_format($hargaJual, 0, ',', '.'),
                'tanggal'      => now(),
            ]);
        });

        return redirect()->route('barang.index')
            ->with('success', "Penjualan {$data['jumlah']} unit {$barang->nama} berhasil dicatat!");
    }

    /**
     * Restok tambah stok saja — dihitung sebagai 'ubah_stok'.
     */
    public function restok(Request $request, string $id)
    {
        $data = $request->validate([
            'jumlah' => 'required|integer|min:1',
        ]);

        $barang = Barang::findOrFail($id);

        DB::transaction(function () use ($barang, $data) {
            $stokSebelum = $barang->jumlah;
            $stokSesudah = $stokSebelum + $data['jumlah'];

            $barang->update([
                'jumlah'         => $stokSesudah,
                'total'          => $stokSesudah * $barang->harga,
                'tanggal_restok' => now(),
            ]);

            AktivitasBarang::create([
                'id_barang'    => $barang->id_barang,
                'nama_barang'  => $barang->nama,
                'jenis'        => 'ubah_stok',
                'jumlah'       => $stokSesudah,
                'stok_sebelum' => $stokSebelum,
                'stok_sesudah' => $stokSesudah,
                'harga_satuan' => $barang->harga,
                'pendapatan'   => 0,
                'catatan'      => "Restok +{$data['jumlah']} unit (total jadi {$stokSesudah})",
                'tanggal'      => now(),
            ]);
        });

        return redirect()->route('barang.index')
            ->with('success', "Stok {$barang->nama} ditambah {$data['jumlah']} unit!");
    }

    public function destroy(string $id)
    {
        Barang::findOrFail($id)->delete();
        return redirect()->route('barang.index')->with('success', 'Barang berhasil dihapus!');
    }

    private function validateData(Request $request, bool $isStore): array
    {
        $rules = [
            'nama'               => 'required|string',
            'harga.harga'        => 'required|integer|min:0',
            'kategori.ukuran'    => 'required|integer|min:0',
            'kategori.ketebalan' => 'required|string',
            'kategori.bahan'     => 'required|string',
        ];

        if ($isStore) {
            $rules += [
                'harga.jumlah'    => 'required|integer|min:1',
                'kategori.bentuk' => 'required|string',
                'kategori.merek'  => 'required|string',
            ];
        }

        return $request->validate($rules);
    }

    private function mapData(array $data, int $id): array
    {
        $harga  = $data['harga']['harga'];
        $jumlah = $data['harga']['jumlah'];

        // Log aktivitas untuk barang baru (stok awal)
        AktivitasBarang::create([
            'id_barang'    => $id,
            'nama_barang'  => $data['nama'],
            'jenis'        => 'ubah_stok',
            'jumlah'       => $jumlah,
            'stok_sebelum' => 0,
            'stok_sesudah' => $jumlah,
            'harga_satuan' => $harga,
            'pendapatan'   => 0,
            'catatan'      => "Barang baru ditambahkan dengan stok awal {$jumlah} unit",
            'tanggal'      => now(),
        ]);

        return [
            'id_barang'      => $id,
            'nama'           => $data['nama'],
            'harga'          => $harga,
            'jumlah'         => $jumlah,
            'total'          => $harga * $jumlah,
            'ukuran'         => $data['kategori']['ukuran'],
            'bentuk'         => $data['kategori']['bentuk'],
            'ketebalan'      => $data['kategori']['ketebalan'],
            'bahan'          => $data['kategori']['bahan'],
            'guna_merek'     => $data['kategori']['merek'],
            'tanggal_restok' => now(),
            'pendapatan'     => 0,
            'jumlah_terjual' => 0,
        ];
    }
}