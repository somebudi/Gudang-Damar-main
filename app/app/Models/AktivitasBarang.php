<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AktivitasBarang extends Model
{
    protected $table      = 'aktivitas_barang';
    protected $primaryKey = 'id_aktivitas';
    public $timestamps    = false;

    protected $fillable = [
        'id_barang',
        'nama_barang',
        'jenis',
        'jumlah',
        'stok_sebelum',
        'stok_sesudah',
        'harga_satuan',
        'pendapatan',
        'catatan',
        'tanggal',
    ];

    protected $casts = [
        'id_barang'    => 'integer',
        'jumlah'       => 'integer',
        'stok_sebelum' => 'integer',
        'stok_sesudah' => 'integer',
        'harga_satuan' => 'integer',
        'pendapatan'   => 'integer',
        'tanggal'      => 'datetime',
    ];

    /**
     * Relasi ke tabel barang
     */
    public function barang()
    {
        return $this->belongsTo(Barang::class, 'id_barang', 'id_barang');
    }
}