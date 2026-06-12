# Gudang-Damar

**Note for developers : fork the repo first before edit or commit.**

## Description
Gudang Damar adalah aplikasi berbasis website yang dirancang untuk mengoptimalkan 
efisiensi pelayanan toko melalui pengelolaan data barang yang terpusat dan terorganisir. 
Dengan menyediakan akses real-time terhadap informasi stok, harga, dan kategori, aplikasi 
ini mempercepat proses transaksi serta mempermudah pencarian maupun pengurutan 
barang secara akurat bagi kasir. Selain fungsi inventaris standar, sistem ini mendukung 
pengelolaan pesanan khusus dengan spesifikasi tertentu, dokumentasi layanan servis untuk 
barang yang rusak, hingga pendataan supplier dan riwayat aktivitas secara menyeluruh. 
Keamanan data operasional dijamin melalui sistem manajemen hak akses pengguna, 
sementara fitur visualisasi data dalam bentuk grafik memberikan wawasan informatif yang 
memudahkan pengambilan keputusan strategis demi menciptakan pengalaman pelanggan 
yang lebih baik. Terdapat juga fitur image generation untuk melihat preview produk 
berdasarkan atribut dan ukuran.

## 🧑‍💻 Team

|          **Name**          |      **NIM**        |                 **Role**              |
|----------------------------|---------------------|---------------------------------------|
| Devo Ghassan Savero        | 103012300005        | UI/UX Designer & Front-End Programmer |
| Damar Muharram             | 103012300096        | Front-End Programmer & Database                  |
| Bimantara Ardi Winata      | 103012300282        | Back-End Programmer                   |
| Muhammad Alvin Ababil      | 103012330064        | Project Manager & Back-End Programmer |
| Arya Wijaya                | 103012330330        | Back-End Programmer                   |
| Fadhil Abithyasa Effendi   | 103012330370        | Front-End Programmer                  |

## 🚀 Features


## 🛠 Tech Stack

**Frontend:**
- VueJS
- Tailwind CSS

**Backend:**
- Laravel
- InertiaJS
- Supabase

## 🚀 How to Run the Project

### Step 1. Clone the Repository
```bash
https://github.com/NeoRyumasil/Gudang-Damar.git
```

### Step 2. Go to the App Folder
```bash
cd app
```

### Step 3. Set the .env
```
copy the .env .example
rename it to .env
```

### Step 4 Fill this blanks in .env
```
SUPABASE_URL=your-supabase-url
SUPABASE_KEY=your-supabase-key

GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost/auth/google/callback
```

### Step 5. install
```
composer install
npm install
```
### Step 6. Setup the project
```
php artisan key:generate
php artisan storage:link
```

### Step 7. Uncomment this in php.ini
```bash
extension_dir = "ext"
extension=mbstring
extension=openssl
extension=pdo_pgsql
extension=pgsql
```

### Step 8. Run the Project
```bash
composer run dev
```

### Step 9. Go to Localhost Links to See the Project
```
Vite = http://localhost:5173/

Laravel = http://localhost:8000
```

## 📋 Requirements
- Supabase

