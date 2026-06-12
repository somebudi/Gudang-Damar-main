<?php

use App\Http\Controllers\Auth\SocialiteController;
use App\Http\Controllers\GrafikController;
use App\Services\DatabaseService;
use Illuminate\Support\Facades\Route;
use Laravel\Fortify\Features;
use App\Http\Controllers\BarangController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\ServisController;
use App\Http\Controllers\PesananController;
use App\Http\Controllers\AktivitasController;

Route::inertia('/', 'Welcome', [
    'canRegister' => Features::enabled(Features::registration()),
])->name('home');

Route::get('/test', function () {
    $databaseService = new DatabaseService();
    $data = $databaseService->testConnection();
    return response()->json($data);
});

// Protected routes - require authentication
Route::middleware(['auth'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard.barang');

    Route::resource('barang', BarangController::class);
    Route::post('/barang/{id}/jual', [BarangController::class, 'jual'])->name('barang.jual');
    Route::post('/barang/{id}/restok', [BarangController::class, 'restok'])->name('barang.restok');

    Route::get('/servis',                  [ServisController::class, 'index'])   ->name('servis.index');
    Route::post('/servis',                 [ServisController::class, 'store'])   ->name('servis.store');
    Route::put('/servis/{id}',             [ServisController::class, 'update'])  ->name('servis.update');
    Route::delete('/servis/{id}',          [ServisController::class, 'destroy']) ->name('servis.destroy');
    Route::post('/servis/{id}/selesai',    [ServisController::class, 'selesai']) ->name('servis.selesai');

    Route::get('/pesanan',                  [PesananController::class, 'index'])   ->name('pesanan.index');
    Route::post('/pesanan',                 [PesananController::class, 'store'])   ->name('pesanan.store');
    Route::get('/pesanan/{id}/edit',        [PesananController::class, 'edit'])    ->name('pesanan.edit');
    Route::put('/pesanan/{id}',             [PesananController::class, 'update'])  ->name('pesanan.update');
    Route::delete('/pesanan/{id}',          [PesananController::class, 'destroy']) ->name('pesanan.destroy');
    Route::post('/pesanan/{id}/selesai',    [PesananController::class, 'selesai']) ->name('pesanan.selesai');

    Route::post('/generate-image', [ImageController::class, 'generate']);
    Route::get('/test-image', function () {
        return view('test-image');
    });

    // ── Grafik / Analytics ────────────────────────────────────────────────────
    Route::get('/grafik', [GrafikController::class, 'index'])->name('grafik.index');
});

Route::prefix('riwayat')->name('riwayat.')->middleware(['auth'])->group(function () {
    // Halaman utama Riwayat (Riwayat/Index.vue)
    Route::get('/', [AktivitasController::class, 'index'])->name('index');

    // Export ke CSV
    Route::get('/export', [AktivitasController::class, 'export'])->name('export');

    // Detail 1 aktivitas (jenis: pesanan/barang/servis)
    Route::get('/{jenis}/{id}', [AktivitasController::class, 'show'])
        ->where('jenis', 'pesanan|barang|servis')
        ->name('show');
});

// Google OAuth Routes (no auth needed)
Route::get('/auth/google/redirect', [SocialiteController::class, 'redirect'])->name('auth.google.redirect');
Route::get('/auth/google/callback', [SocialiteController::class, 'callback'])->name('auth.google.callback');

require __DIR__.'/settings.php';