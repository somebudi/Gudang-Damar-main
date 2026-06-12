<script setup lang="ts">
import { Link, useForm } from '@inertiajs/vue3';

const form = useForm({
    nama: '',
    harga: { harga: 0, jumlah: 1 },
    kategori: { ukuran: 0, bentuk: '', ketebalan: '', bahan: '', merek: '' },
});

function submit() {
    form.post('/barang');
}
</script>

<template>
    <div class="max-w-3xl mx-auto mt-10 bg-white p-6 rounded-2xl shadow">
        <h2 class="text-2xl font-bold mb-6">Tambah Barang</h2>

        <div v-if="$page.props.flash?.success"
             class="bg-green-100 text-green-700 p-3 rounded mb-4">
            {{ $page.props.flash.success }}
        </div>

        <form @submit.prevent="submit">
            <div class="mb-4">
                <label class="block font-semibold mb-1">Nama Barang</label>
                <input v-model="form.nama" type="text"
                       class="w-full p-2 border rounded-lg"
                       placeholder="Masukkan nama barang" required />
            </div>

            <hr class="my-4" />

            <h4 class="font-semibold mb-2">Harga</h4>
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div>
                    <label class="block mb-1">Harga Satuan</label>
                    <input v-model="form.harga.harga" type="number"
                           class="w-full p-2 border rounded-lg" min="0" required />
                </div>
                <div>
                    <label class="block mb-1">Jumlah</label>
                    <input v-model="form.harga.jumlah" type="number"
                           class="w-full p-2 border rounded-lg" min="1" required />
                </div>
            </div>

            <hr class="my-4" />

            <h4 class="font-semibold mb-2">Kategori</h4>
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label>Ukuran</label>
                        <input v-model="form.kategori.ukuran" type="number" min="0"
                            class="w-full p-2 border rounded-lg" required />
                </div>
                <div>
                    <label>Bentuk</label>
                    <input v-model="form.kategori.bentuk" type="text"
                           class="w-full p-2 border rounded-lg" required />
                </div>
                <div>
                    <label>Ketebalan (cm)</label>
                    <input v-model="form.kategori.ketebalan" type="text"
                           class="w-full p-2 border rounded-lg" required />
                </div>
                <div>
                    <label>Bahan</label>
                    <input v-model="form.kategori.bahan" type="text"
                           class="w-full p-2 border rounded-lg" required />
                </div>
                <div>
                    <label>Merek / Guna</label>
                    <input v-model="form.kategori.merek" type="text"
                           class="w-full p-2 border rounded-lg" required />
                </div>
            </div>

            <div class="flex gap-3 mt-6">
                <button type="submit"
                        class="bg-blue-500 text-white px-4 py-2 rounded-lg">
                    Simpan
                </button>
                <Link href="/barang"
                      class="bg-gray-400 text-white px-4 py-2 rounded-lg">
                    Batal
                </Link>
            </div>
        </form>
    </div>
</template>