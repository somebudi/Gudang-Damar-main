<?php
// app/Models/Pesanan.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Pesanan extends Model
{
    protected $table      = 'pesanan';
    protected $primaryKey = 'id_pesanan';
    public $incrementing  = false;
    protected $keyType    = 'int';
    public $timestamps    = false;

    protected $fillable = [
        'id_pesanan',
        'id_barang',
        'id_user',
        'nama_barang',
        'bahan',
        'catatan',
        'jumlah',
        'tanggalpemesanan',
        'tanggalterkirim',
        'bentuk',
        'ukuran',
        'ketebalan',
        'harga',
        'pendapatan',  
    ];

    protected $casts = [
        'id_pesanan'       => 'integer',
        'id_barang'        => 'integer',
        'id_user'          => 'integer',
        'jumlah'           => 'integer',
        'tanggalpemesanan' => 'datetime',
        'tanggalterkirim'  => 'datetime',
        'ukuran'           => 'float',
        'ketebalan'        => 'float',
        'harga'            => 'integer',
        'pendapatan'       => 'integer',  
    ];

    protected static function booted()
    {
        static::creating(function ($pesanan) {
            if (empty($pesanan->id_pesanan)) {
                $maxId = static::max('id_pesanan') ?? 0;
                $pesanan->id_pesanan = $maxId + 1;
            }
        });
    }

    public function barang()
    {
        return $this->belongsTo(Barang::class, 'id_barang', 'id_barang');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id');
    }

    public function servis()
    {
        return $this->hasOne(Servis::class, 'id_pesanan', 'id_pesanan');
    }
}