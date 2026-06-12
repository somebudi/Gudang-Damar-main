<script setup lang="ts">
import { router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import Navbar from '@/components/Navbar.vue';
import Swal from 'sweetalert2';

interface Barang {
    id_barang: number;
    nama: string;
    guna_merek: string;
    ukuran: number;
    ketebalan: string;
    bentuk: string;
    bahan: string;
    harga: number;
    jumlah: number;
    total: number;
}


const props = defineProps<{
    barangList: Barang[];
}>();

const search = ref('');
const sortBy = ref<keyof Barang>('id_barang');
const sortDir = ref<'asc' | 'desc'>('asc');
const showMenu = ref(false);

// Modal state
const showDetail = ref(false);
const showEdit = ref(false);
const selectedBarang = ref<Barang | null>(null);

// Edit form state
const editForm = ref<Barang>({
    id_barang: 0,
    nama: '',
    guna_merek: '',
    ukuran: 0,
    ketebalan: '',
    bentuk: '',
    bahan: '',
    harga: 0,
    jumlah: 0,
    total: 0,
});

const columns = [
    ['id_barang', 'Default (ID)'],
    ['nama', 'Nama'],
    ['guna_merek', 'Merek/Guna'],
    ['ukuran', 'Ukuran'],
    ['ketebalan', 'Ketebalan'],
    ['bentuk', 'Bentuk'],
    ['bahan', 'Bahan'],
    ['harga', 'Harga'],
    ['jumlah', 'Jumlah'],
    ['total', 'Total'],
] as const;

const filteredList = computed(() => {
    let list = [...props.barangList];
    if (search.value) {
        const s = search.value.toLowerCase();
        list = list.filter(b =>
            b.nama?.toLowerCase().includes(s) ||
            b.guna_merek?.toLowerCase().includes(s) ||
            b.bentuk?.toLowerCase().includes(s) ||
            b.bahan?.toLowerCase().includes(s) ||
            b.ketebalan?.toLowerCase().includes(s)
        );
    }
    const key = sortBy.value;
    const dir = sortDir.value === 'asc' ? 1 : -1;
    return list.sort((a, b) => {
        const va = a[key], vb = b[key];
        if (typeof va === 'number' && typeof vb === 'number') return (va - vb) * dir;
        return String(va).localeCompare(String(vb), 'id') * dir;
    });
});

const activeLabel = computed(
    () => columns.find(c => c[0] === sortBy.value)?.[1] ?? 'Sort'
);

const rupiah = (n: number) => 'Rp ' + n.toLocaleString('id-ID');
const isLoading = ref(false);

function openDetail(barang: Barang) {
    selectedBarang.value = barang;
    showDetail.value = true;
}

function openEdit(barang: Barang) {
    editForm.value = { ...barang };
    showEdit.value = true;
}


function closeEdit() { showEdit.value = false; }


function submitEdit() {
    isLoading.value = true;
    router.put(`/barang/${editForm.value.id_barang}`, {
        nama: editForm.value.nama,
        harga: {
            harga: editForm.value.harga,
            jumlah: editForm.value.jumlah,
        },
        kategori: {
            ukuran: editForm.value.ukuran,
            bentuk: editForm.value.bentuk,
            ketebalan: editForm.value.ketebalan,
            bahan: editForm.value.bahan,
            merek: editForm.value.guna_merek,
        },
    }, {
        onSuccess: () => {
            isLoading.value = false;
            closeEdit();
            Swal.fire({ title: 'Berhasil!', text: 'Barang berhasil diupdate!', icon: 'success' });
        },
        onError: () => { isLoading.value = false; },
    });
}

function hapus(id: number) {
    Swal.fire({
        title: 'Are you sure?',
        text: "You won't be able to revert this!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
    }).then((result) => {
        if (result.isConfirmed) {
            isLoading.value = true;
            router.delete(`/barang/${id}`, {
                onSuccess: () => {
                    isLoading.value = false;
                    Swal.fire({ title: 'Deleted!', text: 'Barang berhasil dihapus.', icon: 'success' });
                },
                onError: () => { isLoading.value = false; },
            });
        }
    });
}


// State untuk Set Barang & Jual Barang
const setJumlah = ref(0);
const jualJumlah = ref(0);
const showSetBarang = ref(false);
const showJualBarang = ref(false);

function toggleSet() {
    showSetBarang.value = !showSetBarang.value;
    showJualBarang.value = false;
}

function toggleJual() {
    showJualBarang.value = !showJualBarang.value;
    showSetBarang.value = false;
}

function closeDetail() {
    showDetail.value = false;
    selectedBarang.value = null;
    showSetBarang.value = false;
    showJualBarang.value = false;
    setJumlah.value = 0;
    jualJumlah.value = 0;
}

function submitSet() {
    if (!selectedBarang.value) return;
    if (setJumlah.value === 0) {
        Swal.fire({ title: 'Perhatian!', text: 'Jumlah tidak boleh 0', icon: 'warning' });
        return;
    }

    const stokBaru = selectedBarang.value.jumlah + setJumlah.value;
    isLoading.value = true;

    router.put(`/barang/${selectedBarang.value.id_barang}`, {
        nama: selectedBarang.value.nama,
        harga: { harga: selectedBarang.value.harga, jumlah: stokBaru },
        kategori: {
            ukuran: selectedBarang.value.ukuran,
            bentuk: selectedBarang.value.bentuk,
            ketebalan: selectedBarang.value.ketebalan,
            bahan: selectedBarang.value.bahan,
            merek: selectedBarang.value.guna_merek,
        },
    }, {
        onSuccess: () => {
            isLoading.value = false;
            closeDetail();
            Swal.fire({ title: 'Berhasil!', text: `Stok berhasil diupdate menjadi ${stokBaru}`, icon: 'success' });
        },
        onError: () => { isLoading.value = false; },
    });
}

function submitJual() {
    if (!selectedBarang.value) return;
    if (jualJumlah.value <= 0) {
        Swal.fire({ title: 'Perhatian!', text: 'Jumlah harus lebih dari 0', icon: 'warning' });
        return;
    }
    if (jualJumlah.value > selectedBarang.value.jumlah) {
        Swal.fire({ title: 'Stok tidak cukup!', text: `Stok tersedia: ${selectedBarang.value.jumlah}`, icon: 'error' });
        return;
    }

    const stokBaru = selectedBarang.value.jumlah - jualJumlah.value;
    const terjual = jualJumlah.value;
    isLoading.value = true;

    router.put(`/barang/${selectedBarang.value.id_barang}`, {
        nama: selectedBarang.value.nama,
        harga: { harga: selectedBarang.value.harga, jumlah: stokBaru },
        kategori: {
            ukuran: selectedBarang.value.ukuran,
            bentuk: selectedBarang.value.bentuk,
            ketebalan: selectedBarang.value.ketebalan,
            bahan: selectedBarang.value.bahan,
            merek: selectedBarang.value.guna_merek,
        },
    }, {
        onSuccess: () => {
            isLoading.value = false;
            closeDetail();
            Swal.fire({ title: 'Terjual!', text: `Penjualan ${terjual} unit tercatat. Sisa stok: ${stokBaru}`, icon: 'success' });
        },
        onError: () => { isLoading.value = false; },
    });
}

</script>

<template>
    <div class="min-h-screen bg-gray-50">
        <Navbar />

        <div class="max-w-7xl mx-auto mt-10 px-4">
            <h1 class="text-2xl md:text-3xl font-bold text-gray-800">📦 List Barang</h1>
            <p class="text-sm text-gray-500 mb-6">Kelola semua barang dengan mudah</p>

            <div class="flex flex-col md:flex-row md:justify-between md:items-center gap-3 mb-4">
                <a href="/barang/create"
                   class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg w-fit">
                    + Tambah Barang
                </a>

                <div class="flex flex-col md:flex-row gap-2 w-full md:w-auto">
                    <input v-model="search" type="text"
                           placeholder="🔍︎ Cari nama, merek, bahan, bentuk..."
                           class="border border-gray-300 px-4 py-2 rounded-lg w-full md:w-72 text-black" />

                    <div class="relative flex gap-1">
                        <button @click="showMenu = !showMenu"
                                class="bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded-lg flex items-center gap-2 whitespace-nowrap text-gray-700">
                            Sort: {{ activeLabel }} <span class="text-xs">▼</span>
                        </button>
                        <button @click="sortDir = sortDir === 'asc' ? 'desc' : 'asc'"
                                class="bg-gray-200 hover:bg-gray-300 px-3 py-2 flex rounded-lg items-center gap-1 text-gray-700">
                            {{ sortDir === 'asc' ? '↑' : '↓' }}
                        </button>

                        <div v-if="showMenu"
                             class="absolute top-full mt-1 bg-white border shadow-lg z-10 w-48 rounded-lg">
                            <button v-for="[key, label] in columns" :key="key"
                                    @click="sortBy = key; showMenu = false"
                                    class="block w-full text-left px-4 py-2 hover:bg-blue-500 hover:text-white text-gray-700 first:rounded-t-lg last:rounded-b-lg"
                                    :class="{ 'bg-blue-500 text-white': sortBy === key }">
                                {{ label }}
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div v-if="($page.props.flash as any)?.success"
                 class="bg-green-100 text-green-700 p-3 rounded mb-4">
                {{ ($page.props.flash as any).success }}
            </div>

            <div class="overflow-x-auto">
                <table class="w-full bg-white rounded-xl shadow">
                    <thead class="bg-gray-200 text-gray-700">
                        <tr>
                            <th v-for="h in ['Nama','Merek/Guna','Ukuran','Ketebalan','Bentuk','Bahan','Harga','Jumlah','Total','Aksi']"
                                :key="h" class="p-3">{{ h }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="!filteredList.length">
                            <td colspan="10" class="p-6 text-center text-gray-500">
                                Tidak ada barang ditemukan
                            </td>
                        </tr>
                        <tr v-for="b in filteredList" :key="b.id_barang"
                            class="border-t text-center hover:bg-gray-50 text-black">
                            <td class="p-3">{{ b.nama }}</td>
                            <td class="p-3">{{ b.guna_merek }}</td>
                            <td class="p-3">{{ b.ukuran }}</td>
                            <td class="p-3">{{ b.ketebalan }}</td>
                            <td class="p-3">{{ b.bentuk }}</td>
                            <td class="p-3">{{ b.bahan }}</td>
                            <td class="p-3">{{ rupiah(b.harga) }}</td>
                            <td class="p-3">{{ b.jumlah }}</td>
                            <td class="p-3 font-semibold">{{ rupiah(b.total) }}</td>
                            <td class="p-3 space-x-1 whitespace-nowrap">
                                <button @click="openDetail(b)"
                                        class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm">
                                    Detail
                                </button>
                                <button @click="openEdit(b)"
                                        class="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-1 rounded text-sm">
                                    Edit
                                </button>
                                <button @click="hapus(b.id_barang)"
                                        class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-sm">
                                    Hapus
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="mt-3 text-sm text-gray-600">
                Total: <span class="font-semibold">{{ filteredList.length }}</span>
                dari {{ barangList.length }} barang
                <span v-if="search">| Pencarian: "<span class="font-semibold">{{ search }}</span>"</span>
                <span v-if="sortBy !== 'id_barang'">
                    | Sort: <span class="font-semibold">{{ activeLabel }}</span>
                    ({{ sortDir === 'asc' ? 'A-Z' : 'Z-A' }})
                </span>
            </div>
        </div>

        <!-- Modal Detail -->
<Transition name="fade">
    <div v-if="showDetail"
         class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
         @click.self="closeDetail">
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-md p-6 max-h-[90vh] overflow-y-auto">

            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-gray-800">Detail Barang</h2>
                <button @click="closeDetail"
                        class="text-gray-400 hover:text-gray-600 text-2xl leading-none">&times;</button>
            </div>

            <div v-if="selectedBarang" class="space-y-2">
                <div class="info-row"><span>Nama</span><span>{{ selectedBarang.nama }}</span></div>
                <div class="info-row"><span>Merek/Guna</span><span>{{ selectedBarang.guna_merek }}</span></div>
                <div class="info-row"><span>Ukuran</span><span>{{ selectedBarang.ukuran }}</span></div>
                <div class="info-row"><span>Bentuk</span><span>{{ selectedBarang.bentuk }}</span></div>
                <div class="info-row"><span>Ketebalan</span><span>{{ selectedBarang.ketebalan }}</span></div>
                <div class="info-row"><span>Bahan</span><span>{{ selectedBarang.bahan }}</span></div>
                <div class="info-row"><span>Harga</span><span>{{ rupiah(selectedBarang.harga) }}</span></div>
                <div class="info-row"><span>Jumlah (Stok)</span><span class="font-semibold text-blue-600">{{ selectedBarang.jumlah }}</span></div>
                <div class="info-row font-semibold"><span>Total</span><span>{{ rupiah(selectedBarang.total) }}</span></div>
            </div>

            <!-- Tombol Set & Jual -->
            <div class="flex gap-2 mt-5">
                <button @click="toggleSet"
                        class="flex-1 py-2 rounded-lg font-semibold text-sm transition"
                        :class="showSetBarang ? 'bg-green-500 text-white' : 'bg-green-100 text-green-700 hover:bg-green-200'">
                    📦 Set Barang
                </button>
                <button @click="toggleJual"
                        class="flex-1 py-2 rounded-lg font-semibold text-sm transition"
                        :class="showJualBarang ? 'bg-orange-500 text-white' : 'bg-orange-100 text-orange-700 hover:bg-orange-200'">
                    💰 Jual Barang
                </button>
            </div>

            <!-- Panel Set Barang -->
            <Transition name="slide">
                <div v-if="showSetBarang" class="mt-4 p-4 bg-green-50 border border-green-200 rounded-xl">
                    <p class="text-sm font-semibold text-green-700 mb-3">
                        Stok saat ini: <span class="font-bold">{{ selectedBarang?.jumlah }}</span>
                        → Stok baru: <span class="font-bold text-green-600">{{ (selectedBarang?.jumlah ?? 0) + setJumlah }}</span>
                    </p>
                    <div class="flex items-center gap-2">
                        <button @click="setJumlah = Math.max(-(selectedBarang?.jumlah ?? 0), setJumlah - 1)"
                                class="bg-green-200 hover:bg-green-300 text-green-800 w-9 h-9 rounded-lg font-bold text-lg">
                            ➖
                        </button>
                        <input v-model.number="setJumlah" type="number"
                               class="flex-1 border border-green-300 rounded-lg px-3 py-2 text-center text-black font-semibold" />
                        <button @click="setJumlah++"
                                class="bg-green-200 hover:bg-green-300 text-green-800 w-9 h-9 rounded-lg font-bold text-lg">
                            ➕
                        </button>
                    </div>
                    <p class="text-xs text-gray-500 mt-1 text-center">
                        Gunakan angka negatif untuk mengurangi stok manual
                    </p>
                    <button @click="submitSet"
                            class="w-full mt-3 bg-green-500 hover:bg-green-600 text-white py-2 rounded-lg font-semibold text-sm">
                        Simpan Stok
                    </button>
                </div>
            </Transition>

            <!-- Panel Jual Barang -->
            <Transition name="slide">
                <div v-if="showJualBarang" class="mt-4 p-4 bg-orange-50 border border-orange-200 rounded-xl">
                    <p class="text-sm font-semibold text-orange-700 mb-3">
                        Stok saat ini: <span class="font-bold">{{ selectedBarang?.jumlah }}</span>
                        → Sisa stok: <span class="font-bold"
                            :class="(selectedBarang?.jumlah ?? 0) - jualJumlah < 0 ? 'text-red-600' : 'text-orange-600'">
                            {{ (selectedBarang?.jumlah ?? 0) - jualJumlah }}
                        </span>
                    </p>
                    <div class="flex items-center gap-2">
                        <button @click="jualJumlah = Math.max(0, jualJumlah - 1)"
                                class="bg-orange-200 hover:bg-orange-300 text-orange-800 w-9 h-9 rounded-lg font-bold text-lg">
                            ➖
                        </button>
                        <input v-model.number="jualJumlah" type="number" min="0"
                            :max="selectedBarang?.jumlah"
                            class="flex-1 border border-orange-300 rounded-lg px-3 py-2 text-center text-black font-semibold" />

                        <button @click="jualJumlah = Math.min(selectedBarang?.jumlah ?? 0, jualJumlah + 1)"
                                class="bg-orange-200 hover:bg-orange-300 text-orange-800 w-9 h-9 rounded-lg font-bold text-lg">
                            ➕
                            </button>
                    </div>
                    <button @click="submitJual"
                            class="w-full mt-3 bg-orange-500 hover:bg-orange-600 text-white py-2 rounded-lg font-semibold text-sm">
                        Catat Penjualan
                    </button>
                </div>
            </Transition>

            <!-- Action Buttons -->
            <div class="mt-5 flex justify-end gap-2">
                <button @click="openEdit(selectedBarang!); closeDetail()"
                        class="bg-yellow-500 hover:bg-yellow-600 text-white px-4 py-2 rounded-lg text-sm">
                    Edit
                </button>
                <button @click="closeDetail"
                        class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm">
                    Tutup
                </button>
            </div>

        </div>
    </div>
</Transition>

        <!-- Modal Edit -->
<Transition name="fade">
    <div v-if="showEdit"
         class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
         @click.self="closeEdit">
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-md p-6 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-gray-800">Edit Barang</h2>
                <button @click="closeEdit"
                        class="text-gray-400 hover:text-gray-600 text-2xl leading-none">&times;</button>
            </div>

            <div class="space-y-3">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Nama</label>
                    <input v-model="editForm.nama" type="text"
                           class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Merek / Guna</label>
                    <input v-model="editForm.guna_merek" type="text"
                           class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Ukuran</label>
                    <input v-model="editForm.ukuran" type="number" min="0"
                        class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Bentuk</label>
                    <input v-model="editForm.bentuk" type="text"
                           class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Ketebalan</label>
                    <input v-model="editForm.ketebalan" type="text"
                           class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Bahan</label>
                    <input v-model="editForm.bahan" type="text"
                           class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Harga (Rp)</label>
                    <input v-model="editForm.harga" type="number" min="0"
                            class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Jumlah</label>
                    <input v-model="editForm.jumlah" type="number" min="0"
                            class="w-full border rounded-lg px-3 py-2 text-black" />
                </div>
            </div>

            <div class="mt-6 flex justify-end gap-2">
                <button @click="submitEdit"
                        class="bg-gradient-to-r from-purple-600 to-blue-500 hover:from-blue-500 hover:to-purple-600 text-white px-4 py-2 rounded-lg text-sm font-semibold">
                    Simpan
                </button>
                <button @click="closeEdit"
                        class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm">
                    Batal
                </button>
            </div>
        </div>
    </div>
</Transition>
    <!-- Loading Overlay -->
    <Transition name="fade">
        <div v-if="isLoading"
            class="fixed inset-0 bg-black/40 z-[9999] flex items-center justify-center">
            <div class="loader"></div>
        </div>
    </Transition>
    </div>
</template>

<style scoped>
.info-row {
    display: flex;
    justify-content: space-between;
    padding: 8px 12px;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    background-color: #fafafa;
    font-size: 14px;
    color: #000;
}

.info-row span:first-child {
    color: #64748b;
    font-weight: 500;
}

.info-row span:last-child {
    color: #000;
    font-weight: 600;
}

.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.slide-enter-active,
.slide-leave-active {
    transition: all 0.25s ease;
}

.slide-enter-from,
.slide-leave-to {
    opacity: 0;
    transform: translateY(-8px);
}
.loader {
    width: 50px;
    padding: 8px;
    aspect-ratio: 1;
    border-radius: 50%;
    background: #25b09b;
    --_m:
        conic-gradient(#0000 10%, #000),
        linear-gradient(#000 0 0) content-box;
    -webkit-mask: var(--_m);
    mask: var(--_m);
    -webkit-mask-composite: source-out;
    mask-composite: subtract;
    animation: l3 1s infinite linear;
}

@keyframes l3 {
    to { transform: rotate(1turn); }
}
</style>