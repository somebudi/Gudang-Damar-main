<script setup>
import { router } from '@inertiajs/vue3'
import { ref } from 'vue'

// props dari controller
const props = defineProps({
  servis: Object
})

// form state (isi dari data lama)
const form = ref({
  catatanPemesanan: props.servis.catatanPemesanan || '',
  harga:            props.servis.harga || null,
})

// submit update
const submit = () => {
  router.post(`/servis/update/${props.servis.id_pesanan}`, form.value)
}
</script>

<template>
  <div class="container d-flex justify-content-center">
    <div class="card">
      <h2 class="mb-4 text-center">Edit Data Servis</h2>

      <form @submit.prevent="submit">
        <div class="mb-3">
          <label class="form-label">Catatan Pemesanan</label>

          <textarea
            v-model="form.catatanPemesanan"
            class="form-control"
            required
          ></textarea>
        </div>

        <!-- ✨ Field Harga -->
        <div class="mb-3">
          <label class="form-label">Harga</label>

          <input
            v-model.number="form.harga"
            type="number"
            min="0"
            class="form-control harga-input"
            placeholder="Contoh: 50000"
          />
        </div>

        <div class="d-flex justify-content-between">
          <button
            type="button"
            @click="$inertia.visit('/riwayat')"
            class="btn btn-secondary"
          >
            Kembali
          </button>

          <button type="submit" class="btn btn-primary">
            Simpan Perubahan
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
body {
  background: linear-gradient(to bottom, #FBECCA 30%, #ffffff 100%);
}

.card {
  margin-top: 5%;
  background-color: white;
  border-radius: 12px;
  padding: 30px 20px;
  width: 40%;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

textarea {
  width: 100%;
  height: 200px;
  padding: 12px;
  font-size: 14px;
  border: 1px solid #ccc;
  border-radius: 6px;
  resize: vertical;
}

.harga-input {
  width: 100%;
  padding: 12px;
  font-size: 14px;
  border: 1px solid #ccc;
  border-radius: 6px;
}
</style>