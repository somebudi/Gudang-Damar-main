<script setup>
import { router,Link } from '@inertiajs/vue3'
import Navbar from '@/components/Navbar.vue';
defineOptions({ layout: null })

// ── Props dari GrafikController::index() ─────────────────────────────────
const props = defineProps({
  summaryCards:      { type: Object, default: () => ({}) },
  revenueTrend:      { type: Object, default: () => ({ buckets: [], yAxisLabels: [] }) },
  revenueByCategory: { type: Array,  default: () => [] },
  topStok:           { type: Array,  default: () => [] },
  topTerjual:        { type: Array,  default: () => [] },
  pesananTrend:      { type: Object, default: () => ({ buckets: [], yAxisLabels: [] }) },
  topPesanan:        { type: Array,  default: () => [] },
  servisTrend:       { type: Object, default: () => ({ buckets: [], yAxisLabels: [] }) },
  topServis:         { type: Array,  default: () => [] },
  activePeriod:      { type: String, default: 'YTD' },
})

const periods = ['1D', '1W', '1M', '3M', 'YTD', '1Y', '5Y']

// Warna tetap untuk bar revenue by category
const categoryColorMap = {
  'Pesanan': '#2563eb',   // biru
  'Servis':  '#7c3aed',   // ungu
  'Terjual': '#f97316',   // orange
}
const defaultCategoryColor = '#64748b' // fallback abu

function getCategoryColor(kategori) {
  return categoryColorMap[kategori] || defaultCategoryColor
}

// Ganti period → Inertia request baru ke /grafik?period=X
function changePeriod(period) {
  router.get('/grafik', { period }, {
    preserveState:  true,
    preserveScroll: true,
    replace:        true,
  })
}

// Menampilkan nominal rupiah utuh tanpa penyingkatan
function formatRupiah(value) {
  if (!value && value !== 0) return 'Rp 0';
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value);
}

// Menampilkan angka kuantitas utuh (misal: 1.500 alih-alih 1.5K)
function formatCount(value) {
  if (!value && value !== 0) return '0';
  return value.toLocaleString('id-ID');
}

// ── Trend helpers (3 state: naik/turun/stagnan) ──────────────────────────
function trendColor(val) {
  const v = val ?? 0;
  if (v > 0) return '#16a34a';   // hijau
  if (v < 0) return '#dc2626';   // merah
  return '#9ca3af';              // abu-abu (stagnan)
}

function trendBg(val) {
  const v = val ?? 0;
  if (v > 0) return 'rgba(22,163,74,0.12)';
  if (v < 0) return 'rgba(220,38,38,0.12)';
  return 'rgba(156,163,175,0.12)';
}

function trendIcon(val) {
  const v = val ?? 0;
  if (v > 0) return 'trending_up';
  if (v < 0) return 'trending_down';
  return 'trending_flat';
}

// Background & border untuk card berdasarkan trend
function cardBg(val) {
  const v = val ?? 0;
  if (v > 0) return 'rgba(22,163,74,0.08)';   // hijau muda
  if (v < 0) return 'rgba(220,38,38,0.08)';   // merah muda
  return '';                                    // default (tidak berubah)
}

function cardBorder(val) {
  const v = val ?? 0;
  if (v > 0) return '1px solid rgba(22,163,74,0.25)';
  if (v < 0) return '1px solid rgba(220,38,38,0.25)';
  return '';                                    // default
}
</script>

