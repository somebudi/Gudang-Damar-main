<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index()
    {
        return Inertia::render('Dashboard', [
            'barangList' => Barang::all(),
        ]);
    }
}