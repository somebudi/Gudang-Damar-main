<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Ubah tipe kolom di tabel barang
        DB::statement('ALTER TABLE barang ALTER COLUMN total TYPE bigint');
        DB::statement('ALTER TABLE barang ALTER COLUMN pendapatan TYPE bigint');
        
        // Ubah tipe kolom di tabel aktivitas_barang (karena ini juga diisi saat nambah barang)
        DB::statement('ALTER TABLE aktivitas_barang ALTER COLUMN pendapatan TYPE bigint');
        DB::statement('ALTER TABLE aktivitas_barang ALTER COLUMN harga_satuan TYPE bigint');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('ALTER TABLE barang ALTER COLUMN total TYPE integer');
        DB::statement('ALTER TABLE barang ALTER COLUMN pendapatan TYPE integer');
        
        DB::statement('ALTER TABLE aktivitas_barang ALTER COLUMN pendapatan TYPE integer');
        DB::statement('ALTER TABLE aktivitas_barang ALTER COLUMN harga_satuan TYPE integer');
    }
};
