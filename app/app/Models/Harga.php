<?php

class Harga
{
    private int $harga;
    private int $jumlah;
    private int $total;

    public function __construct(int $harga = 0, int $jumlah = 0)
    {
        $this->harga  = $harga;
        $this->jumlah = $jumlah;
        $this->total  = 0;
    }

    public function getHarga(): int
    {
        return $this->harga;
    }

    public function setHarga(int $harga): void
    {
        $this->harga = $harga;
    }

    public function getJumlah(): int
    {
        return $this->jumlah;
    }

    public function setJumlah(int $jumlah): void
    {
        $this->jumlah = $jumlah;
    }

    public function getTotal(): int
    {
        return $this->total;
    }

    public function hitungTotalHarga(): void
    {
        $this->total = $this->harga * $this->jumlah;
    }
}