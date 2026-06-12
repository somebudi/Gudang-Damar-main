<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Jadikan tanggalterkirim nullable
        //    (sebelumnya DEFAULT CURRENT_TIMESTAMP → semua pesanan baru langsung "terkirim")
        DB::statement('ALTER TABLE pesanan ALTER COLUMN tanggalterkirim DROP DEFAULT');
        DB::statement('ALTER TABLE pesanan ALTER COLUMN tanggalterkirim DROP NOT NULL');

        // 2. Jadikan id_pesanan auto-increment menggunakan sequence Supabase/PostgreSQL
        //    (sebelumnya integer biasa, tidak ada nextval)
        DB::statement('CREATE SEQUENCE IF NOT EXISTS pesanan_id_pesanan_seq');
        DB::statement("SELECT setval('pesanan_id_pesanan_seq', COALESCE((SELECT MAX(id_pesanan) FROM pesanan), 0) + 1, false)");
        DB::statement("ALTER TABLE pesanan ALTER COLUMN id_pesanan SET DEFAULT nextval('pesanan_id_pesanan_seq')");
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE pesanan ALTER COLUMN id_pesanan DROP DEFAULT');
        DB::statement('DROP SEQUENCE IF EXISTS pesanan_id_pesanan_seq');
        DB::statement("ALTER TABLE pesanan ALTER COLUMN tanggalterkirim SET DEFAULT CURRENT_TIMESTAMP");
    }
};