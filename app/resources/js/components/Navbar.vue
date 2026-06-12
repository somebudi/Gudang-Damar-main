<script setup lang="ts">
import { Link, router } from '@inertiajs/vue3';

function handleLogout() {
    router.post('/logout');
}
</script>

<template>
    <header class="header">
        <div class="logo">
            <img src="/gambar/LogoDamar.jpeg" alt="Logo" width="55" height="55" />
        </div>
        <ul class="navbar">
            <li><Link href="/barang" id="buttonPenyimpanan">Penyimpanan</Link></li>
            <li><Link href="/servis" id="buttonServis">Servis</Link></li>
            <li><Link href="/pesanan" id="buttonPesanan">Pesanan</Link></li>
            <li><Link href="/riwayat" id="buttonGrafik">Aktivitas</Link></li>
            <li><a href="#" id="logout-button" @click.prevent="handleLogout">Log Out</a></li>
        </ul>
    </header>
</template>

<style scoped>
.header {
    background-color: #66ACE6;
    padding: 1px 10px;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 0;
    box-sizing: border-box;
}

.logo img {
    width: 55px;
    height: 55px;
}

.navbar {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
}

.navbar li {
    margin-left: 20px;
}

.navbar a {
    background-color: transparent;
    border: none;
    color: white;
    text-decoration: none;
    padding: 5px 10px;
    cursor: pointer;
    transition: background-color 0.3s ease;
    border-radius: 5px;
    display: inline-block;
    font-size: 1rem;
}

.navbar a:hover {
    background-color: white;
    color: #66ACE6;
    border-radius: 5px;
}
</style>