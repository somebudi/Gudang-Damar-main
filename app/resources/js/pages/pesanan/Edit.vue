<script setup>
import { router } from '@inertiajs/vue3'
import { reactive } from 'vue'
import Navbar from '@/components/Navbar.vue'

const props = defineProps({
  pesanan: {
    type: Object,
    required: true
  }
})

const form = reactive({
  nama_barang: props.pesanan.nama_barang,
  bahan:       props.pesanan.bahan,
  jumlah:      props.pesanan.jumlah,
  catatan:     props.pesanan.catatan ?? '',
  bentuk:      props.pesanan.bentuk ?? '',
  ukuran:      props.pesanan.ukuran ?? '',
  ketebalan:   props.pesanan.ketebalan ?? '',
  harga:       props.pesanan.harga ?? '',
})

const submitForm = () => {
  router.put(`/pesanan/${props.pesanan.id_pesanan}`, { ...form })
}

const kembali = () => {
  router.get('/pesanan')
}
</script>

<template>
  <div class="edit-page">
    <Navbar />

    <main class="edit-main">
      <div class="edit-header">
        <div>
          <nav class="breadcrumb">
            <a href="/pesanan">Data Pesanan</a>
            <span class="bc-sep">/</span>
            <span class="bc-active">Edit</span>
          </nav>
          <h1 class="page-title">Edit Pesanan</h1>
          <p class="page-subtitle">ID: #{{ String(pesanan.id_pesanan).padStart(6, '0') }}</p>
        </div>
      </div>

      <div class="edit-card">
        <form @submit.prevent="submitForm" class="edit-form">
          <div class="form-group">
            <label>Nama Barang</label>
            <input
              v-model="form.nama_barang"
              type="text"
              required
              placeholder="Contoh: Piring"
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Bahan</label>
              <input
                v-model="form.bahan"
                type="text"
                required
                placeholder="Contoh: Besi, Kayu, PVC"
              />
            </div>
            <div class="form-group">
              <label>Jumlah</label>
              <input
                v-model.number="form.jumlah"
                type="number"
                min="1"
                required
              />
            </div>
          </div>

          <!-- ✨ Bentuk -->
          <div class="form-group">
            <label>Bentuk <span class="label-opt">(opsional)</span></label>
            <input
              v-model="form.bentuk"
              type="text"
              placeholder="Contoh: Persegi, Bulat, Persegi Panjang"
            />
          </div>

          <!-- ✨ Ukuran & Ketebalan -->
          <div class="form-row">
            <div class="form-group">
              <label>Ukuran <span class="label-opt">(opsional)</span></label>
              <input
                v-model.number="form.ukuran"
                type="number"
                step="0.01"
                min="0"
                placeholder="Contoh: 10.5"
              />
            </div>
            <div class="form-group">
              <label>Ketebalan <span class="label-opt">(opsional)</span></label>
              <input
                v-model.number="form.ketebalan"
                type="number"
                step="0.01"
                min="0"
                placeholder="Contoh: 2.5"
              />
            </div>
          </div>

          <!-- ✨ Harga -->
          <div class="form-group">
            <label>Harga <span class="label-opt">(opsional)</span></label>
            <input
              v-model.number="form.harga"
              type="number"
              min="0"
              placeholder="Contoh: 50000"
            />
          </div>

          <div class="form-group">
            <label>Catatan <span class="label-opt">(opsional)</span></label>
            <textarea
              v-model="form.catatan"
              rows="4"
              placeholder="Tambahkan catatan khusus…"
            ></textarea>
          </div>

          <div class="form-actions">
            <button type="button" class="btn-batal" @click="kembali">
              <span class="material-symbols-outlined">arrow_back</span>
              Kembali
            </button>
            <button type="submit" class="btn-simpan">
              <span class="material-symbols-outlined">save</span>
              Simpan Perubahan
            </button>
          </div>
        </form>
      </div>
    </main>

    <footer>&copy; 2025 GudangDamar. All rights reserved.</footer>
  </div>
</template>

<style scoped>
.edit-page {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #f0f2f5;
  font-family: 'Inter', sans-serif;
  color: #000;
}

.edit-main {
  flex: 1;
  padding: 36px 28px;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}

.edit-header { margin-bottom: 28px; }

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: #94a3b8;
  margin-bottom: 8px;
}
.breadcrumb a { color: #94a3b8; text-decoration: none; }
.breadcrumb a:hover { color: #001e40; }
.bc-sep { padding: 0 4px; }
.bc-active { color: #001e40; }

.page-title {
  font-size: 2rem;
  font-weight: 800;
  color: #000;
  margin: 0;
}
.page-subtitle {
  color: #64748b;
  font-size: 0.95rem;
  margin: 4px 0 0;
  font-family: 'Consolas', monospace;
}

.edit-card {
  background: #fff;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 24px rgba(0,30,64,.05);
}

.edit-form {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.form-group label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  color: #000;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: .06em;
}
.label-opt {
  font-weight: 400;
  text-transform: none;
  font-size: 11px;
  color: #94a3b8;
}

.form-group input,
.form-group textarea {
  color: #000;
  width: 100%;
  padding: 12px 14px;
  border: 1.5px solid #e2e8f0;
  border-radius: 10px;
  font-size: 14px;
  font-family: inherit;
  background: #f8fafc;
  resize: vertical;
  box-sizing: border-box;
  transition: border-color .2s, box-shadow .2s;
}
.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #006e25;
  box-shadow: 0 0 0 3px rgba(0,110,37,.12);
  background: #fff;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-top: 8px;
}

.btn-batal,
.btn-simpan {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 10px;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: transform .15s, box-shadow .15s;
}
.btn-batal {
  border: 1.5px solid #e2e8f0;
  background: #fff;
  color: #64748b;
}
.btn-batal:hover { background: #f1f5f9; }
.btn-simpan {
  border: none;
  background: linear-gradient(135deg, #006e25, #00a63e);
  color: #fff;
  font-weight: 700;
  box-shadow: 0 6px 16px rgba(0,110,37,.2);
}
.btn-simpan:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 24px rgba(0,110,37,.3);
}

footer {
  background-color: #222;
  color: white;
  padding: 12px;
  text-align: center;
  font-size: 14px;
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

@media (max-width: 640px) {
  .form-row     { grid-template-columns: 1fr; }
  .form-actions { flex-direction: column-reverse; }
  .form-actions button { width: 100%; justify-content: center; }
}
</style>