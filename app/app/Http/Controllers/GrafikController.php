<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use App\Models\AktivitasBarang;
use App\Models\Pesanan;
use App\Models\Servis;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class GrafikController extends Controller
{
    /**
     * Halaman utama grafik/analytics.
     * Menyediakan semua data yang dibutuhkan index.vue
     */
    public function index(Request $request): Response
    {
        $period = $request->input('period', 'YTD'); // 1D | 1W | 1M | 3M | YTD | 1Y | 5Y

        return Inertia::render('grafik/index', [
            // ── Summary Cards ──────────────────────────────────────────────
            'summaryCards'      => $this->getSummaryCards(),

            // ── Revenue Trend (bar chart utama) ────────────────────────────
            'revenueTrend'      => $this->getRevenueTrend($period),

            // ── Revenue by Category (bahan) ────────────────────────────────
            'revenueByCategory' => $this->getRevenueByCategory(),

            // ── Stok & Penjualan Barang ─────────────────────────────────────
            'topStok'           => $this->getTopStok(),
            'topTerjual'        => $this->getTopTerjual(),

            // ── Pesanan ─────────────────────────────────────────────────────
            'pesananTrend'      => $this->getPesananTrend($period),
            'topPesanan'        => $this->getTopPesanan(),

            // ── Servis ──────────────────────────────────────────────────────
            'servisTrend'       => $this->getServisTrend($period),
            'topServis'         => $this->getTopServis(),

            // Kirim period aktif agar Vue tahu tombol mana yang aktif
            'activePeriod'      => $period,
        ]);
    }

    // =========================================================================
    //  SUMMARY CARDS
    // =========================================================================

    /**
     * Hitung 3 kartu ringkasan di bagian atas:
     *   1. Total Revenue (pendapatan semua sumber)
     *   2. YTD Growth vs tahun lalu
     *   3. Peak Revenue Period (bulan / kuartal terbaik)
     */
    private function getSummaryCards(): array
    {
        $now       = Carbon::now();
        $thisYear  = $now->year;
        $lastYear  = $thisYear - 1;

        // ── Total Revenue bulan ini ─────────────────────────────────────────
        $revenueThisMonth = $this->getTotalRevenue(
            $now->copy()->startOfMonth(),
            $now->copy()->endOfMonth()
        );
        $revenueLastMonth = $this->getTotalRevenue(
            $now->copy()->subMonth()->startOfMonth(),
            $now->copy()->subMonth()->endOfMonth()
        );

        $revenueChangePercent = $revenueLastMonth > 0
            ? round((($revenueThisMonth - $revenueLastMonth) / $revenueLastMonth) * 100, 1)
            : 0;

        // ── YoY Growth (bulan ini vs bulan yang sama tahun lalu) ──────────────
        $revenueThisMonthFull = $revenueThisMonth; // sudah dihitung di atas
        $revenueSameMonthLastYear = $this->getTotalRevenue(
            $now->copy()->subYear()->startOfMonth(),  // tgl 1 bulan ini tahun lalu
            $now->copy()->subYear()->endOfMonth()     // akhir bulan ini tahun lalu
        );

        $oneYearGrowth = $revenueSameMonthLastYear > 0
            ? round((($revenueThisMonthFull - $revenueSameMonthLastYear) / $revenueSameMonthLastYear) * 100, 1)
            : 0;

        // ── Peak Revenue Period ─────────────────────────────────────────────
        $peak = $this->getPeakPeriod();

        return [
            'totalRevenue'        => $revenueThisMonth,
            'revenueChangePercent'=> $revenueChangePercent,
            'oneYearGrowth'       => $oneYearGrowth,
            'peakPeriod'          => $peak['label'],   // mis. "Q3 '24"
            'peakRevenue'         => $peak['revenue'],
        ];
    }

    /**
     * Jumlahkan pendapatan dari 3 sumber: barang (AktivitasBarang jenis=jual),
     * pesanan (tanggalterkirim not null), servis (tanggalterkirim not sentinel).
     */
    private function getTotalRevenue(Carbon $from, Carbon $to): int
    {
        // Pendapatan dari penjualan barang
        $barang = AktivitasBarang::where('jenis', 'jual')
            ->whereBetween('tanggal', [$from, $to])
            ->sum('pendapatan');

        // Pendapatan dari pesanan selesai
        $pesanan = Pesanan::whereNotNull('tanggalterkirim')
            ->whereBetween('tanggalterkirim', [$from, $to])
            ->sum('pendapatan');

        // Pendapatan dari servis selesai (tanggalterkirim != sentinel 1970-01-01)
        $servis = Servis::where('tanggalterkirim', '!=', '1970-01-01 00:00:00')
            ->whereNotNull('tanggalterkirim')
            ->whereBetween('tanggalterkirim', [$from, $to])
            ->sum('pendapatan');

        return (int) ($barang + $pesanan + $servis);
    }

    /**
     * Cari bulan/kuartal dengan pendapatan tertinggi (rolling 2 tahun).
     */
    private function getPeakPeriod(): array
    {
        $months      = [];
        $startOfScan = Carbon::now()->subYears(2)->startOfMonth();

        for ($i = 0; $i < 24; $i++) {
            $monthStart = $startOfScan->copy()->addMonths($i);
            $monthEnd   = $monthStart->copy()->endOfMonth();
            $revenue    = $this->getTotalRevenue($monthStart, $monthEnd);

            $months[] = [
                'year'    => $monthStart->year,
                'month'   => $monthStart->month,
                'revenue' => $revenue,
            ];
        }

        // Cari bulan tertinggi, mapping ke kuartal
        $peak    = collect($months)->sortByDesc('revenue')->first();
        $quarter = 'Q' . ceil($peak['month'] / 3) . " '" . substr($peak['year'], 2);

        return [
            'label'   => $quarter,
            'revenue' => $peak['revenue'],
        ];
    }

    // =========================================================================
    //  REVENUE TREND (bar chart utama)
    // =========================================================================

    /**
     * Kembalikan array data per-periode untuk bar chart Revenue Trend.
     * Format: [ ['label' => 'JAN', 'revenue' => 850000000, 'height_percent' => 60], ... ]
     */
    private function getRevenueTrend(string $period): array
    {
        $buckets = $this->buildTimeBuckets($period);

        $maxRevenue = 0;
        foreach ($buckets as &$bucket) {
            $bucket['revenue'] = $this->getTotalRevenue(
                Carbon::parse($bucket['from']),
                Carbon::parse($bucket['to'])
            );
            if ($bucket['revenue'] > $maxRevenue) {
                $maxRevenue = $bucket['revenue'];
            }
        }
        unset($bucket);

        // Hitung height_percent relatif ke nilai tertinggi (untuk rendering bar CSS)
        foreach ($buckets as &$bucket) {
            $bucket['height_percent'] = $maxRevenue > 0
                ? round(($bucket['revenue'] / $maxRevenue) * 100)
                : 0;
        }
        unset($bucket);

        // ── Trend: selisih persentase bucket pertama vs terakhir ──────────
        $trendPercent = null; // null = tidak ditampilkan (misal 1D)
        if ($period !== '1D' && count($buckets) >= 2) {
            $firstRevenue = $buckets[0]['revenue'];
            $lastRevenue  = $buckets[count($buckets) - 1]['revenue'];
            if ($firstRevenue > 0) {
                $trendPercent = round((($lastRevenue - $firstRevenue) / $firstRevenue) * 100, 2);
                $trendPercent = max(-200000, min(200000, $trendPercent));
            } elseif ($lastRevenue > 0) {
                $trendPercent = 100.0;
            } else {
                $trendPercent = 0;
            }
        }

        return [
            'buckets'      => $buckets,
            'maxRevenue'   => $maxRevenue,
            'yAxisLabels'  => $this->buildYAxisLabels($maxRevenue),
            'trendPercent' => $trendPercent,
        ];
    }

    /**
     * Buat bucket waktu sesuai period yang dipilih.
     * Untuk YTD/1Y/5Y → per bulan.
     * Untuk 3M → per minggu.
     * Untuk 1W/1M → per hari.
     * Untuk 1D → per jam (hourly).
     */
    private function buildTimeBuckets(string $period): array
    {
        $now     = Carbon::now();
        $buckets = [];

        switch ($period) {
            case '1D':
                for ($h = 7; $h <= 17; $h++) {
                    $from = $now->copy()->startOfDay()->addHours($h);
                    $to   = $from->copy()->addHour()->subSecond();
                    $buckets[] = [
                        'label' => $from->format('H:i'),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                }
                break;

            case '1W':
                for ($d = 6; $d >= 0; $d--) {
                    $from = $now->copy()->subDays($d)->startOfDay();
                    $to   = $from->copy()->endOfDay();
                    $buckets[] = [
                        'label' => $from->format('D'),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                }
                break;

            case '1M':
                for ($d = 29; $d >= 0; $d--) {
                    $from = $now->copy()->subDays($d)->startOfDay();
                    $to   = $from->copy()->endOfDay();
                    $buckets[] = [
                        'label' => $from->format('d'),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                }
                break;

            case '3M':
                $start = $now->copy()->subMonths(3)->startOfWeek();
                $week  = $start->copy();
                while ($week->lte($now)) {
                    $from = $week->copy()->startOfWeek();
                    $to   = $week->copy()->endOfWeek();
                    $buckets[] = [
                        'label' => $from->format('d/M'),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                    $week->addWeek();
                }
                break;

            case '1Y':
                for ($m = 12; $m >= 0; $m--) {
                    $from = $now->copy()->subMonths($m)->startOfMonth();
                    $to   = $from->copy()->endOfMonth();
                    $buckets[] = [
                        'label' => strtoupper($from->format('M')),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                }
                break;

            case '5Y':
                for ($y = 5; $y >= 0; $y--) {
                    $from = $now->copy()->subYears($y)->startOfYear();
                    $to   = $from->copy()->endOfYear();
                    $buckets[] = [
                        'label' => $from->format('Y'),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                }
                break;

            // YTD (default)
            default:
                $startOfYear = Carbon::create($now->year, 1, 1)->startOfMonth();
                for ($m = 0; $m < $now->month; $m++) {
                    $from = $startOfYear->copy()->addMonths($m);
                    $to   = $from->copy()->endOfMonth();
                    $buckets[] = [
                        'label' => strtoupper($from->format('M')),
                        'from'  => $from->toDateTimeString(),
                        'to'    => $to->toDateTimeString(),
                    ];
                }
                break;
        }

        return $buckets;
    }

    /**
     * Buat 5 label Y-axis (dari 0 sampai max) dalam format IDR singkat.
     */
    private function buildYAxisLabels(int $maxRevenue): array
    {
        if ($maxRevenue === 0) {
            return ['2,000M', '1,500M', '1,000M', '500M', '0'];
        }

        $labels = [];
        for ($i = 4; $i >= 0; $i--) {
            $value = ($maxRevenue / 4) * $i;
            $labels[] = $this->formatRevenueLabelShort((int) $value);
        }
        return $labels;
    }

    /** Format angka jadi "850M", "1.2B", "2,500M" dsb. */
    private function formatRevenueLabelShort(int $value): string
    {
        if ($value === 0) return '0';
        if ($value >= 1_000_000_000) {
            return number_format($value / 1_000_000_000, 1) . 'B';
        }
        return number_format($value / 1_000_000, 0, '.', ',') . 'M';
    }

    // =========================================================================
    //  REVENUE BY CATEGORY (bahan)
    // =========================================================================

    /**
     * Pendapatan dikelompokkan berdasarkan sumber: Terjual, Pesanan, Servis.
     * Format: [ ['kategori' => 'Terjual', 'revenue' => ..., 'percent' => 45], ... ]
     */
    private function getRevenueByCategory(): array
    {
        // Pendapatan dari penjualan barang (jenis = jual)
        $terjual = (int) AktivitasBarang::where('jenis', 'jual')->sum('pendapatan');

        // Pendapatan dari pesanan selesai (tanggalterkirim not null)
        $pesanan = (int) Pesanan::whereNotNull('tanggalterkirim')->sum('pendapatan');

        // Pendapatan dari servis selesai (tanggalterkirim != sentinel)
        $servis = (int) Servis::where('tanggalterkirim', '!=', '1970-01-01 00:00:00')
            ->whereNotNull('tanggalterkirim')
            ->sum('pendapatan');

        $totalAll = $terjual + $pesanan + $servis;

        $sources = [
            ['kategori' => 'Terjual', 'revenue' => $terjual],
            ['kategori' => 'Pesanan', 'revenue' => $pesanan],
            ['kategori' => 'Servis',  'revenue' => $servis],
        ];

        // Hitung persentase dan urutkan dari terbesar
        $result = collect($sources)->map(function ($item) use ($totalAll) {
            $item['percent'] = $totalAll > 0
                ? round(($item['revenue'] / $totalAll) * 100, 2)
                : 0;
            return $item;
        })->sortByDesc('revenue')->values()->toArray();

        return $result;
    }

    // =========================================================================
    //  TOP STOK & TOP TERJUAL
    // =========================================================================

    /**
     * Top 10 barang berdasarkan stok terbanyak saat ini.
     */
    private function getTopStok(int $limit = 10): array
    {
        $items = Barang::orderByDesc('jumlah')
            ->limit($limit)
            ->get(['nama', 'jumlah']);

        $max = $items->first()?->jumlah ?? 1;

        return $items->map(function ($item) use ($max) {
            return [
                'nama'           => $item->nama,
                'jumlah'         => $item->jumlah,
                'width_percent'  => $max > 0
                    ? round(($item->jumlah / $max) * 100)
                    : 0,
            ];
        })->toArray();
    }

    /**
     * Top 10 barang berdasarkan total unit terjual (dari log AktivitasBarang).
     */
    private function getTopTerjual(int $limit = 10): array
    {
        $items = AktivitasBarang::where('jenis', 'jual')
            ->select('nama_barang', DB::raw('SUM(jumlah) as total_terjual'))
            ->groupBy('nama_barang')
            ->orderByDesc('total_terjual')
            ->limit($limit)
            ->get();

        $max = $items->first()?->total_terjual ?? 1;

        return $items->map(function ($item) use ($max) {
            return [
                'nama'          => $item->nama_barang,
                'jumlah'        => (int) $item->total_terjual,
                'width_percent' => $max > 0
                    ? round(($item->total_terjual / $max) * 100)
                    : 0,
            ];
        })->toArray();
    }

    // =========================================================================
    //  PESANAN TREND & TOP PESANAN
    // =========================================================================

    /**
     * Trend jumlah pesanan per-periode (count, bukan revenue).
     */
    private function getPesananTrend(string $period): array
    {
        $buckets = $this->buildTimeBuckets($period);
        $max     = 0;

        foreach ($buckets as &$bucket) {
            $count = Pesanan::whereBetween('tanggalpemesanan', [
                $bucket['from'], $bucket['to'],
            ])->count();

            $bucket['count'] = $count;
            if ($count > $max) $max = $count;
        }
        unset($bucket);

        foreach ($buckets as &$bucket) {
            $bucket['height_percent'] = $max > 0
                ? round(($bucket['count'] / $max) * 100)
                : 0;
        }
        unset($bucket);

        // ── Trend: selisih persentase bucket pertama vs terakhir ──────────
        $trendPercent = null;
        if ($period !== '1D' && count($buckets) >= 2) {
            $firstCount = $buckets[0]['count'];
            $lastCount  = $buckets[count($buckets) - 1]['count'];
            if ($firstCount > 0) {
                $trendPercent = round((($lastCount - $firstCount) / $firstCount) * 100, 2);
                $trendPercent = max(-200000, min(200000, $trendPercent));
            } elseif ($lastCount > 0) {
                $trendPercent = 100.0;
            } else {
                $trendPercent = 0;
            }
        }

        return [
            'buckets'      => $buckets,
            'maxCount'     => $max,
            'yAxisLabels'  => $this->buildCountYAxis($max),
            'trendPercent' => $trendPercent,
        ];
    }

    /**
     * Top 5 pesanan terbanyak berdasarkan nama_barang.
     */
    private function getTopPesanan(int $limit = 5): array
    {
        $items = Pesanan::select('nama_barang', DB::raw('SUM(jumlah) as total'))
            ->groupBy('nama_barang')
            ->orderByDesc('total')
            ->limit($limit)
            ->get();

        $max = $items->first()?->total ?? 1;

        return $items->map(function ($item) use ($max) {
            return [
                'nama'          => $item->nama_barang,
                'jumlah'        => (int) $item->total,
                'width_percent' => $max > 0
                    ? round(($item->total / $max) * 100)
                    : 0,
            ];
        })->toArray();
    }

    // =========================================================================
    //  SERVIS TREND & TOP SERVIS
    // =========================================================================

    /**
     * Trend jumlah servis per-periode (count).
     */
    private function getServisTrend(string $period): array
    {
        $buckets = $this->buildTimeBuckets($period);
        $max     = 0;

        foreach ($buckets as &$bucket) {
            $count = Servis::whereBetween('tanggalpemesanan', [
                $bucket['from'], $bucket['to'],
            ])->count();

            $bucket['count'] = $count;
            if ($count > $max) $max = $count;
        }
        unset($bucket);

        foreach ($buckets as &$bucket) {
            $bucket['height_percent'] = $max > 0
                ? round(($bucket['count'] / $max) * 100)
                : 0;
        }
        unset($bucket);

        // ── Trend: selisih persentase bucket pertama vs terakhir ──────────
        $trendPercent = null;
        if ($period !== '1D' && count($buckets) >= 2) {
            $firstCount = $buckets[0]['count'];
            $lastCount  = $buckets[count($buckets) - 1]['count'];
            if ($firstCount > 0) {
                $trendPercent = round((($lastCount - $firstCount) / $firstCount) * 100, 2);
                $trendPercent = max(-200000, min(200000, $trendPercent));
            } elseif ($lastCount > 0) {
                $trendPercent = 100.0;
            } else {
                $trendPercent = 0;
            }
        }

        return [
            'buckets'      => $buckets,
            'maxCount'     => $max,
            'yAxisLabels'  => $this->buildCountYAxis($max),
            'trendPercent' => $trendPercent,
        ];
    }

    /**
     * Top 5 servis berdasarkan nama_barang (jenis servis terpopuler).
     */
    private function getTopServis(int $limit = 5): array
    {
        $items = Servis::select('nama_barang', DB::raw('COUNT(*) as total'))
            ->groupBy('nama_barang')
            ->orderByDesc('total')
            ->limit($limit)
            ->get();

        $max = $items->first()?->total ?? 1;

        return $items->map(function ($item) use ($max) {
            return [
                'nama'          => $item->nama_barang,
                'jumlah'        => (int) $item->total,
                'width_percent' => $max > 0
                    ? round(($item->total / $max) * 100)
                    : 0,
            ];
        })->toArray();
    }

    // =========================================================================
    //  HELPERS
    // =========================================================================

    /** Buat 5 label Y-axis untuk grafik berbasis count (bukan rupiah). */
    private function buildCountYAxis(int $max): array
    {
        if ($max === 0) return ['10', '7.5', '5', '2.5', '0'];

        $labels = [];
        for ($i = 4; $i >= 0; $i--) {
            $value    = ($max / 4) * $i;
            $labels[] = $value >= 1000
                ? number_format($value / 1000, 1) . 'K'
                : (string) round($value);
        }
        return $labels;
    }
}