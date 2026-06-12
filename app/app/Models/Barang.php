<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    protected $table      = 'barang';
    protected $primaryKey = 'id_barang';
    public $incrementing  = false;
    protected $keyType    = 'int';
    public $timestamps    = false;

    protected $fillable = [
        'id_barang',
        'nama',
        'harga',
        'jumlah',
        'total',
        'ukuran',
        'bentuk',
        'ketebalan',
        'bahan',
        'guna_merek',
        'pendapatan',
        'jumlah_terjual',
        'tanggal_terakhir_jual',
        'tanggal_restok',
    ];

    protected $casts = [
        'harga'                 => 'integer',
        'jumlah'                => 'integer',
        'total'                 => 'integer',
        'pendapatan'            => 'integer',
        'jumlah_terjual'        => 'integer',
        'tanggal_terakhir_jual' => 'datetime',
        'tanggal_restok'        => 'datetime',
    ];

    /**
     * Helper: catat penjualan barang
     * Kurangi stok + tambah pendapatan + update tanggal jual
     */
    public function jual(int $jumlahJual, ?int $hargaJual = null): void
    {
        $hargaPerUnit = $hargaJual ?? $this->harga;

        $this->update([
            'jumlah'                => max(0, $this->jumlah - $jumlahJual),
            'total'                 => max(0, ($this->jumlah - $jumlahJual) * $this->harga),
            'jumlah_terjual'        => $this->jumlah_terjual + $jumlahJual,
            'pendapatan'            => $this->pendapatan + ($hargaPerUnit * $jumlahJual),
            'tanggal_terakhir_jual' => now(),
        ]);
    }

    /**
     * Helper: catat penambahan stok (restok)
     */
    public function restok(int $jumlahTambah): void
    {
        $this->update([
            'jumlah'         => $this->jumlah + $jumlahTambah,
            'total'          => ($this->jumlah + $jumlahTambah) * $this->harga,
            'tanggal_restok' => now(),
        ]);
    }
}