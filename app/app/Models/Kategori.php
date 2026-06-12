<?php

class Kategori
{
    private int $ukuran;
    private string $bentuk;
    private string $ketebalan;
    private string $bahan;
    private string $merek;

    public function __construct(
        int $ukuran = 0,
        string $bentuk = '',
        string $ketebalan = '',
        string $bahan = '',
        string $merek = ''
    ) {
        $this->ukuran    = $ukuran;
        $this->bentuk    = $bentuk;
        $this->ketebalan = $ketebalan;
        $this->bahan     = $bahan;
        $this->merek     = $merek;
    }

    public function getUkuran(): int
    {
        return $this->ukuran;
    }

    public function setUkuran(int $ukuran): void
    {
        $this->ukuran = $ukuran;
    }

    public function getBentuk(): string
    {
        return $this->bentuk;
    }

    public function setBentuk(string $bentuk): void
    {
        $this->bentuk = $bentuk;
    }

    public function getKetebalan(): string
    {
        return $this->ketebalan;
    }

    public function setKetebalan(string $ketebalan): void
    {
        $this->ketebalan = $ketebalan;
    }

    public function getBahan(): string
    {
        return $this->bahan;
    }

    public function setBahan(string $bahan): void
    {
        $this->bahan = $bahan;
    }

    public function getMerek(): string
    {
        return $this->merek;
    }

    public function setMerek(string $merek): void
    {
        $this->merek = $merek;
    }
}