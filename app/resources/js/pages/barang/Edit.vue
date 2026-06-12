<script setup lang="ts">
import { Link, useForm } from '@inertiajs/vue3';

const props = defineProps<{
    barang: {
        id_barang: number;
        nama: string;
        harga: number;
        jumlah: number;
        ukuran: number;
        ketebalan: string;
        bahan: string;
        bentuk: string;
        guna_merek: string;
    };
}>();

const form = useForm({
    nama: props.barang.nama,
    harga: {
        harga: props.barang.harga,
        jumlah: props.barang.jumlah,
    },
    kategori: {
        ukuran: props.barang.ukuran,
        ketebalan: props.barang.ketebalan,
        bahan: props.barang.bahan,
        bentuk: props.barang.bentuk,
        merek: props.barang.guna_merek,
    },
});

function submit() {
    form.put(`/barang/${props.barang.id_barang}`);
}
</script>

<template>
    <main class="max-w-md mx-auto mt-10 bg-white rounded-2xl shadow p-6">
        <h2 class="text-xl font-bold text-center mb-6 text-gray-800">
            Edit Barang
        </h2>

        <form @submit.prevent="submit">

            <label class="block mb-1 font-semibold text-gray-700">Nama</label>
            <input v-model="form.nama" type="text"
                   class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Merek / Guna</label>
            <input v-model="form.kategori.merek" type="text"
                   class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Ukuran</label>
            <input v-model="form.kategori.ukuran" type="number" min="0"
                class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Bentuk</label>
            <input v-model="form.kategori.bentuk" type="text"
                   class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Ketebalan</label>
            <input v-model="form.kategori.ketebalan" type="text"
                   class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Bahan</label>
            <input v-model="form.kategori.bahan" type="text"
                   class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Harga (Rp)</label>
            <input v-model="form.harga.harga" type="number" min="0"
                class="w-full p-2 mb-4 border rounded-lg text-black" />

            <label class="block mb-1 font-semibold text-gray-700">Jumlah</label>
            <input v-model="form.harga.jumlah" type="number" min="0"
                class="w-full p-2 mb-4 border rounded-lg text-black" />

            <div class="flex flex-col gap-3 mt-4">
                <button type="submit"
                        class="bg-gradient-to-r from-purple-600 to-blue-500 text-white py-2 rounded-lg font-bold shadow hover:from-blue-500 hover:to-purple-600">
                    Simpan Perubahan
                </button>
                <Link :href="`/barang`"
                      class="text-center bg-gray-200 hover:bg-gray-300 text-gray-700 py-2 rounded-lg font-bold">
                    Kembali
                </Link>
            </div>

        </form>
    </main>
</template>