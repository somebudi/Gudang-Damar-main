<?php

namespace App\Http\Controllers\MobileApi;

use App\Http\Controllers\Controller;
use App\Models\Servis;
use App\Models\Pesanan;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ServisMobileApiController extends Controller
{
    public function index(Request $request)
    {
        $servis = Servis::orderBy('id_pesanan', 'desc')->get();
        return response()->json([
            'message' => 'Success',
            'data' => $servis
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_barang'   => 'required|string',
            'bahan'         => 'required|string',
            'jumlah'        => 'required|integer|min:1',
            'bentuk_barang' => 'nullable|string',
            'harga'         => 'nullable|integer',
            'catatan'       => 'nullable|string',
        ]);

        $data['jumlah']        = $data['jumlah'] ?? 1;
        $data['bentuk_barang'] = (isset($data['bentuk_barang']) && $data['bentuk_barang'] !== '') ? $data['bentuk_barang'] : 0;
        $data['harga']         = (isset($data['harga']) && $data['harga'] !== '') ? $data['harga'] : 0;
        $data['catatan']       = $data['catatan'] ?? '';

        $servis = null;

        DB::transaction(function () use ($data, &$servis) {
            $idBaru = (Pesanan::max('id_pesanan') ?? 0) + 1;

            $pesanan = Pesanan::create([
                'id_pesanan'       => $idBaru,
                'id_user'          => 1,
                'id_barang'        => null,
                'nama_barang'      => $data['nama_barang'],
                'bahan'            => $data['bahan'],
                'jumlah'           => $data['jumlah'],
                'bentuk'           => '',
                'ukuran'           => 0,
                'ketebalan'        => 0,
                'harga'            => $data['harga'],
                'catatan'          => $data['catatan'],
                'tanggalpemesanan' => Carbon::now(),
                'tanggalterkirim'  => null,
                'pendapatan'       => 0,
            ]);

            $servis = Servis::create([
                'id_pesanan'       => $pesanan->id_pesanan,
                'nama_barang'      => $data['nama_barang'],
                'bahan'            => $data['bahan'],
                'jumlah'           => $data['jumlah'],
                'bentuk_barang'    => $data['bentuk_barang'],
                'harga'            => $data['harga'],
                'catatan'          => $data['catatan'],
                'tanggalpemesanan' => Carbon::now(),
                'tanggalterkirim'  => '1970-01-01 00:00:00',
                'pendapatan'       => 0,
            ]);
        });

        return response()->json([
            'message' => 'Servis berhasil dibuat',
            'data' => $servis
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $servis = Servis::where('id_pesanan', $id)->first();
        if (!$servis) {
            return response()->json(['message' => 'Servis tidak ditemukan'], 404);
        }

        // Logic for marking as "Selesai"
        if ($request->has('selesai') && $request->selesai) {
            if (!$servis->harga || $servis->harga <= 0) {
                return response()->json(['message' => 'Harga servis harus diisi terlebih dahulu!'], 400);
            }

            $pendapatan = $servis->harga * ($servis->jumlah ?? 1);

            $servis->update([
                'tanggalterkirim' => Carbon::now(),
                'pendapatan'      => $pendapatan,
            ]);

            return response()->json([
                'message' => 'Servis berhasil ditandai selesai',
                'data' => $servis
            ]);
        }

        // General update
        $data = $request->validate([
            'nama_barang'   => 'sometimes|required|string',
            'bahan'         => 'sometimes|required|string',
            'jumlah'        => 'sometimes|required|integer|min:1',
            'bentuk_barang' => 'nullable|string',
            'harga'         => 'nullable|integer',
            'catatan'       => 'nullable|string',
        ]);

        if (array_key_exists('bentuk_barang', $data) && empty($data['bentuk_barang'])) {
            $data['bentuk_barang'] = 0;
        }
        if (array_key_exists('catatan', $data) && empty($data['catatan'])) {
            $data['catatan'] = '';
        }
        if (array_key_exists('harga', $data) && empty($data['harga'])) {
            $data['harga'] = 0;
        }

        $servis->update($data);

        return response()->json([
            'message' => 'Servis berhasil diperbarui',
            'data' => $servis
        ]);
    }

    public function destroy($id)
    {
        $servis = Servis::where('id_pesanan', $id)->first();
        if (!$servis) {
            return response()->json(['message' => 'Servis tidak ditemukan'], 404);
        }

        $servis->delete();

        return response()->json([
            'message' => 'Servis berhasil dihapus'
        ]);
    }
}
