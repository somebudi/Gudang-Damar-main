<?php

namespace App\Http\Controllers;

use App\Models\Aktivitas;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AktivitasController extends Controller
{
    /**
     * Tampilkan halaman Riwayat Aktivitas.
     *
     * Halaman ini menampilkan gabungan data dari 3 tabel (pesanan, barang, servis)
     * yang ditampilkan sebagai "aktivitas" di Riwayat/Index.vue
     */
    public function index(Request $request): Response
    {
        // Ambil filter dari query string
        $filters = [
            'search'     => $request->input('search'),
            'jenis'      => $request->input('jenis'),      // all | pesanan | barang | servis
            'status'     => $request->input('status'),     // all | Dipesan | Dibeli | Diproses | Selesai
            'kategori'   => $request->input('kategori'),
            'start_date' => $request->input('start_date'),
            'end_date'   => $request->input('end_date'),
        ];

        // Ambil semua aktivitas dari ketiga tabel
        $aktivitas = Aktivitas::all($filters);

        // Filter berdasarkan jenis (pesanan/barang/servis)
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

        // Filter status
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $aktivitas = $aktivitas->where('status', $filters['status'])->values();
        }

        // Filter kategori (bahan)
        if (!empty($filters['kategori']) && $filters['kategori'] !== 'all') {
            $aktivitas = $aktivitas->filter(function ($item) use ($filters) {
                return stripos($item['bahan'] ?? '', $filters['kategori']) !== false;
            })->values();
        }

        // Pagination manual karena data dari collection gabungan
        $perPage     = 10;
        $currentPage = (int) $request->input('page', 1);
        $total       = $aktivitas->count();
        $lastPage    = max(1, (int) ceil($total / $perPage));
        $paginated   = $aktivitas->forPage($currentPage, $perPage)->values();

        // Kirim data ke Vue (sesuai struktur props di Riwayat/Index.vue)
        return Inertia::render('riwayat/Index', [
            'transactions' => [
                'data'         => $paginated,
                'current_page' => $currentPage,
                'last_page'    => $lastPage,
                'total'        => $total,
                'per_page'     => $perPage,
            ],
            'stats'   => Aktivitas::stats(),
            'filters' => $filters,
        ]);
    }

    /**
     * Tampilkan detail 1 aktivitas berdasarkan jenis & id.
     * Dipanggil dari tombol "visibility" di tabel.
     */
    public function show(Request $request, string $jenis, int $id)
    {
        $data = null;

        switch (strtolower($jenis)) {
            case 'pesanan':
                $data = \App\Models\Pesanan::with('barang')->findOrFail($id);
                break;

            case 'barang':
                $data = \App\Models\Barang::findOrFail($id);
                break;

            case 'servis':
                $data = \App\Models\Servis::findOrFail($id);
                break;

            default:
                abort(404, 'Jenis aktivitas tidak dikenal.');
        }

        return Inertia::render('riwayat/Detail', [
            'jenis' => ucfirst($jenis),
            'data'  => $data,
        ]);
    }

    /**
     * Export data (placeholder - tombol "Export Data" di halaman).
     */
    public function export(Request $request)
    {
        $filters   = $request->all();
        $aktivitas = Aktivitas::all($filters);

        $filename = 'riwayat-aktivitas-' . date('Y-m-d') . '.csv';
        $headers  = [
            'Content-Type'        => 'text/csv',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function () use ($aktivitas) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, [
                'Jenis', 'Sub Jenis', 'Nama Barang', 'Kategori', 'Jumlah',
                'Harga Satuan', 'Total Harga', 'Pendapatan', 'Status', 'Tanggal Transaksi',
            ]);

            foreach ($aktivitas as $row) {
                fputcsv($handle, [
                    $row['jenis'],
                    $row['sub_jenis'] ?? '-',     // ✨ baru
                    $row['nama_barang'],
                    $row['kategori'],
                    $row['jumlah'],
                    $row['harga_satuan'],
                    $row['total_harga'],
                    $row['pendapatan'] ?? 0,      // ✨ baru
                    $row['status'],
                    $row['tanggal_transaksi'],
                ]);
            }

            fclose($handle);
        };

        return response()->stream($callback, 200, $headers);
    }
}