<script setup>
import { router } from '@inertiajs/vue3'
import { ref, reactive, computed } from 'vue'
import Navbar from '@/components/Navbar.vue'

// Props dari controller
const props = defineProps({
  servisList: {
    type: Array,
    default: () => []
  }
})

// ── State modal ──────────────────────────────────────────────
const showModal  = ref(false)
const isEditing  = ref(false)
const editId     = ref(null)

const form = reactive({
  nama_barang:   '',
  bahan:         '',
  jumlah:        null,
  bentuk_barang: null,
  catatan:       '',
  harga:         null,
})

// ── Helper ───────────────────────────────────────────────────
const resetForm = () => {
  form.nama_barang   = ''
  form.bahan         = ''
  form.jumlah        = null
  form.bentuk_barang = null
  form.catatan       = ''
  form.harga         = null
  isEditing.value    = false
  editId.value       = null
}

// ── Modal open/close ─────────────────────────────────────────
const openTambah = () => {
  resetForm()
  showModal.value = true
}

const openEdit = (servis) => {
  isEditing.value    = true
  editId.value       = servis.id_servis
  form.nama_barang   = servis.nama_barang
  form.bahan         = servis.bahan
  form.jumlah        = servis.jumlah || null
  form.bentuk_barang = servis.bentuk_barang || null
  form.catatan       = servis.catatan ?? ''
  form.harga         = servis.harga || null
  showModal.value    = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

// ── Submit tambah / update ───────────────────────────────────
const submitForm = () => {
  if (isEditing.value) {
    router.put(`/servis/${editId.value}`, { ...form }, {
      onSuccess: () => closeModal()
    })
  } else {
    router.post('/servis', { ...form }, {
      onSuccess: () => closeModal()
    })
  }
}

// ── Selesai ──────────────────────────────────────────────────
const selesaiServis = (id) => {
  if (confirm('Tandai servis ini sebagai selesai?')) {
    router.post(`/servis/${id}/selesai`)
  }
}

// ── Hapus ────────────────────────────────────────────────────
const hapusServis = (id) => {
  if (confirm('Yakin ingin menghapus data servis ini?')) {
    router.delete(`/servis/${id}`)
  }
}

// ── Cek apakah servis belum selesai ──────────────────────────
// Handle null atau sentinel date (1970-01-01)
const isBelumSelesai = (dateString) => {
  if (!dateString) return true
  const date = new Date(dateString)
  return date.getFullYear() <= 1970
}

// ── Format tanggal ───────────────────────────────────────────
const formatDate = (dateString) => {
  if (!dateString) return '-'

  return new Date(dateString).toLocaleDateString('id-ID', {
    day:    '2-digit',
    month:  'short',
    year:   'numeric',
    hour:   '2-digit',
    minute: '2-digit',
  })
}

// ── Format tanggal kirim (handle sentinel date) ──────────────
const formatTanggalKirim = (dateString) => {
  if (isBelumSelesai(dateString)) return '-'
  return formatDate(dateString)
}

// ── Truncate catatan untuk tampilan tabel ────────────────────
const truncate = (text, maxLength = 40) => {
  if (!text) return '-'
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

// ── Format harga (Rupiah) ────────────────────────────────────
const formatRupiah = (value) => {
  if (!value && value !== 0) return '-'
  return 'Rp ' + Number(value).toLocaleString('id-ID')
}

// ── Total pendapatan (dari servis yang sudah selesai) ────────
const totalPendapatan = computed(() => {
  return props.servisList
    .filter(s => !isBelumSelesai(s.tanggalterkirim))
    .reduce((sum, s) => sum + (Number(s.harga) || 0), 0)
})
</script>

<template>
  <div class="servis-page">
    <Navbar />

    <main class="servis-main">
      <!-- Header -->
      <div class="servis-header">
        <div>
          <nav class="breadcrumb">
            <a href="/barang">Penyimpanan</a>
            <span class="material-symbols-outlined bc-arrow">chevron_right</span>
            <span class="bc-active">Data Servis</span>
          </nav>
          <h1 class="page-title">Data Servis</h1>
          <p class="page-subtitle">Kelola data servis barang gudang.</p>
        </div>
        <button class="btn-tambah-header" @click="openTambah">
          <span class="material-symbols-outlined">add_circle</span>
          Tambah Servis
        </button>
      </div>

      <!-- Summary Cards -->
      <div class="summary-row">
        <div class="summary-card">
          <div class="summary-icon blue">
            <span class="material-symbols-outlined">build</span>
          </div>
          <div>
            <p class="summary-label">Total Servis</p>
            <h3 class="summary-value">{{ servisList.length }}</h3>
          </div>
        </div>
        <div class="summary-card">
          <div class="summary-icon orange">
            <span class="material-symbols-outlined">pending_actions</span>
          </div>
          <div>
            <p class="summary-label">Dalam Proses</p>
            <h3 class="summary-value">
              {{ servisList.filter(s => isBelumSelesai(s.tanggalterkirim)).length }}
            </h3>
          </div>
        </div>
        <div class="summary-card">
          <div class="summary-icon green">
            <span class="material-symbols-outlined">check_circle</span>
          </div>
          <div>
            <p class="summary-label">Selesai</p>
            <h3 class="summary-value">
              {{ servisList.filter(s => !isBelumSelesai(s.tanggalterkirim)).length }}
            </h3>
          </div>
        </div>
        <!-- ✨ Kartu Pendapatan -->
        <div class="summary-card">
          <div class="summary-icon purple">
            <span class="material-symbols-outlined">payments</span>
          </div>
          <div>
            <p class="summary-label">Total Pendapatan</p>
            <h3 class="summary-value">{{ formatRupiah(totalPendapatan) }}</h3>
          </div>
        </div>
      </div>

      <!-- Table -->
      <div class="table-wrapper">
        <div class="table-scroll">
          <table>
            <thead>
              <tr>
                <th>No</th>
                <th>Nama Barang</th>
                <th>Bahan</th>
                <th>Jumlah</th>
                <th>Bentuk</th>
                <th>Harga</th>
                <th>Catatan</th>
                <th>Tgl Pemesanan</th>
                <th>Tgl Selesai</th>
                <th>Status</th>
                <th class="th-aksi">Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(servis, idx) in servisList" :key="servis.id_servis">
                <td class="td-no">{{ idx + 1 }}</td>
                <td class="td-nama">
                  <div class="nama-cell">
                    <div class="nama-icon">
                      <span class="material-symbols-outlined">construction</span>
                    </div>
                    <span>{{ servis.nama_barang }}</span>
                  </div>
                </td>
                <td>{{ servis.bahan }}</td>
                <td class="td-jumlah">{{ servis.jumlah || '-' }}</td>
                <td>{{ servis.bentuk_barang || '-' }}</td>
                <td class="td-harga">{{ formatRupiah(servis.harga) }}</td>
                <td class="td-catatan" :title="servis.catatan">
                  {{ truncate(servis.catatan) }}
                </td>
                <td>{{ formatDate(servis.tanggalpemesanan) }}</td>
                <td>{{ formatTanggalKirim(servis.tanggalterkirim) }}</td>
                <td>
                  <span
                    class="badge"
                    :class="!isBelumSelesai(servis.tanggalterkirim) ? 'badge-selesai' : 'badge-proses'"
                  >
                    {{ !isBelumSelesai(servis.tanggalterkirim) ? 'Selesai' : 'Dalam Proses' }}
                  </span>
                </td>
                <td>
                  <div class="aksi-group">
                    <button
                      v-if="isBelumSelesai(servis.tanggalterkirim)"
                      class="btn-aksi btn-selesai"
                      title="Tandai Selesai"
                      @click="selesaiServis(servis.id_servis)"
                    >
                      <span class="material-symbols-outlined">check</span>
                    </button>
                    <button
                      v-if="isBelumSelesai(servis.tanggalterkirim)"
                      class="btn-aksi btn-edit"
                      title="Edit"
                      @click="openEdit(servis)"
                    >
                      <span class="material-symbols-outlined">edit</span>
                    </button>
                    <button
                      class="btn-aksi btn-hapus"
                      title="Hapus"
                      @click="hapusServis(servis.id_servis)"
                    >
                      <span class="material-symbols-outlined">delete</span>
                    </button>
                  </div>
                </td>
              </tr>

              <tr v-if="servisList.length === 0">
                <td colspan="11" class="td-empty">
                  <span class="material-symbols-outlined empty-icon">inbox</span>
                  <p>Belum ada data servis.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>

    <!-- Modal Tambah / Edit -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
        <div class="modal-card" @click.stop>
          <div class="modal-header">
            <h2>{{ isEditing ? 'Edit Servis' : 'Tambah Servis Baru' }}</h2>
            <button class="modal-close" @click="closeModal">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>

          <form @submit.prevent="submitForm" class="modal-form">
            <!-- Nama Barang (wajib) -->
            <div class="form-group">
              <label>Nama Barang</label>
              <input
                v-model="form.nama_barang"
                type="text"
                required
                placeholder="Masukkan nama barang"
              />
            </div>

            <!-- Bahan (wajib) + Jumlah (opsional) -->
            <div class="form-row">
              <div class="form-group">
                <label>Bahan</label>
                <input
                  v-model="form.bahan"
                  type="text"
                  required
                  placeholder="Contoh: Kayu, Besi, Plastik"
                />
              </div>
              <div class="form-group">
                <label>
                  Jumlah
                  <span class="label-optional">(opsional)</span>
                </label>
                <input
                  v-model.number="form.jumlah"
                  type="number"
                  min="1"
                  placeholder="Default: 1"
                />
              </div>
            </div>

            <!-- Bentuk Barang (opsional) + Harga (opsional) -->
            <div class="form-row">
              <div class="form-group">
                <label>
                  Bentuk Barang (kode)
                  <span class="label-optional">(opsional)</span>
                </label>
                <input
                  v-model.number="form.bentuk_barang"
                  type="number"
                  min="1"
                  placeholder="Kosongkan jika tidak ada"
                />
              </div>
              <div class="form-group">
                <label>
                  Harga
                  <span class="label-optional">(opsional)</span>
                </label>
                <input
                  v-model.number="form.harga"
                  type="number"
                  min="0"
                  placeholder="Contoh: 50000"
                />
              </div>
            </div>

            <!-- Catatan (WAJIB) -->
            <div class="form-group">
              <label>
                Catatan
                <span class="label-required">*</span>
              </label>
              <textarea
                v-model="form.catatan"
                rows="4"
                required
                placeholder="Tambahkan catatan servis, kerusakan, atau permintaan khusus..."
                maxlength="1000"
              ></textarea>
              <p class="char-counter">{{ form.catatan.length }} / 1000 karakter</p>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-batal" @click="closeModal">Batal</button>
              <button type="submit" class="btn-simpan">
                <span class="material-symbols-outlined">{{ isEditing ? 'save' : 'add' }}</span>
                {{ isEditing ? 'Simpan Perubahan' : 'Tambah Servis' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <footer>&copy; 2025 GudangDamar. All rights reserved.</footer>
  </div>
</template>

<style scoped>
/* ===== Page ===== */
.servis-page {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #f0f2f5;
  font-family: 'Inter', sans-serif;
}

.servis-main {
  flex: 1;
  padding: 36px 28px;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}

/* ===== Header ===== */
.servis-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 28px;
  flex-wrap: wrap;
  gap: 16px;
}

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
.breadcrumb a { color: #94a3b8; text-decoration: none; transition: color .2s; }
.breadcrumb a:hover { color: #001e40; }
.bc-arrow { font-size: 14px !important; }
.bc-active { color: #001e40; }

.page-title {
  font-size: 2rem;
  font-weight: 800;
  color: #001e40;
  letter-spacing: -0.02em;
  margin: 0;
}
.page-subtitle {
  color: #64748b;
  font-size: 1rem;
  margin: 4px 0 0;
}

.btn-tambah-header {
  display: flex;
  align-items: center;
  gap: 8px;
  background: linear-gradient(135deg, #006e25, #00a63e);
  color: #fff;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 8px 20px rgba(0,110,37,.25);
  transition: transform .2s, box-shadow .2s;
}
.btn-tambah-header:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 28px rgba(0,110,37,.35);
}

/* ===== Summary ===== */
.summary-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 28px;
}

.summary-card {
  background: #fff;
  border-radius: 14px;
  padding: 22px 24px;
  display: flex;
  align-items: center;
  gap: 18px;
  box-shadow: 0 4px 24px rgba(0,30,64,.05);
  transition: box-shadow .3s;
}
.summary-card:hover { box-shadow: 0 8px 32px rgba(0,30,64,.1); }

.summary-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.summary-icon.blue   { background: #dbeafe; color: #2563eb; }
.summary-icon.orange { background: #ffedd5; color: #ea580c; }
.summary-icon.green  { background: #dcfce7; color: #16a34a; }
.summary-icon.purple { background: #ede9fe; color: #7c3aed; }
.summary-icon .material-symbols-outlined { font-size: 24px; }

.summary-label {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: .12em;
  color: #94a3b8;
  margin: 0 0 4px;
}
.summary-value {
  font-size: 1.75rem;
  font-weight: 800;
  color: #001e40;
  margin: 0;
}

/* ===== Table ===== */
.table-wrapper {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 24px rgba(0,30,64,.05);
}
.table-scroll { overflow-x: auto; }

table { width: 100%; border-collapse: collapse; }

thead tr { background: #f8fafc; border-bottom: 2px solid #e2e8f0; }
th {
  padding: 14px 18px;
  font-size: 10px;
  font-weight: 800;
  letter-spacing: .14em;
  text-transform: uppercase;
  color: #64748b;
  text-align: left;
  white-space: nowrap;
}
.th-aksi { text-align: center; }

tbody tr { border-bottom: 1px solid #f1f5f9; transition: background .15s; }
tbody tr:hover { background: #f8fafc; }

td {
  padding: 16px 18px;
  font-size: 14px;
  color: #334155;
  vertical-align: middle;
}
.td-no     { font-weight: 700; color: #94a3b8; width: 50px; }
.td-jumlah { font-weight: 700; color: #001e40; }
.td-harga  { font-weight: 700; color: #006e25; white-space: nowrap; }

.td-catatan {
  max-width: 220px;
  color: #64748b;
  font-style: italic;
  font-size: 13px;
  cursor: help;
}

.nama-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}
.nama-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #475569;
  flex-shrink: 0;
}
.nama-icon .material-symbols-outlined { font-size: 18px; }
.td-nama span { font-weight: 600; color: #001e40; }

/* Badge status */
.badge {
  display: inline-block;
  padding: 4px 14px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: .06em;
  text-transform: uppercase;
  white-space: nowrap;
}
.badge-selesai { background: #dcfce7; color: #15803d; }
.badge-proses  { background: #fef3c7; color: #b45309; }

/* Action buttons */
.aksi-group {
  display: flex;
  justify-content: center;
  gap: 6px;
}
.btn-aksi {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform .15s, box-shadow .15s;
}
.btn-aksi:hover { transform: scale(1.1); }
.btn-aksi .material-symbols-outlined { font-size: 18px; }

.btn-selesai { background: #dcfce7; color: #16a34a; }
.btn-selesai:hover { box-shadow: 0 4px 12px rgba(22,163,74,.3); }
.btn-edit   { background: #dbeafe; color: #2563eb; }
.btn-edit:hover { box-shadow: 0 4px 12px rgba(37,99,235,.3); }
.btn-hapus  { background: #fee2e2; color: #dc2626; }
.btn-hapus:hover { box-shadow: 0 4px 12px rgba(220,38,38,.3); }

/* Empty state */
.td-empty {
  text-align: center;
  padding: 60px 20px !important;
  color: #94a3b8;
}
.empty-icon { font-size: 48px !important; margin-bottom: 8px; display: block; }
.td-empty p { margin: 8px 0 0; font-size: 15px; }

/* ===== Modal ===== */
.modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0,0,0,.45);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn .2s ease;
}

.modal-card {
  background: #fff;
  border-radius: 20px;
  width: 520px;
  max-width: 92vw;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 24px 64px rgba(0,0,0,.18);
  animation: slideUp .25s ease;
}

@keyframes fadeIn  { from { opacity: 0 } to { opacity: 1 } }
@keyframes slideUp { from { opacity: 0; transform: translateY(24px) } to { opacity: 1; transform: translateY(0) } }

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 28px 0;
}
.modal-header h2 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #001e40;
  margin: 0;
}
.modal-close {
  background: #f1f5f9;
  border: none;
  border-radius: 10px;
  width: 36px;
  height: 36px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #64748b;
  transition: background .15s;
}
.modal-close:hover { background: #e2e8f0; }

.modal-form { padding: 24px 28px 28px; }

.form-group { margin-bottom: 18px; }
.form-group label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  color: #475569;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: .06em;
}

.label-optional {
  font-weight: 500;
  color: #94a3b8;
  text-transform: none;
  letter-spacing: normal;
  margin-left: 4px;
  font-size: 11px;
}

.label-required {
  color: #dc2626;
  margin-left: 4px;
  font-weight: 700;
}

.form-group input,
.form-group textarea {
  color: #000000;
  width: 100%;
  padding: 12px 14px;
  border: 1.5px solid #e2e8f0;
  border-radius: 10px;
  font-size: 14px;
  font-family: inherit;
  background: #f8fafc;
  transition: border-color .2s, box-shadow .2s;
  box-sizing: border-box;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
  line-height: 1.5;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #006e25;
  box-shadow: 0 0 0 3px rgba(0,110,37,.12);
  background: #fff;
}

.char-counter {
  margin: 6px 0 0;
  font-size: 11px;
  color: #94a3b8;
  text-align: right;
  font-weight: 500;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 8px;
}

.btn-batal {
  padding: 12px 24px;
  border-radius: 10px;
  border: 1.5px solid #e2e8f0;
  background: #fff;
  color: #64748b;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: background .15s;
}
.btn-batal:hover { background: #f1f5f9; }

.btn-simpan {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 10px;
  border: none;
  background: linear-gradient(135deg, #006e25, #00a63e);
  color: #fff;
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  box-shadow: 0 6px 16px rgba(0,110,37,.2);
  transition: transform .15s, box-shadow .15s;
}
.btn-simpan:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 24px rgba(0,110,37,.3);
}
.btn-simpan .material-symbols-outlined { font-size: 18px; }

/* ===== Footer ===== */
footer {
  background-color: #222;
  color: white;
  padding: 12px;
  text-align: center;
  font-size: 14px;
}

/* ===== Responsive ===== */
@media (max-width: 1024px) {
  .summary-row { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 768px) {
  .summary-row   { grid-template-columns: 1fr; }
  .servis-header { flex-direction: column; align-items: flex-start; }
  .form-row      { grid-template-columns: 1fr; }
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}
</style>