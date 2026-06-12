<script setup lang="ts">
import { router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';
import Navbar from '@/components/Navbar.vue';
import SearchBar from '@/components/SearchBar.vue';

interface Barang {
    id_barang: number;
    nama: string;
    harga: number;
    jumlah: number;
    total: number;
    ukuran: number;
    guna_merek: string;
}

const props = defineProps<{
    barangList: Barang[];
}>();

const search = ref('');
const showFilter = ref(false);
const sortBy = ref('default');

const filteredList = computed(() => {
    let list = [...props.barangList];

    if (search.value) {
        const s = search.value.toLowerCase();
        list = list.filter(b => b.nama?.toLowerCase().includes(s));
    }

    if (sortBy.value === 'az') list.sort((a, b) => a.nama.localeCompare(b.nama, 'id'));
    if (sortBy.value === 'za') list.sort((a, b) => b.nama.localeCompare(a.nama, 'id'));
    if (sortBy.value === 'expensive') list.sort((a, b) => b.harga - a.harga);
    if (sortBy.value === 'cheap') list.sort((a, b) => a.harga - b.harga);

    return list;
});

function applyFilter(sort: string) {
    sortBy.value = sort;
    showFilter.value = false;
}

function hapus(id: number) {
    if (confirm('Yakin ingin menghapus barang ini?')) {
        router.delete(`/barang/${id}`);
    }
}
</script>

<template>
    <div style="display:flex;flex-direction:column;min-height:100vh;">

        <Navbar />

        <!-- Search -->
        <div class="search-header">
            <div style="display:flex;gap:10px;">
                <input v-model="search" class="search-input"
                       type="text" placeholder="Cari barang..." />
                <button class="search-btn">Cari</button>
            </div>
            <button class="filter-btn" @click="showFilter = true">Filter</button>
        </div>

        <!-- Filter Overlay -->
        <div class="overlay" :class="{ active: showFilter }" @click.self="showFilter = false">
            <div class="popup-panel">
                <div class="button-grid">
                    <div class="filter-column">
                        <button class="filter-button" @click="applyFilter('az')">Huruf A-Z</button>
                        <button class="filter-button" @click="applyFilter('za')">Huruf Z-A</button>
                        <button class="filter-button" @click="applyFilter('expensive')">Harga Mahal</button>
                        <button class="filter-button" @click="applyFilter('cheap')">Harga Murah</button>
                    </div>
                </div>
                <button class="close-btn" @click="showFilter = false">Tutup</button>
            </div>
        </div>

        <!-- Tombol Tambah -->
        <div class="btn-wrapper">
            <a href="/barang/create" class="btn-tambah">
                <span class="btn-text">Tambah Jenis Barang</span>
                <span class="btn-icon">+</span>
            </a>
        </div>

        <!-- Grid Cards -->
        <main style="flex:1;overflow-y:auto;padding:20px 0;margin-top:80px;">
            <div class="grid-container">
                <div v-for="barang in filteredList" :key="barang.id_barang" class="card">
                    <a :href="`/barang/${barang.id_barang}`" style="text-decoration:none;">
                        <div class="card-content">
                            <strong>{{ barang.nama }}</strong>
                            <p>Ukuran: {{ barang.ukuran }}</p>
                            <p>Harga: Rp {{ barang.harga.toLocaleString('id-ID') }}</p>
                            <p>Jumlah: {{ barang.jumlah }}</p>
                            <p>Total: Rp {{ barang.total.toLocaleString('id-ID') }}</p>
                        </div>
                    </a>
                    <div class="card-actions">
                        <a :href="`/barang/${barang.id_barang}/edit`" class="action-btn edit">Edit</a>
                        <button @click="hapus(barang.id_barang)" class="action-btn delete">Hapus</button>
                    </div>
                </div>

                <div v-if="!filteredList.length" style="grid-column:1/-1;text-align:center;color:#888;padding:40px;">
                    Tidak ada barang ditemukan
                </div>
            </div>
        </main>

        <footer>
            &copy; 2025 GudangDamar. All rights reserved.
        </footer>

    </div>
</template>

<style scoped>
.search-header {
    position: fixed;
    top: 5px;
    left: 20%;
    transform: none;
    display: flex;
    gap: 10px;
    background-color: white;
    padding: 10px 20px;
    border-radius: 30px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    z-index: 100;
    align-items: center;
}

.search-input {
    padding: 8px 16px;
    border-radius: 20px;
    border: 1px solid #ccc;
    width: 200px;
}

.search-btn, .filter-btn {
    padding: 8px 16px;
    border: none;
    border-radius: 20px;
    background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
    color: white;
    cursor: pointer;
}

.search-btn:hover, .filter-btn:hover {
    background: linear-gradient(135deg, #2575fc 0%, #6a11cb 100%);
    transform: scale(1.05);
}

.overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    z-index: 200;
    justify-content: center;
    align-items: center;
}

.overlay.active { display: flex; }

.popup-panel {
    background: white;
    border-radius: 10px;
    padding: 30px;
    width: 500px;
    max-width: 90%;
    box-shadow: 0 0 20px rgba(0,0,0,0.2);
    animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
    from { transform: scale(0.8); opacity: 0; }
    to   { transform: scale(1);   opacity: 1; }
}

.button-grid { display: flex; gap: 20px; flex-wrap: wrap; }
.filter-column { display: flex; flex-direction: column; gap: 10px; }

.filter-button, .close-btn {
    padding: 8px 16px;
    border-radius: 20px;
    border: none;
    cursor: pointer;
}

.filter-button { background-color: #dcdcdc; }
.filter-button:hover { background-color: #bcbcbc; }
.close-btn { margin-top: 20px; background-color: #e74c3c; color: white; }
.close-btn:hover { background-color: #c0392b; }

.btn-wrapper {
    position: fixed;
    top: 70px;
    left: 5%;
    z-index: 1000;
}

.btn-tambah {
    background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
    color: white;
    padding: 12px 24px;
    font-size: 16px;
    font-weight: 600;
    border-radius: 8px;
    cursor: pointer;
    box-shadow: 0 6px 15px rgba(37,117,252,0.4);
    transition: background 0.3s ease, transform 0.2s ease;
    display: flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
}

.btn-tambah:hover {
    background: linear-gradient(135deg, #2575fc 0%, #6a11cb 100%);
    transform: scale(1.05);
}

.btn-text { display: inline; }
.btn-icon { display: none; font-size: 20px; }

@media (max-width: 900px) {
    .btn-text { display: none; }
    .btn-icon { display: inline; }
    .btn-tambah { padding: 14px; border-radius: 50%; width: 50px; height: 50px; justify-content: center; }
}

.grid-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 15px;
    padding: 20px;
    max-width: 1200px;
    margin: auto;
}

.card {
    position: relative;
    height: 200px;
    background-image: url('/gambar/dapur.jpg');
    background-size: cover;
    background-position: center;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 10px rgba(0,0,0,0.25);
    cursor: pointer;
    transition: transform 0.3s ease;
}

.card:hover { transform: translateY(-5px); }

.card::before {
    content: "";
    position: absolute;
    inset: 0;
    background-color: rgba(0,0,0,0.5);
    opacity: 0;
    transition: 0.3s ease;
    z-index: 1;
}

.card:hover::before { opacity: 1; }

.card-content {
    position: absolute;
    inset: 0;
    z-index: 2;
    color: white;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    opacity: 0;
    padding: 10px;
    text-align: center;
    transition: 0.3s ease;
}

.card:hover .card-content { opacity: 1; }
.card-content p { margin: 4px 0; font-size: 13px; }
.card-content strong { font-size: 15px; margin-bottom: 5px; }

.card-actions {
    position: absolute;
    bottom: 8px;
    left: 0;
    right: 0;
    z-index: 3;
    display: flex;
    justify-content: center;
    gap: 8px;
    opacity: 0;
    transition: 0.3s ease;
}

.card:hover .card-actions { opacity: 1; }

.action-btn {
    padding: 4px 12px;
    border-radius: 20px;
    border: none;
    cursor: pointer;
    font-size: 12px;
    text-decoration: none;
}

.action-btn.edit { background: #f59e0b; color: white; }
.action-btn.delete { background: #ef4444; color: white; }

footer {
    background-color: #222;
    color: white;
    padding: 12px;
    text-align: center;
    font-size: 14px;
}
</style>