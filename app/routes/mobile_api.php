<?php

use App\Http\Controllers\MobileApi\AuthMobileApiController;
use App\Http\Controllers\MobileApi\AktivitasMobileApiController;
use App\Http\Controllers\MobileApi\BarangMobileApiController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Mobile API Routes (untuk Flutter mobile app)
|--------------------------------------------------------------------------
*/

// Public — nggak butuh login
Route::post('/register',     [AuthMobileApiController::class, 'register']);
Route::post('/login',        [AuthMobileApiController::class, 'login']);
Route::post('/auth/google',  [AuthMobileApiController::class, 'googleLogin']);

// Protected — wajib membawa token Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me',      [AuthMobileApiController::class, 'me']);
    Route::post('/logout', [AuthMobileApiController::class, 'logout']);
    
    // Fitur Barang
    Route::get('/barang',            [BarangMobileApiController::class, 'index']);
    Route::post('/barang',           [BarangMobileApiController::class, 'store']);
    Route::get('/barang/{id}',       [BarangMobileApiController::class, 'show']);
    Route::put('/barang/{id}',       [BarangMobileApiController::class, 'update']);
    Route::post('/barang/{id}/stok', [BarangMobileApiController::class, 'updateStok']);
    Route::post('/barang/{id}/penjualan', [BarangMobileApiController::class, 'catatPenjualan']);
    Route::delete('/barang/{id}',    [BarangMobileApiController::class, 'destroy']);

    // Fitur Riwayat Aktivitas
    Route::get('/riwayat', [AktivitasMobileApiController::class, 'index']);
    Route::get('/riwayat/export', [AktivitasMobileApiController::class, 'export']);

    // Fitur Pesanan
    Route::get('/pesanan',           [\App\Http\Controllers\MobileApi\PesananMobileApiController::class, 'index']);
    Route::post('/pesanan',          [\App\Http\Controllers\MobileApi\PesananMobileApiController::class, 'store']);
    Route::put('/pesanan/{id}',      [\App\Http\Controllers\MobileApi\PesananMobileApiController::class, 'update']);
    Route::delete('/pesanan/{id}',   [\App\Http\Controllers\MobileApi\PesananMobileApiController::class, 'destroy']);

    // Fitur Servis
    Route::get('/servis',            [\App\Http\Controllers\MobileApi\ServisMobileApiController::class, 'index']);
    Route::post('/servis',           [\App\Http\Controllers\MobileApi\ServisMobileApiController::class, 'store']);
    Route::put('/servis/{id}',       [\App\Http\Controllers\MobileApi\ServisMobileApiController::class, 'update']);
    Route::delete('/servis/{id}',    [\App\Http\Controllers\MobileApi\ServisMobileApiController::class, 'destroy']);

    // Fitur Generate Image AI (Pollinations.ai - no API key needed)
    Route::post('/generate-image',   [\App\Http\Controllers\MobileApi\ImageMobileApiController::class, 'generate']);
});