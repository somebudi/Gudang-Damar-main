<?php

namespace App\Http\Controllers\MobileApi;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PesananMobileApiController extends Controller
{
    public function index(Request $request)
    {
        $pesanan = Pesanan::orderBy('id_pesanan', 'desc')->get();
        return response()->json([
            'message' => 'Success',
            'data' => $pesanan
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_barang' => 'required|string',
            'bahan'       => 'required|string',
            'jumlah'      => 'required|integer|min:1',
            'bentuk'      => 'nullable|string',
            'ukuran'      => 'nullable|numeric',
            'ketebalan'   => 'nullable|numeric',
            'harga'       => 'nullable|integer',
            'catatan'     => 'nullable|string',
        ]);

        $idBaru = (Pesanan::max('id_pesanan') ?? 0) + 1;

        $pesanan = Pesanan::create([
            'id_pesanan'       => $idBaru,
            'id_user'          => 1, // Fix: Always use 1 (admin in login table) because API users are from users table
            'id_barang'        => null, // Optional custom item
            'nama_barang'      => $data['nama_barang'],
            'bahan'            => $data['bahan'],
            'jumlah'           => $data['jumlah'],
            'bentuk'           => $data['bentuk'] ?? '',
            'ukuran'           => $data['ukuran'] ?? 0,
            'ketebalan'        => $data['ketebalan'] ?? 0,
            'harga'            => $data['harga'] ?? 0,
            'catatan'          => $data['catatan'] ?? '',
            'tanggalpemesanan' => Carbon::now(),
            'tanggalterkirim'  => null,
            'pendapatan'       => 0,
        ]);

        return response()->json([
            'message' => 'Pesanan berhasil dibuat',
            'data' => $pesanan
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $pesanan = Pesanan::where('id_pesanan', $id)->first();
        if (!$pesanan) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        // Logic for marking as "Selesai"
        if ($request->has('selesai') && $request->selesai) {
            $pesanan->tanggalterkirim = Carbon::now();
            $pesanan->pendapatan = $pesanan->harga; // Transfer harga ke pendapatan jika selesai
            $pesanan->save();

            return response()->json([
                'message' => 'Pesanan berhasil ditandai selesai',
                'data' => $pesanan
            ]);
        }

        // General update
        $data = $request->validate([
            'nama_barang' => 'sometimes|required|string',
            'bahan'       => 'sometimes|required|string',
            'jumlah'      => 'sometimes|required|integer|min:1',
            'bentuk'      => 'nullable|string',
            'ukuran'      => 'nullable|numeric',
            'ketebalan'   => 'nullable|numeric',
            'harga'       => 'nullable|integer',
            'catatan'     => 'nullable|string',
        ]);

        $pesanan->update($data);

        return response()->json([
            'message' => 'Pesanan berhasil diperbarui',
            'data' => $pesanan
        ]);
    }

    public function destroy($id)
    {
        $pesanan = Pesanan::where('id_pesanan', $id)->first();
        if (!$pesanan) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        try {
            \App\Models\Servis::where('id_pesanan', $id)->delete();
        } catch (\Exception $e) {
            // Ignore if it fails to delete servis
        }

        $pesanan->delete();

        return response()->json([
            'message' => 'Pesanan berhasil dihapus'
        ]);
    }
}
