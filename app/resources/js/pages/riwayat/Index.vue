<script setup lang="ts">
import { Head, router, Link } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import Navbar from '@/components/Navbar.vue';

// Props dari AktivitasController@index
const props = defineProps({
    transactions: {
        type: Object,
        default: () => ({
            data: [],
            current_page: 1,
            last_page: 1,
            total: 0,
            per_page: 10,
        }),
    },
    stats: {
        type: Object,
        default: () => ({
            total_transaksi: 0,
            total_barang_terjual: 0,
            total_pendapatan: 0,
            total_pesanan: 0,
            total_servis: 0,
        }),
    },
    filters: {
        type: Object,
        default: () => ({
            search: '',
            jenis: 'all',
            status: 'all',
            kategori: 'all',
        }),
    },
});

// Reactive filter state
const search = ref(props.filters.search || '');
const jenis = ref(props.filters.jenis || 'all');
const status = ref(props.filters.status || 'all');
const kategori = ref(props.filters.kategori || 'all');

// Format tanggal
const formatDate = (dateString: string | null) => {
    if (!dateString) {
        return '-';
    }

    return new Date(dateString).toLocaleDateString('id-ID', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
    });
};

// Format mata uang IDR
const formatCurrency = (amount: number) => {
    if (!amount || amount === 0) {
        return '-';
    }

    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(amount);
};

// Ikon berdasarkan jenis aktivitas
const getIconByJenis = (jenis: string) => {
    const j = (jenis || '').toLowerCase();

    if (j === 'pesanan') {
        return 'shopping_cart';
    }

    if (j === 'servis') {
        return 'build';
    }

    if (j === 'barang') {
        return 'inventory_2';
    }

    return 'inventory';
};

// Warna badge berdasarkan jenis
const getJenisBadgeClass = (jenis: string) => {
    const j = (jenis || '').toLowerCase();

    if (j === 'pesanan') {
        return 'bg-blue-100 text-blue-800';
    }

    if (j === 'servis') {
        return 'bg-purple-100 text-purple-800';
    }

    if (j === 'barang') {
        return 'bg-amber-100 text-amber-800';
    }

    return 'bg-slate-100 text-slate-800';
};

// Data yang ditampilkan
const displayTransactions = computed(() => props.transactions?.data ?? []);

// Apply filter -> reload halaman
const applyFilters = () => {
    router.get(
        '/riwayat',
        {
            search: search.value,
            jenis: jenis.value,
            status: status.value,
            kategori: kategori.value,
        },
        { preserveState: true, preserveScroll: true },
    );
};

// Ganti halaman
const goToPage = (page: number) => {
    router.get(
        '/riwayat',
        {
            page,
            search: search.value,
            jenis: jenis.value,
            status: status.value,
            kategori: kategori.value,
        },
        { preserveState: true, preserveScroll: true },
    );
};

// Lihat detail
const viewDetail = (item: any) => {
    router.visit(`/riwayat/${item.jenis.toLowerCase()}/${item.id}`);
};

// Export
const exportData = () => {
    window.location.href = `/riwayat/export?search=${search.value}&jenis=${jenis.value}&status=${status.value}`;
};
</script>

