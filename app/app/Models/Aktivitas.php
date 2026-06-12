<?php

namespace App\Models;

use Illuminate\Support\Collection;

class Aktivitas
{
    public static function all(array $filters = []): Collection
    {
        $pesanan     = self::fromPesanan($filters);
        $barangLog   = self::fromAktivitasBarang($filters);
        $servis      = self::fromServis($filters);

        $merged = $pesanan->concat($barangLog)->concat($servis);

        return $merged->sortByDesc(function ($item) {
            return $item['tanggal_transaksi'] ?? '';
        })->values();
    }

    protected static function fromPesanan(array $filters = []): Collection
    {
        $query = Pesanan::query()->with('barang')->orderByDesc('tanggalpemesanan');

        if (!empty($filters['search'])) {
            $query->where('nama_barang', 'like', '%' . $filters['search'] . '%');
        }
        if (!empty($filters['start_date'])) {
            $query->whereDate('tanggalpemesanan', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('tanggalpemesanan', '<=', $filters['end_date']);
        }

        return $query->get()->map(function ($row) {
            $hargaSatuan = $row->harga ?? ($row->barang->harga ?? 0);
            $totalHarga  = $hargaSatuan * $row->jumlah;

            // ✅ FIX: cek tanggalterkirim sebagai Carbon
            $isSelesai = self::isTanggalValid($row->tanggalterkirim);

            return [
                'id'                => $row->id_pesanan,
                'jenis'             => 'Pesanan',
                'sub_jenis'         => null,
                'nama_barang'       => $row->nama_barang,
                'bahan'             => $row->bahan,
                'kategori'          => $row->bahan,
                'jumlah'            => $row->jumlah,
                'harga_satuan'      => $hargaSatuan,
                'total_harga'       => $totalHarga,
                'pendapatan'        => $row->pendapatan ?? ($isSelesai ? $totalHarga : 0),
                'catatan'           => $row->catatan,
                'bentuk'            => $row->bentuk,
                'ukuran'            => $row->ukuran,
                'ketebalan'         => $row->ketebalan,
                'tanggalpemesanan'  => $row->tanggalpemesanan,
                'tanggalterkirim'   => $row->tanggalterkirim,
                'tanggal_transaksi' => $row->tanggalpemesanan,
                'status'            => $isSelesai ? 'Selesai' : 'Dipesan',
            ];
        });
    }

    protected static function fromAktivitasBarang(array $filters = []): Collection
    {
        $query = AktivitasBarang::query();

        if (!empty($filters['search'])) {
            $query->where('nama_barang', 'like', '%' . $filters['search'] . '%');
        }
        if (!empty($filters['start_date'])) {
            $query->whereDate('tanggal', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('tanggal', '<=', $filters['end_date']);
        }

        return $query->orderByDesc('tanggal')->get()->map(function ($row) {
            $isJual = $row->jenis === 'jual';

            return [
                'id'                => $row->id_aktivitas,
                'jenis'             => 'Barang',
                'sub_jenis'         => $isJual ? 'Terjual' : 'Stok',
                'nama_barang'       => $row->nama_barang,
                'bahan'             => null,
                'kategori'          => '-',
                'jumlah'            => $row->jumlah,
                'harga_satuan'      => $isJual ? $row->harga_satuan : null,
                'total_harga'       => $isJual ? $row->pendapatan : null,
                'pendapatan'        => $row->pendapatan,
                'catatan'           => $row->catatan,
                'bentuk'            => null,
                'ukuran'            => null,
                'ketebalan'         => null,
                'tanggalpemesanan'  => $row->tanggal,
                'tanggalterkirim'   => $isJual ? $row->tanggal : null,
                'tanggal_transaksi' => $row->tanggal,
                'status'            => $isJual ? 'Terjual' : 'Dibeli',
            ];
        });
    }

    protected static function fromServis(array $filters = []): Collection
    {
        // ✅ FIX: tambah orderBy biar konsisten
        $query = Servis::query()->orderByDesc('tanggalpemesanan');

        if (!empty($filters['search'])) {
            $query->where('nama_barang', 'like', '%' . $filters['search'] . '%');
        }
        if (!empty($filters['start_date'])) {
            $query->whereDate('tanggalpemesanan', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('tanggalpemesanan', '<=', $filters['end_date']);
        }

        return $query->get()->map(function ($row) {
            // ✅ FIX: pakai helper yang aman untuk Carbon object
            $isSelesai = self::isTanggalValid($row->tanggalterkirim);

            return [
                'id'                => $row->id_pesanan,
                'jenis'             => 'Servis',
                'sub_jenis'         => null,
                'nama_barang'       => $row->nama_barang,
                'bahan'             => $row->bahan,
                'kategori'          => $row->bahan,
                'jumlah'            => $row->jumlah,
                'harga_satuan'      => $row->harga,
                'total_harga'       => $row->harga ?? 0,
                'pendapatan'        => $row->pendapatan ?? ($isSelesai ? ($row->harga ?? 0) : 0),
                'catatan'           => $row->catatan,
                'bentuk'            => $row->bentuk_barang,
                'ukuran'            => null,
                'ketebalan'         => null,
                'tanggalpemesanan'  => $row->tanggalpemesanan,
                'tanggalterkirim'   => $isSelesai ? $row->tanggalterkirim : null,
                'tanggal_transaksi' => $row->tanggalpemesanan,
                'status'            => $isSelesai ? 'Selesai' : 'Diproses',
            ];
        });
    }

    /**
     * ✅ FIX: Helper aman untuk cek apakah tanggalterkirim valid (artinya sudah selesai).
     * Mendukung Carbon, string, dan null. Sentinel date 1970/0000 dianggap "belum selesai".
     */
    protected static function isTanggalValid($tanggal): bool
    {
        if (empty($tanggal)) {
            return false;
        }

        // Cast ke string Y-m-d (Carbon punya format(), string biasa pakai substr)
        if ($tanggal instanceof \DateTimeInterface) {
            $tanggalStr = $tanggal->format('Y-m-d');
        } else {
            $tanggalStr = substr((string) $tanggal, 0, 10);
        }

        // Sentinel date = belum selesai
        if ($tanggalStr === '1970-01-01' || $tanggalStr === '0000-00-00') {
            return false;
        }

        return true;
    }

    /**
     * Statistik total untuk summary cards.
     */
    public static function stats(): array
    {
        $totalPesanan = Pesanan::count();
        $totalServis  = Servis::count();
        $totalBarang  = Barang::sum('jumlah') ?? 0;

        $totalLogBarang = AktivitasBarang::count();

        // ✅ FIX: pendapatan pesanan - filter pesanan yang sudah selesai (tanggalterkirim NOT NULL)
        $pendapatanPesanan = Pesanan::whereNotNull('tanggalterkirim')->sum('pendapatan') ?? 0;

        // ✅ FIX: pendapatan servis - exclude sentinel date 1970-01-01 yang artinya belum selesai
        $pendapatanServis = Servis::whereNotNull('pendapatan')
            ->where('tanggalterkirim', '>', '1970-01-02')
            ->sum('pendapatan') ?? 0;

        $pendapatanBarang = AktivitasBarang::where('jenis', 'jual')->sum('pendapatan') ?? 0;

        $totalBarangTerjual = AktivitasBarang::where('jenis', 'jual')->sum('jumlah') ?? 0;

        return [
            'total_transaksi'       => $totalPesanan + $totalServis + $totalLogBarang,
            'total_barang_terjual'  => $totalBarangTerjual,
            'total_stok_barang'     => $totalBarang,
            'total_pendapatan'      => $pendapatanPesanan + $pendapatanServis + $pendapatanBarang,
            'pendapatan_pesanan'    => $pendapatanPesanan,
            'pendapatan_servis'     => $pendapatanServis,
            'pendapatan_barang'     => $pendapatanBarang,
            'total_pesanan'         => $totalPesanan,
            'total_servis'          => $totalServis,
        ];
    }
}