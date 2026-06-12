<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Setting ini diperlukan biar Flutter web (di port random kayak
    | localhost:56xxx) bisa request ke Laravel (localhost:8000).
    | Mobile (Android/iOS) tidak terpengaruh karena bukan browser.
    |
    */

    'paths' => ['mobile-api/*'],

    'allowed_methods' => ['*'],

    // Untuk development lokal. Untuk production, ganti dengan
    // domain Flutter web yang spesifik.
    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // Set false karena kita pakai bearer token, bukan cookie.
    'supports_credentials' => false,

];