<template>
    <div style="display: flex; flex-direction: column; min-height: 100vh; background-color: #f8f9fa;">
        <Head>
            <title>Riwayat Aktivitas - Gudang Damar</title>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet" />
            <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet" />
        </Head>

        <Navbar />

        <main
            style="flex: 1; padding: 40px 20px; max-width: 1600px; margin: 0 auto; width: 100%; box-sizing: border-box;"
            class="font-body text-[#191c1d]"
        >
            <!-- Header -->
            <div class="mb-10">
                <nav class="mb-4 flex items-center gap-2 text-xs font-bold tracking-widest text-slate-400 uppercase">
                    <a href="/barang">Penyimpanan</a>
                    <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                    <span class="text-[#001e40]">Riwayat Aktivitas</span>
                </nav>
                <div class="flex flex-col items-start justify-between gap-4 md:flex-row md:items-end">
                    <div>
                        <h2 class="mb-2 text-4xl font-extrabold tracking-tight text-[#001e40]">
                            Riwayat Aktivitas
                        </h2>
                        <p class="text-lg text-[#43474f]">
                            Gabungan riwayat Pesanan, Barang, dan Servis.
                        </p>
                    </div>
                    <div class="flex items-center gap-3">
                        <!-- BUTTON GRAFIK -->
                        
                        <button
                            @click="exportData"
                            class="flex items-center gap-2 rounded-lg bg-[#006e25] px-6 py-3 text-sm font-bold text-white shadow-lg shadow-[#006e25]/20 transition-all hover:opacity-90"
                        >
                            <span class="material-symbols-outlined text-sm">file_download</span>
                            Export Data
                        </button>
                    </div>
                </div>
            </div>

            <!-- Summary Cards -->
            <div class="mb-10 grid grid-cols-1 gap-6 md:grid-cols-3">
                <div class="group rounded-xl bg-white p-6 shadow-[0_12px_40px_rgba(0,30,64,0.04)] transition-all duration-300 hover:shadow-lg">
                    <div class="mb-4 flex items-start justify-between">
                        <div class="rounded-lg bg-[#f3f4f5] p-3 transition-colors group-hover:bg-[#003366] group-hover:text-white">
                            <span class="material-symbols-outlined">receipt_long</span>
                        </div>
                    </div>
                    <p class="mb-1 text-[11px] font-bold tracking-widest text-slate-400 uppercase">Total Transaksi</p>
                    <h3 class="text-3xl font-extrabold tracking-tight text-[#001e40]">
                        {{ stats.total_transaksi.toLocaleString('id-ID') }}
                    </h3>
                    <p class="mt-2 text-xs text-slate-500">
                        Pesanan: {{ stats.total_pesanan }} | Servis: {{ stats.total_servis }}
                    </p>
                </div>

                <div class="group rounded-xl bg-white p-6 shadow-[0_12px_40px_rgba(0,30,64,0.04)] transition-all duration-300 hover:shadow-lg">
                    <div class="mb-4 flex items-start justify-between">
                        <div class="rounded-lg bg-[#f3f4f5] p-3 transition-colors group-hover:bg-[#003366] group-hover:text-white">
                            <span class="material-symbols-outlined">inventory</span>
                        </div>
                    </div>
                    <p class="mb-1 text-[11px] font-bold tracking-widest text-slate-400 uppercase">Total Barang</p>
                    <h3 class="text-3xl font-extrabold tracking-tight text-[#001e40]">
                        {{ stats.total_barang_terjual.toLocaleString('id-ID') }}
                    </h3>
                </div>

                <div class="group rounded-xl border-l-4 border-[#006e25] bg-white p-6 shadow-[0_12px_40px_rgba(0,30,64,0.04)] transition-all duration-300 hover:shadow-lg">
                    <div class="mb-4 flex items-start justify-between">
                        <div class="rounded-lg bg-[#f3f4f5] p-3 transition-colors group-hover:bg-[#003366] group-hover:text-white">
                            <span class="material-symbols-outlined">payments</span>
                        </div>
                    </div>
                    <p class="mb-1 text-[11px] font-bold tracking-widest text-slate-400 uppercase">Total Pendapatan</p>
                    <h3 class="text-3xl font-extrabold tracking-tight text-[#001e40]">
                        {{
                            stats.total_pendapatan >= 1000000000
                                ? 'Rp ' + (stats.total_pendapatan / 1000000000).toFixed(1) + 'B'
                                : formatCurrency(stats.total_pendapatan)
                        }}
                    </h3>
                </div>
            </div>

            <!-- Filter Bar -->
            <div class="mb-6 flex flex-wrap items-center gap-4 rounded-xl border border-slate-200 bg-[#f3f4f5] p-5">
                <div class="relative min-w-62.5 flex-1 md:min-w-75">
                    <span class="material-symbols-outlined absolute top-1/2 left-3 -translate-y-1/2 text-slate-400">search</span>
                    <input
                        v-model="search"
                        @keyup.enter="applyFilters"
                        class="w-full rounded-lg border-none bg-white py-3 pr-4 pl-11 text-sm focus:ring-2 focus:ring-[#006e25]/50"
                        placeholder="Cari nama barang..."
                        type="text"
                    />
                </div>
                <div class="flex flex-wrap gap-3">
                    <!-- Filter Jenis Aktivitas -->
                    <select
                        v-model="jenis"
                        @change="applyFilters"
                        class="cursor-pointer rounded-lg border-none bg-white px-4 py-2.5 text-sm font-medium focus:ring-2 focus:ring-[#006e25]/50"
                    >
                        <option value="all">Semua Jenis</option>
                        <option value="pesanan">Pesanan</option>
                        <option value="barang">Barang</option>
                        <option value="servis">Servis</option>
                    </select>

                    <select
                        v-model="status"
                        @change="applyFilters"
                        class="cursor-pointer rounded-lg border-none bg-white px-4 py-2.5 text-sm font-medium focus:ring-2 focus:ring-[#006e25]/50"
                    >
                        <option value="all">Semua Status</option>
                        <option value="Dipesan">Dipesan</option>
                        <option value="Diproses">Diproses</option>
                        <option value="Dibeli">Stok Masuk</option>
                        <option value="Terjual">Terjual</option>
                        <option value="Selesai">Selesai</option>
                    </select>

                    <div class="flex items-center gap-3">

                    <!-- BUTTON GRAFIK -->
                    <Link 
                        href="/grafik"
                        class="flex items-center gap-2 bg-white border border-slate-200 text-primary px-4 py-2.5 rounded-lg font-bold text-sm hover:bg-slate-50 transition-all"
                    >
                        <span class="material-symbols-outlined text-lg">leaderboard</span>
                        Grafik
                    </Link>

                    </div>



                    
                </div>
            </div>

            <!-- Tabel -->
            <div class="overflow-hidden rounded-xl bg-white shadow-[0_12px_40px_rgba(0,30,64,0.04)]">
                <div class="overflow-x-auto">
                    <table class="w-full border-collapse text-left">
                        <thead>
                            <tr class="border-b border-[#c3c6d1]/20 bg-[#f3f4f5]">
                                <th class="px-6 py-4 w-[12%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase pl-13">Jenis</th>
                                <th class="px-6 py-4 w-[28%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase">Nama Barang</th>
                                <th class="px-6 py-4 w-[10%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase">Jumlah</th>
                                <th class="px-6 py-4 w-[15%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase">Harga Satuan</th>
                                <th class="px-6 py-4 w-[15%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase">Total Harga</th>
                                <th class="px-6 py-4 w-[10%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase">Status</th>
                                <th class="px-6 py-4 w-[10%] text-xs font-extrabold tracking-[0.15em] text-slate-500 uppercase">Tanggal</th>
                                
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-[#c3c6d1]/10">
                            <tr
                                v-for="(item, index) in displayTransactions"
                                :key="`${item.jenis}-${item.sub_jenis || ''}-${item.id}-${index}`"
                                class="transition-colors hover:bg-[#f3f4f5]/60"
                            >
                                <!-- Jenis -->
                                <td class="px-6 py-5">
                                    <span
                                        class="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[10px] font-extrabold tracking-widest uppercase"
                                        :class="getJenisBadgeClass(item.jenis)"
                                    >
                                        <span class="material-symbols-outlined text-[14px]">
                                            {{ getIconByJenis(item.jenis) }}
                                        </span>
                                        {{ item.jenis }}
                                    </span>
                                </td>

                               
                                <!-- Nama Barang -->
                                <td class="px-6 py-5">
                                    <div class="flex items-center gap-3">
                                        <div class="flex h-10 w-10 items-center justify-center rounded bg-[#f3f4f5] text-[#001e40]">
                                            <span class="material-symbols-outlined">{{ getIconByJenis(item.jenis) }}</span>
                                        </div>
                                        <div>
                                            <div class="font-bold text-[#001e40]">{{ item.nama_barang }}</div>
                                            <div v-if="item.catatan" class="text-xs text-slate-500">{{ item.catatan }}</div>
                                        </div>
                                    </div>
                                </td>

                                <!-- Jumlah -->
                                <td class="px-6 py-5 text-sm font-bold text-[#001e40]">
                                    {{ item.jumlah }} Unit
                                </td>

                                <!-- Harga Satuan (null untuk ubah stok) -->
                                <td class="px-6 py-5 text-sm text-[#43474f]">
                                    {{ formatCurrency(item.harga_satuan) }}
                                    
                                </td>

                                <!-- Total Harga (null untuk ubah stok) -->
                                <td class="px-6 py-5 text-sm font-extrabold text-[#001e40]">
                                    {{ formatCurrency(item.total_harga) }}
                                </td>

                                <!-- Status -->
                                <td class="px-6 py-5">
                                    <span
                                        v-if="item.status === 'Selesai'"
                                        class="rounded-full bg-[#80f98b] px-3 py-1 text-[10px] font-extrabold tracking-widest text-[#007327] uppercase"
                                    >Selesai</span>
                                    <span
                                        v-else-if="item.status === 'Diproses'"
                                        class="rounded-full bg-[#fef3c7] px-3 py-1 text-[10px] font-extrabold tracking-widest text-[#b45309] uppercase"
                                    >Dalam Proses</span>
                                    <span
                                        v-else-if="item.status === 'Dibeli'"
                                        class="rounded-full bg-blue-100 px-3 py-1 text-[10px] font-extrabold tracking-widest text-blue-800 uppercase"
                                    >Stok Masuk</span>
                                    <span
                                        v-else-if="item.status === 'Terjual'"
                                        class="rounded-full bg-green-100 px-3 py-1 text-[10px] font-extrabold tracking-widest text-green-800 uppercase"
                                    >Terjual</span>
                                    <span
                                        v-else
                                        class="rounded-full bg-red-100 px-3 py-1 text-[10px] font-extrabold tracking-widest text-red-800 uppercase"
                                    >Dipesan</span>
                                </td>

                                <!-- Tanggal -->
                                <td class="px-6 py-5 text-sm text-[#43474f]">
                                    {{ formatDate(item.tanggal_transaksi) }}
                                </td>

                                <!-- Aksi -->
                                
                            </tr>

                            <tr v-if="displayTransactions.length === 0">
                                <td colspan="8" class="px-6 py-10 text-center text-slate-500">
                                    Belum ada riwayat aktivitas.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div class="flex flex-col items-center justify-between gap-4 border-t border-[#c3c6d1]/20 bg-[#f3f4f5]/50 px-6 py-4 md:flex-row">
                    <p class="text-center text-xs font-bold tracking-widest text-slate-500 uppercase md:text-left">
                        Menampilkan {{ displayTransactions.length }} dari {{ transactions.total }} Aktivitas
                    </p>
                    <div class="flex items-center gap-2">
                        <button
                            @click="goToPage(transactions.current_page - 1)"
                            :disabled="transactions.current_page === 1"
                            class="p-2 text-slate-400 transition-colors hover:text-[#001e40] disabled:opacity-30"
                        >
                            <span class="material-symbols-outlined">chevron_left</span>
                        </button>
                        <div class="flex items-center gap-1">
                            <button
                                v-for="p in Math.min(transactions.last_page, 5)"
                                :key="p"
                                @click="goToPage(p)"
                                class="h-8 w-8 rounded-lg text-xs font-bold transition-all"
                                :class="
                                    p === transactions.current_page
                                        ? 'bg-[#001e40] text-white shadow-md shadow-[#001e40]/20'
                                        : 'hover:bg-[#f3f4f5]'
                                "
                            >
                                {{ p }}
                            </button>
                        </div>
                        <button
                            @click="goToPage(transactions.current_page + 1)"
                            :disabled="transactions.current_page === transactions.last_page"
                            class="p-2 text-slate-400 transition-colors hover:text-[#001e40] disabled:opacity-30"
                        >
                            <span class="material-symbols-outlined">chevron_right</span>
                        </button>
                    </div>
                </div>
            </div>
        </main>

        <footer>&copy; 2025 GudangDamar. All rights reserved.</footer>
    </div>
</template>

<style scoped>
.font-body {
    font-family: 'Inter', sans-serif;
}
.material-symbols-outlined {
    font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}
footer {
    background-color: #222;
    color: white;
    padding: 12px;
    text-align: center;
    font-size: 14px;
}
</style>