<template>
<div class="min-h-screen bg-gray-50">
  <Navbar />
  <main class="flex-1 min-h-screen w-full">
    <div class="pt-8 px-6 pb-12 max-w-7xl mx-auto space-y-8">

      <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-6">
        <div>
          <h2 class="text-3xl font-light tracking-tight text-primary font-display mb-1">Performa Pendapatan</h2>
          <p class="text-on-surface-variant text-sm">Insight data keuangan operasional gudang.</p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

        <div class="rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] flex flex-col justify-between h-36 transition-colors duration-500"
          :style="{
            backgroundColor: cardBg(summaryCards.revenueChangePercent) || undefined,
            border: cardBorder(summaryCards.revenueChangePercent) || '1px solid rgba(var(--md-sys-color-outline-variant), 0.15)'
          }"
          :class="{ 'bg-surface-container-lowest border border-outline-variant/15': !(summaryCards.revenueChangePercent) }"
        >
          <span class="text-xs font-semibold text-on-surface-variant uppercase tracking-widest font-label">Total Pendapatan</span>
          <div>
            <div class="text-2xl md:text-3xl font-light text-primary tracking-tight font-display truncate" :title="formatRupiah(summaryCards.totalRevenue)">
              {{ formatRupiah(summaryCards.totalRevenue) }}
            </div>
            <div class="flex items-center mt-2">
              <span
                class="flex items-center px-2 py-0.5 rounded-full text-xs font-medium mr-2"
                :style="{
                  color: trendColor(summaryCards.revenueChangePercent),
                  backgroundColor: trendBg(summaryCards.revenueChangePercent)
                }"
              >
                <span class="material-symbols-outlined text-[14px] mr-1">
                  {{ trendIcon(summaryCards.revenueChangePercent) }}
                </span>
                {{ (summaryCards.revenueChangePercent ?? 0) > 0 ? '+' : '' }}{{ summaryCards.revenueChangePercent ?? 0 }}%
              </span>
              <span class="text-xs text-outline">vs bulan lalu</span>
            </div>
          </div>
        </div>

        <div class="rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] flex flex-col justify-between h-36 transition-colors duration-500"
          :style="{
            backgroundColor: cardBg(summaryCards.oneYearGrowth) || undefined,
            border: cardBorder(summaryCards.oneYearGrowth) || '1px solid rgba(var(--md-sys-color-outline-variant), 0.15)'
          }"
          :class="{ 'bg-surface-container-lowest border border-outline-variant/15': !(summaryCards.oneYearGrowth) }"
        >
          <span class="text-xs font-semibold text-on-surface-variant uppercase tracking-widest font-label">Pertumbuhan YoY </span>
          <div>
            <div class="text-3xl font-light tracking-tight font-display" :style="{ color: trendColor(summaryCards.oneYearGrowth) }">
              {{ (summaryCards.oneYearGrowth ?? 0) > 0 ? '+' : '' }}{{ summaryCards.oneYearGrowth ?? 0 }}%
            </div>
            <div class="flex items-center mt-2">
              <span
                class="flex items-center px-2 py-0.5 rounded-full text-xs font-medium mr-2"
                :style="{
                  color: trendColor(summaryCards.oneYearGrowth),
                  backgroundColor: trendBg(summaryCards.oneYearGrowth)
                }"
              >
                <span class="material-symbols-outlined text-[14px] mr-1">
                  {{ trendIcon(summaryCards.oneYearGrowth) }}
                </span>
                {{ (summaryCards.oneYearGrowth ?? 0) > 0 ? '+' : '' }}{{ summaryCards.oneYearGrowth ?? 0 }}%
              </span>
              <span class="text-xs text-outline">vs bulan yang sama tahun lalu</span>
            </div>
          </div>
        </div>

        <div class="bg-surface-container-lowest rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-outline-variant/15 flex flex-col justify-between h-36 relative overflow-hidden">
          <div class="absolute right-0 bottom-0 opacity-15 pointer-events-none">
            <span class="material-symbols-outlined text-[100px] text-amber-500 drop-shadow-[0_6px_20px_rgba(245,158,11,0.35)]">
              military_tech
            </span>
          </div>
          <span class="text-xs font-semibold text-on-surface-variant uppercase tracking-widest font-label relative z-10">Periode Pendapatan Tertinggi</span>
          <div class="relative z-10">
            <div class="text-3xl font-light text-primary tracking-tight font-display">
              {{ summaryCards.peakPeriod || '—' }}
            </div>
            <div class="flex items-center mt-2 truncate">
              <span class="text-xs text-outline truncate" :title="formatRupiah(summaryCards.peakRevenue)">Pendapatan tertinggi: {{ formatRupiah(summaryCards.peakRevenue) }} </span>
            </div>
          </div>
        </div>

      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        <div class="lg:col-span-2 bg-surface-container-lowest rounded-lg shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-outline-variant/15 flex flex-col h-[500px]">
          <div class="p-6 pb-2 border-b border-surface-variant flex justify-between items-center">
            <div class="flex items-center gap-3">
              <h3 class="font-bold text-primary font-headline">Analisis Tren Pendapatan</h3>
              <span
                v-if="revenueTrend.trendPercent != null && activePeriod !== '1D'"
                class="flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                :style="{
                  color: trendColor(revenueTrend.trendPercent),
                  backgroundColor: trendBg(revenueTrend.trendPercent)
                }"
              >
                <span class="material-symbols-outlined text-[14px] mr-1">
                  {{ trendIcon(revenueTrend.trendPercent) }}
                </span>
                {{ (revenueTrend.trendPercent ?? 0) > 0 ? '+' : '' }}{{ revenueTrend.trendPercent ?? 0 }}%
              </span>
            </div>
            <div class="flex bg-surface-container-high rounded-DEFAULT p-1 overflow-x-auto no-scrollbar gap-1">
              <button
                v-for="p in periods"
                :key="p"
                @click="changePeriod(p)"
                class="px-3 py-1 text-xs font-medium rounded-DEFAULT transition-all duration-300 ease-out transform hover:scale-105 active:scale-95 whitespace-nowrap"
                :class="activePeriod === p
                  ? 'font-bold bg-surface-container-lowest shadow-sm'
                  : 'text-on-surface-variant hover:text-green-600 hover:bg-surface-container-lowest/50'"
                :style="activePeriod === p ? { color: '#16a34a', boxShadow: '0 0 0 1px rgba(22,163,74,0.2)' } : {}"
              >{{ p }}</button>
            </div>
          </div>
          <div class="p-6 flex-1 relative flex items-end justify-between pl-28 pr-6 pb-12 pt-8">
            <div class="absolute inset-0 p-6 pb-12 pl-28 pr-6 pointer-events-none flex flex-col justify-between">
              <div v-for="i in 4" :key="i" class="border-t border-surface-container-high w-full"></div>
              <div class="border-t border-outline-variant/40 w-full"></div>
            </div>

            <template v-if="revenueTrend.buckets && revenueTrend.buckets.length">
              <div
                v-for="bucket in revenueTrend.buckets"
                :key="bucket.label"
                class="relative z-10 flex flex-col items-center group h-full justify-end"
                style="flex: 1;"
              >
                <div
                  class="w-full max-w-[32px] rounded-t-sm shadow-sm relative cursor-pointer transition-colors"
                  :class="bucket.height_percent === 100 ? 'bg-green-600' : 'bg-green-300 group-hover:bg-green-500'"
                  :style="{ height: Math.max(bucket.height_percent, 2) + '%', opacity: bucket.height_percent === 0 ? 0.3 : 1 }"
                >
                  <div class="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-surface-container-lowest border border-outline-variant/20 shadow-lg rounded-DEFAULT p-3 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none w-max min-w-[140px] z-50">
                    <p class="text-[10px] font-label uppercase text-outline mb-1 text-center">{{ bucket.label }}</p>
                    <p class="text-sm font-bold text-primary text-center">{{ formatRupiah(bucket.revenue) }}</p>
                  </div>
                </div>
                <div class="absolute -bottom-8 text-[10px] text-outline font-label text-center w-full truncate">{{ bucket.label }}</div>
              </div>
            </template>
            <div v-else class="w-full h-full flex items-center justify-center text-sm text-outline">
              Belum ada data revenue.
            </div>

            <div class="absolute left-2 top-8 bottom-12 w-24 pr-2 flex flex-col justify-between text-[10px] text-outline font-label pointer-events-none text-right">
              <span v-for="label in revenueTrend.yAxisLabels" :key="label" class="truncate" :title="label">{{ label }}</span>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg p-6 h-[500px] flex flex-col border border-gray-200 shadow-sm">
          <h3 class="font-bold text-primary font-headline mb-6">Revenue by Category</h3>
          <div class="flex-1 space-y-5 overflow-y-auto pr-2 no-scrollbar">
            <template v-if="revenueByCategory && revenueByCategory.length">
              <div v-for="(cat, idx) in revenueByCategory" :key="cat.kategori">
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm font-medium text-on-surface truncate max-w-[65%]">{{ cat.kategori }}</span>
                  <span class="text-sm font-bold text-primary">{{ cat.percent }}%</span>
                </div>
                <div class="w-full bg-surface-variant rounded-full h-1.5">
                  <div
                    class="h-1.5 rounded-full transition-all duration-700 ease-out"
                    :style="{ width: cat.percent + '%', background: getCategoryColor(cat.kategori) }"
                  ></div>
                </div>
                <p class="text-xs text-outline mt-1 text-right">{{ formatRupiah(cat.revenue) }}</p>
              </div>
            </template>
            <div v-else class="text-sm text-center py-8 text-outline">
              Belum ada data penjualan per kategori.
            </div>
          </div>
        </div>

      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

        <div class="bg-surface-container-lowest rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-gray-200  flex flex-col">
          <div class="flex justify-between items-center mb-6">
            <h3 class="font-bold text-primary uppercase font-headline tracking-wider text-sm">Top 10 Stok Terbanyak</h3>
            <span class="material-symbols-outlined text-[20px] text-blue-400">inventory_2</span>
          </div>
          <div class="space-y-3 overflow-y-auto no-scrollbar" style="max-height:320px;">
            <template v-if="topStok && topStok.length">
              <div v-for="(item, idx) in topStok" :key="item.nama" class="flex items-center gap-3 hover:bg-blue-50/40 px-2 py-1 rounded-md transition-all duration-200">
                <span class="text-xs font-bold w-5 text-right shrink-0 text-slate-500">{{ idx + 1 }}</span>
                <div class="flex-1 min-w-0">
                  <div class="flex justify-between items-center mb-1">
                    <span class="text-sm font-medium text-gray-800 truncate">{{ item.nama }}</span>
                    <span class="text-xs font-semibold ml-2 shrink-0 text-blue-500">{{ formatCount(item.jumlah) }}</span>
                  </div>
                  <div class="w-full bg-surface-container-high rounded-full h-1.5">
                    <div class="bg-[#93C5FD] h-1.5 rounded-full transition-all duration-700 ease-out" :style="{ width: item.width_percent + '%' }"></div>
                  </div>
                </div>
              </div>
            </template>
            <div v-else class="text-sm text-center py-6 text-outline">Belum ada data stok.</div>
          </div>
        </div>

        <div class="bg-surface-container-lowest rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-gray-200 flex flex-col">
          <div class="flex justify-between items-center mb-6">
            <h3 class="font-bold text-primary uppercase font-headline tracking-wider text-sm">Top 10 Barang Terjual</h3>
            <span class="material-symbols-outlined text-[20px] text-[#f59e0b]">sell</span>
          </div>
          <div class="space-y-3 overflow-y-auto no-scrollbar" style="max-height:320px;">
            <template v-if="topTerjual && topTerjual.length">
              <div v-for="(item, idx) in topTerjual" :key="item.nama" class="flex items-center gap-3 hover:bg-orange-50/40 px-2 py-1 rounded-md transition-all duration-200">
                <span class="text-xs font-bold w-5 text-right shrink-0 text-slate-500">{{ idx + 1 }}</span>
                <div class="flex-1 min-w-0">
                  <div class="flex justify-between items-center mb-1">
                    <span class="text-sm font-medium text-gray-800 truncate">{{ item.nama }}</span>
                    <span class="text-xs font-semibold ml-2 shrink-0 text-[#d97706]">{{ formatCount(item.jumlah) }}</span>
                  </div>
                  <div class="w-full bg-surface-container-high rounded-full h-1.5">
                    <div class="bg-[#F59E0B] h-1.5 rounded-full transition-all duration-700 ease-out" :style="{ width: item.width_percent + '%' }"></div>
                  </div>
                </div>
              </div>
            </template>
            <div v-else class="text-sm text-center py-6 text-outline">Belum ada data penjualan.</div>
          </div>
        </div>

      </div>

      <div class="flex flex-col gap-4">
        <h2 class="text-2xl font-light tracking-tight text-primary font-display">Analisis Tren Pesanan</h2>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

          <div class="lg:col-span-2 bg-surface-container-lowest rounded-lg shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-outline-variant/15 flex flex-col h-[400px]">
            <div class="p-6 pb-2 border-b border-surface-variant flex justify-between items-center">
              <div class="flex items-center gap-3">
                <h3 class="font-bold text-primary font-headline uppercase tracking-wider text-sm">Trend Pesanan</h3>
                <span
                  v-if="pesananTrend.trendPercent != null && activePeriod !== '1D'"
                  class="flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                  :style="{
                    color: trendColor(pesananTrend.trendPercent),
                    backgroundColor: trendBg(pesananTrend.trendPercent)
                  }"
                >
                  <span class="material-symbols-outlined text-[14px] mr-1">
                    {{ trendIcon(pesananTrend.trendPercent) }}
                  </span>
                  {{ (pesananTrend.trendPercent ?? 0) > 0 ? '+' : '' }}{{ pesananTrend.trendPercent ?? 0 }}%
                </span>
              </div>
              <div class="flex bg-surface-container-high rounded-DEFAULT p-1 overflow-x-auto no-scrollbar gap-1">
                <button
                  v-for="p in periods" :key="p"
                  @click="changePeriod(p)"
                  class="px-2 py-1 text-[10px] font-medium rounded-DEFAULT transition-all duration-300 ease-out transform hover:scale-105 active:scale-95 whitespace-nowrap"
                  :class="activePeriod === p
                    ? 'font-bold bg-surface-container-lowest shadow-sm'
                    : 'text-on-surface-variant hover:text-blue-600 hover:bg-surface-container-lowest/50'"
                  :style="activePeriod === p ? { color: '#2563eb', boxShadow: '0 0 0 1px rgba(37,99,235,0.2)' } : {}"
                >{{ p }}</button>
              </div>
            </div>
            <div class="p-6 flex-1 relative flex items-end justify-between pl-16 pr-6 pb-12 pt-8">
              <div class="absolute inset-0 p-6 pb-12 pl-16 pr-6 pointer-events-none flex flex-col justify-between">
                <div v-for="i in 4" :key="i" class="border-t border-surface-container-high w-full"></div>
                <div class="border-t border-outline-variant/40 w-full"></div>
              </div>
              <template v-if="pesananTrend.buckets && pesananTrend.buckets.length">
                <div
                  v-for="bucket in pesananTrend.buckets" :key="bucket.label"
                  class="relative z-10 flex flex-col items-center group h-full justify-end"
                  style="flex: 1;"
                >
                  <div
                    class="w-full max-w-[28px] shadow-sm relative cursor-pointer transition-colors"
                    :class="bucket.height_percent === 100   ? 'bg-blue-600'   : 'bg-blue-300 group-hover:bg-blue-500'"
                    :style="{ height: Math.max(bucket.height_percent, 2) + '%', opacity: bucket.height_percent === 0 ? 0.3 : 1 }"
                  >
                    <div class="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-surface-container-lowest border border-outline-variant/20 shadow-lg rounded-DEFAULT p-2 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-50 whitespace-nowrap">
                      <p class="text-[10px] font-label uppercase text-outline mb-0.5 text-center">{{ bucket.label }}</p>
                      <p class="text-xs font-bold text-primary text-center">{{ formatCount(bucket.count) }} pesanan</p>
                    </div>
                  </div>
                  <div class="absolute -bottom-7 text-[10px] text-outline font-label text-center w-full truncate">{{ bucket.label }}</div>
                </div>
              </template>
              <div v-else class="w-full h-full flex items-center justify-center text-sm text-outline">
                Belum ada data pesanan.
              </div>
              <div class="absolute left-2 top-8 bottom-12 w-12 pr-2 flex flex-col justify-between text-[10px] text-outline font-label pointer-events-none text-right">
                <span v-for="label in pesananTrend.yAxisLabels" :key="label" class="truncate" :title="label">{{ label }}</span>
              </div>
            </div>
          </div>

          <div class="bg-surface-container-lowest rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-gray-200 flex flex-col h-[400px]">
            <div class="flex justify-between items-center mb-6">
              <h3 class="font-bold text-primary uppercase font-headline tracking-wider text-sm">Top 5 Pesanan</h3>
              <span class="material-symbols-outlined text-[20px] text-blue-500 ">shopping_cart</span>
            </div>
            <div class="space-y-4 overflow-y-auto no-scrollbar flex-1">
              <template v-if="topPesanan && topPesanan.length">
                <div 
                    v-for="(item, idx) in topPesanan" 
                    :key="item.nama" 
                    class="flex items-center gap-3 hover:bg-blue-50/40 px-2 py-1 rounded-md  transition-all duration-200"
                  >
                  <span class="text-xs font-bold w-5 text-right shrink-0 text-slate-500">{{ idx + 1 }}</span>
                  <div class="flex-1 min-w-0">
                    <div class="flex justify-between items-center mb-1">
                      <span class="text-sm font-medium text-on-surface truncate">{{ item.nama }}</span>
                      <span class="text-sm font-semibold text-blue-600 ml-2 shrink-0">{{ formatCount(item.jumlah) }}</span>
                    </div>
                    <div class="w-full bg-surface-container-high rounded-full h-1.5">
                      <div class="bg-[#60A5FA] h-1.5 rounded-full transition-all duration-700 ease-out" :style="{ width: item.width_percent + '%' }"></div>
                    </div>
                  </div>
                </div>
              </template>
              <div v-else class="text-sm text-center py-6 text-outline">Belum ada data pesanan.</div>
            </div>
          </div>

        </div>
      </div>

      <div class="flex flex-col gap-4">
        <h2 class="text-2xl font-light tracking-tight text-primary font-display">Analisis Tren Servis</h2>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

          <div class="lg:col-span-2 bg-surface-container-lowest rounded-lg shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-outline-variant/15 flex flex-col h-[400px]">
            <div class="p-6 pb-2 border-b border-surface-variant flex justify-between items-center">
              <div class="flex items-center gap-3">
                <h3 class="font-bold text-primary font-headline uppercase tracking-wider text-sm">Trend Servis</h3>
                <span
                  v-if="servisTrend.trendPercent != null && activePeriod !== '1D'"
                  class="flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                  :style="{
                    color: trendColor(servisTrend.trendPercent),
                    backgroundColor: trendBg(servisTrend.trendPercent)
                  }"
                >
                  <span class="material-symbols-outlined text-[14px] mr-1">
                    {{ trendIcon(servisTrend.trendPercent) }}
                  </span>
                  {{ (servisTrend.trendPercent ?? 0) > 0 ? '+' : '' }}{{ servisTrend.trendPercent ?? 0 }}%
                </span>
              </div>
              <div class="flex bg-surface-container-high rounded-DEFAULT p-1 overflow-x-auto no-scrollbar gap-1">
                <button
                  v-for="p in periods" :key="p"
                  @click="changePeriod(p)"
                  class="px-2 py-1 text-[10px] font-medium rounded-DEFAULT transition-all duration-300 ease-out transform hover:scale-105 active:scale-95 whitespace-nowrap"
                  :class="activePeriod === p
                    ? 'font-bold bg-surface-container-lowest shadow-sm'
                    : 'text-on-surface-variant hover:text-purple-600 hover:bg-surface-container-lowest/50'"
                  :style="activePeriod === p ? { color: '#7c3aed', boxShadow: '0 0 0 1px rgba(124,58,237,0.2)' } : {}"
                >{{ p }}</button>
              </div>
            </div>
            <div class="p-6 flex-1 relative flex items-end justify-between pl-16 pr-6 pb-12 pt-8">
              <div class="absolute inset-0 p-6 pb-12 pl-16 pr-6 pointer-events-none flex flex-col justify-between">
                <div v-for="i in 4" :key="i" class="border-t border-surface-container-high w-full"></div>
                <div class="border-t border-outline-variant/40 w-full"></div>
              </div>
              <template v-if="servisTrend.buckets && servisTrend.buckets.length">
                <div
                  v-for="bucket in servisTrend.buckets" :key="bucket.label"
                  class="relative z-10 flex flex-col items-center group h-full justify-end"
                  style="flex: 1;"
                >
                  <div
                    class="w-full max-w-[28px]  shadow-sm relative cursor-pointer transition-colors"
                    :class="bucket.height_percent === 100   ? 'bg-purple-600'   : 'bg-purple-300 group-hover:bg-purple-500'"
                    :style="{ height: Math.max(bucket.height_percent, 2) + '%', opacity: bucket.height_percent === 0 ? 0.3 : 1 }"
                  >
                    <div class="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 bg-surface-container-lowest border border-outline-variant/20 shadow-lg rounded-DEFAULT p-2 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-50 whitespace-nowrap">
                      <p class="text-[10px] font-label uppercase text-outline mb-0.5 text-center">{{ bucket.label }}</p>
                      <p class="text-xs font-bold text-primary text-center">{{ formatCount(bucket.count) }} servis</p>
                    </div>
                  </div>
                  <div class="absolute -bottom-7 text-[10px] text-outline font-label text-center w-full truncate">{{ bucket.label }}</div>
                </div>
              </template>
              <div v-else class="w-full h-full flex items-center justify-center text-sm text-outline">
                Belum ada data servis.
              </div>
              <div class="absolute left-2 top-8 bottom-12 w-12 pr-2 flex flex-col justify-between text-[10px] text-outline font-label pointer-events-none text-right">
                <span v-for="label in servisTrend.yAxisLabels" :key="label" class="truncate" :title="label">{{ label }}</span>
              </div>
            </div>
          </div>

          <div class="bg-surface-container-lowest rounded-lg p-6 shadow-[0_4px_20px_rgba(0,30,64,0.03)] border border-gray-200 flex flex-col h-[400px]">
            <div class="flex justify-between items-center mb-6">
              <h3 class="font-bold text-primary uppercase font-headline tracking-wider text-sm">Top 5 Servis</h3>
              <span class="material-symbols-outlined text-[20px] text-purple-500">build</span>
            </div>
            <div class="space-y-4 overflow-y-auto no-scrollbar flex-1">
              <template v-if="topServis && topServis.length">
                <div v-for="(item, idx) in topServis" :key="item.nama" class="flex items-center gap-3 hover:bg-purple-50/40 px-2 py-1 rounded-md transition-all duration-200">
                  <span class="text-xs font-bold w-5 text-right shrink-0 text-slate-500">{{ idx + 1 }}</span>
                  <div class="flex-1 min-w-0">
                    <div class="flex justify-between items-center mb-1">
                      <span class="text-sm font-medium text-on-surface truncate">{{ item.nama }}</span>
                      <span class="text-sm font-semibold text-purple-600 ml-2 shrink-0">{{ formatCount(item.jumlah) }}</span>
                    </div>
                    <div class="w-full bg-surface-container-high rounded-full h-1.5">
                      <div class="bg-[#A78BFA] h-1.5 rounded-full transition-all duration-700 ease-out" :style="{ width: item.width_percent + '%' }"></div>
                    </div>
                  </div>
                </div>
              </template>
              <div v-else class="text-sm text-center py-6 text-outline">Belum ada data servis.</div>
            </div>
          </div>

        </div>
      </div>

    </div>
  </main>
</div>
</template>



<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
</style>
