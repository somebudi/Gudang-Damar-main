<?php

namespace App\Http\Controllers\MobileApi;

use App\Http\Controllers\Controller;
use App\Models\Aktivitas;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AktivitasMobileApiController extends Controller
{
    /**
     * GET /mobile-api/riwayat
     * Mengembalikan data gabungan riwayat aktivitas dalam bentuk JSON murni.
     */
    public function index(Request $request): JsonResponse
    {
        // 1. Ambil filter dari query string aplikasi Flutter
        $filters = [
            'search'     => $request->input('search'),
            'jenis'      => $request->input('jenis'),      // all | pesanan | barang | servis
            'status'     => $request->input('status'),     // all | Dipesan | Dibeli | Diproses | Selesai
            'start_date' => $request->input('start_date'),
            'end_date'   => $request->input('end_date'),
        ];

        // 2. Ambil semua data dari model gabungan Aktivitas
        $aktivitas = Aktivitas::all($filters);

        // 3. Filter berdasarkan jenis (Pesanan / Barang / Servis)
        if (!empty($filters['jenis']) && $filters['jenis'] !== 'all') {
            $jenisMap = [
                'pesanan' => 'Pesanan',
                'barang'  => 'Barang',
                'servis'  => 'Servis',
            ];
            $jenis = $jenisMap[$filters['jenis']] ?? null;
            if ($jenis) {
                $aktivitas = $aktivitas->where('jenis', $jenis)->values();
            }
        }

        // 4. Filter berdasarkan status transaksi
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $aktivitas = $aktivitas->where('status', $filters['status'])->values();
        }

        // 5. Pagination manual untuk data Collection
        $perPage     = 10;
        $currentPage = (int) $request->input('page', 1);
        $total       = $aktivitas->count();
        $lastPage    = max(1, (int) ceil($total / $perPage));
        $paginated   = $aktivitas->forPage($currentPage, $perPage)->values();

        // 6. Kembalikan data JSON murni
        return response()->json([
            'transactions' => [
                'data'         => $paginated,
                'current_page' => $currentPage,
                'last_page'    => $lastPage,
                'total'        => $total,
                'per_page'     => $perPage,
            ],
            'stats' => Aktivitas::stats(),
        ]);
    }

    /**
     * GET /mobile-api/riwayat/export
     * Meng-generate dan mengirimkan data riwayat dalam format CSV.
     */
    public function export(Request $request)
    {
        // 1. Ambil filter yang sama seperti method index
        $filters = [
            'search'     => $request->input('search'),
            'jenis'      => $request->input('jenis'),
            'status'     => $request->input('status'),
            'start_date' => $request->input('start_date'),
            'end_date'   => $request->input('end_date'),
        ];

        // 2. Ambil semua data (tanpa pagination karena ini export)
        $aktivitas = Aktivitas::all($filters);

        // Filter Jenis
        if (!empty($filters['jenis']) && $filters['jenis'] !== 'all') {
            $jenisMap = ['pesanan' => 'Pesanan', 'barang' => 'Barang', 'servis' => 'Servis'];
            $jenis = $jenisMap[$filters['jenis']] ?? null;
            if ($jenis) {
                $aktivitas = $aktivitas->where('jenis', $jenis)->values();
            }
        }

        // Filter Status
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $aktivitas = $aktivitas->where('status', $filters['status'])->values();
        }

        // 3. Siapkan header untuk response CSV
        $filename = "Export_GudangDamar_" . date('Ymd_His') . ".csv";
        $headers = [
            "Content-type"        => "text/csv",
            "Content-Disposition" => "attachment; filename=$filename",
            "Pragma"              => "no-cache",
            "Cache-Control"       => "must-revalidate, post-check=0, pre-check=0",
            "Expires"             => "0"
        ];

        // 4. Buat file CSV di memory (stream)
        $callback = function() use($aktivitas) {
            $file = fopen('php://output', 'w');
            
            // Tulis Header Kolom CSV
            fputcsv($file, ['Tanggal', 'Jenis', 'Nama Barang', 'Jumlah', 'Total Harga', 'Status', 'Catatan']);

            // Tulis baris data
            foreach ($aktivitas as $item) {
                fputcsv($file, [
                    $item['tanggal_transaksi'] ?? '-',
                    $item['jenis'] ?? '-',
                    $item['nama_barang'] ?? '-',
                    $item['jumlah'] ?? '0',
                    $item['total_harga'] ?? $item['harga_satuan'] ?? '0',
                    $item['status'] ?? '-',
                    $item['catatan'] ?? '-'
                ]);
            }
            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}