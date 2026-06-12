<script setup lang="ts">
import { ref } from 'vue';
import { router } from '@inertiajs/vue3';

const query = ref('');
const showFilter = ref(false);

function search() {
    router.get('/search/result', { query: query.value });
}

function applyFilter(sort: string) {
    router.get('/search/result', { sort });
    showFilter.value = false;
}
</script>

<template>
    <!-- Search Header -->
    <div class="search-header">
        <div style="display:flex;gap:10px;">
            <input v-model="query" class="search-input"
                   type="text" placeholder="Cari barang..."
                   @keyup.enter="search" />
            <button class="search-btn" @click="search">Cari</button>
        </div>
        <button class="filter-btn" @click="showFilter = true">Filter</button>
    </div>

    <!-- Popup Filter -->
    <div class="overlay" :class="{ active: showFilter }"
         @click.self="showFilter = false">
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
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
    z-index: 100;
    align-items: center;
}

.search-input {
    padding: 8px 16px;
    border-radius: 20px;
    border: 1px solid #ccc;
    width: 200px;
}

.search-btn,
.filter-btn {
    padding: 8px 16px;
    border: none;
    border-radius: 20px;
    background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
    color: white;
    cursor: pointer;
}

.search-btn:hover,
.filter-btn:hover {
    background: linear-gradient(135deg, #2575fc 0%, #6a11cb 100%);
    transform: scale(1.05);
    box-shadow: 0 8px 20px rgba(37, 117, 252, 0.6);
}

.overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.5);
    z-index: 200;
    justify-content: center;
    align-items: center;
}

.overlay.active {
    display: flex;
}

.popup-panel {
    background-color: white;
    border-radius: 10px;
    padding: 30px;
    width: 500px;
    max-width: 90%;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.2);
    animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
    from { transform: scale(0.8); opacity: 0; }
    to   { transform: scale(1);   opacity: 1; }
}

.button-grid {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.filter-column {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.filter-button,
.close-btn {
    padding: 8px 16px;
    border-radius: 20px;
    border: none;
    cursor: pointer;
}

.filter-button { background-color: #dcdcdc; }
.filter-button:hover { background-color: #bcbcbc; }

.close-btn {
    margin-top: 20px;
    background-color: #e74c3c;
    color: white;
}

.close-btn:hover { background-color: #c0392b; }
</style>