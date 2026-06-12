<?php

namespace App\Http\Controllers\MobileApi;

use App\Http\Controllers\Controller;
use App\Models\Barang;
use App\Models\AktivitasBarang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BarangMobileApiController extends Controller
{
    public function index(Request $request)
    {
        $query = Barang::query();
        if ($request->filled('search')) {
            $query->where('nama', 'like', '%' . $request->search . '%')
                  ->orWhere('guna_merek', 'like', '%' . $request->search . '%');
        }
        $barang = $query->orderBy('nama')->get();
        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Success',
            'data' => $barang
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'               => 'required|string',
            'harga.harga'        => 'required|integer|min:0',
            'harga.jumlah'       => 'required|integer|min:1',
            'kategori.ukuran'    => 'required|integer|min:0',
            'kategori.ketebalan' => 'required|string',
            'kategori.bahan'     => 'required|string',
            'kategori.bentuk'    => 'required|string',
            'kategori.merek'     => 'required|string',
        ]);

        $idBaru = (Barang::max('id_barang') ?? 0) + 1;
        $harga  = $data['harga']['harga'];
        $jumlah = $data['harga']['jumlah'];

        DB::transaction(function () use ($data, $idBaru, $harga, $jumlah) {
            Barang::create([
                'id_barang'      => $idBaru,
                'nama'           => $data['nama'],
                'harga'          => $harga,
                'jumlah'         => $jumlah,
                'total'          => $harga * $jumlah,
                'ukuran'         => $data['kategori']['ukuran'],
                'bentuk'         => $data['kategori']['bentuk'],
                'ketebalan'      => $data['kategori']['ketebalan'],
                'bahan'          => $data['kategori']['bahan'],
                'guna_merek'     => $data['kategori']['merek'],
                'tanggal_restok' => \Carbon\Carbon::now(),
                'pendapatan'     => 0,
                'jumlah_terjual' => 0,
            ]);

            AktivitasBarang::create([
                'id_barang'    => $idBaru,
                'nama_barang'  => $data['nama'],
                'jenis'        => 'ubah_stok',
                'jumlah'       => $jumlah,
                'stok_sebelum' => 0,
                'stok_sesudah' => $jumlah,
                'harga_satuan' => $harga,
                'pendapatan'   => 0,
                'catatan'      => "Barang baru ditambahkan dengan stok awal {$jumlah} unit",
                'tanggal'      => \Carbon\Carbon::now(),
            ]);
        });

        $barang = Barang::find($idBaru);
        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Barang berhasil ditambahkan',
            'data'    => $barang
        ], 201);
    }

    public function show(string $id)
    {
        $barang = Barang::findOrFail($id);
        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Success',
            'data' => $barang
        ]);
    }

    public function update(Request $request, string $id)
    {
        $barang = Barang::findOrFail($id);
        
        $request->validate([
            'nama'               => 'required|string',
            'harga.harga'        => 'required|integer|min:0',
            'harga.jumlah'       => 'required|integer|min:0',
            'kategori.ukuran'    => 'required|integer|min:0',
            'kategori.ketebalan' => 'required|string',
            'kategori.bahan'     => 'required|string',
            'kategori.bentuk'    => 'required|string',
            'kategori.merek'     => 'required|string',
        ]);

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

            if ($jumlahBaru !== $jumlahLama) {
                $updateData['tanggal_restok'] = \Carbon\Carbon::now();
            }

            $barang->update($updateData);

            if ($jumlahBaru !== $jumlahLama) {
                AktivitasBarang::create([
                    'id_barang'    => $barang->id_barang,
                    'nama_barang'  => $barang->nama,
                    'jenis'        => 'ubah_stok',
                    'jumlah'       => $jumlahBaru,                 
                    'stok_sebelum' => $jumlahLama,
                    'stok_sesudah' => $jumlahBaru,
                    'harga_satuan' => $request->input('harga.harga'),
                    'pendapatan'   => 0,
                    'catatan'      => "Stok diubah dari {$jumlahLama} menjadi {$jumlahBaru} unit",
                    'tanggal'      => \Carbon\Carbon::now(),
                ]);
            }
        });

        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Barang berhasil diupdate',
            'data'    => $barang->fresh()
        ]);
    }

    public function updateStok(Request $request, string $id)
    {
        $barang = Barang::findOrFail($id);
        $request->validate(['jumlah' => 'required|integer']);

        $jumlahBaru = (int) $request->jumlah;
        $jumlahLama = $barang->jumlah;

        if ($jumlahBaru == $jumlahLama) {
            return \Illuminate\Support\Facades\Response::json([
                'message' => 'Stok tidak berubah',
                'data'    => $barang
            ]);
        }

        DB::transaction(function () use ($barang, $jumlahBaru, $jumlahLama) {
            $barang->update([
                'jumlah' => $jumlahBaru,
                'total'  => $barang->harga * $jumlahBaru,
                'tanggal_restok' => \Carbon\Carbon::now(),
            ]);

            AktivitasBarang::create([
                'id_barang'    => $barang->id_barang,
                'nama_barang'  => $barang->nama,
                'jenis'        => 'ubah_stok',
                'jumlah'       => abs($jumlahBaru - $jumlahLama),                 
                'stok_sebelum' => $jumlahLama,
                'stok_sesudah' => $jumlahBaru,
                'harga_satuan' => $barang->harga,
                'pendapatan'   => 0,
                'catatan'      => "Set stok manual dari {$jumlahLama} menjadi {$jumlahBaru}",
                'tanggal'      => \Carbon\Carbon::now(),
            ]);
        });

        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Stok berhasil diperbarui',
            'data'    => $barang->fresh()
        ]);
    }

    public function catatPenjualan(Request $request, string $id)
    {
        $barang = Barang::findOrFail($id);
        $request->validate(['jumlah_terjual' => 'required|integer|min:1']);

        $jumlahTerjual = (int) $request->jumlah_terjual;

        if ($jumlahTerjual > $barang->jumlah) {
            return \Illuminate\Support\Facades\Response::json([
                'message' => 'Stok tidak mencukupi'
            ], 400);
        }

        $jumlahLama = $barang->jumlah;
        $jumlahBaru = $jumlahLama - $jumlahTerjual;
        $pendapatan = $jumlahTerjual * $barang->harga;

        DB::transaction(function () use ($barang, $jumlahTerjual, $jumlahBaru, $jumlahLama, $pendapatan) {
            $barang->update([
                'jumlah'         => $jumlahBaru,
                'total'          => $barang->harga * $jumlahBaru,
                'jumlah_terjual' => $barang->jumlah_terjual + $jumlahTerjual,
                'pendapatan'     => $barang->pendapatan + $pendapatan,
            ]);

            AktivitasBarang::create([
                'id_barang'    => $barang->id_barang,
                'nama_barang'  => $barang->nama,
                'jenis'        => 'barang_keluar',
                'jumlah'       => $jumlahTerjual,                 
                'stok_sebelum' => $jumlahLama,
                'stok_sesudah' => $jumlahBaru,
                'harga_satuan' => $barang->harga,
                'pendapatan'   => $pendapatan,
                'catatan'      => "Pencatatan penjualan sebanyak {$jumlahTerjual} unit",
                'tanggal'      => \Carbon\Carbon::now(),
            ]);
        });

        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Penjualan berhasil dicatat',
            'data'    => $barang->fresh()
        ]);
    }
    public function destroy(string $id)
    {
        $barang = Barang::findOrFail($id);
        $barang->delete();
        return \Illuminate\Support\Facades\Response::json([
            'message' => 'Barang berhasil dihapus'
        ]);
    }
}
