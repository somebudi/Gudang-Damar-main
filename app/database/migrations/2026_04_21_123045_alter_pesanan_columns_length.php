<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        \Illuminate\Support\Facades\DB::statement('ALTER TABLE pesanan ALTER COLUMN nama_barang TYPE VARCHAR(255)');
        \Illuminate\Support\Facades\DB::statement('ALTER TABLE pesanan ALTER COLUMN bahan TYPE VARCHAR(255)');
        \Illuminate\Support\Facades\DB::statement('ALTER TABLE pesanan ALTER COLUMN catatan TYPE VARCHAR(500)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Not easily reversible without knowing the original limits.
    }
};
