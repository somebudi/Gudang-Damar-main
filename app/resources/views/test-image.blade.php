<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Image Generation</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: sans-serif;
            background: #f5f5f5;
            display: flex;
            justify-content: center;
            padding: 40px 16px;
        }

        .card {
            background: #fff;
            border-radius: 12px;
            padding: 32px;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }

        h1 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 24px;
            color: #111;
        }

        label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: #444;
            margin-bottom: 6px;
        }

        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            resize: vertical;
            min-height: 100px;
            outline: none;
            transition: border 0.2s;
        }

        textarea:focus { border-color: #6366f1; }

        button {
            margin-top: 16px;
            width: 100%;
            padding: 12px;
            background: #6366f1;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }

        button:hover { background: #4f46e5; }
        button:disabled { background: #a5b4fc; cursor: not-allowed; }

        /* Loading state */
        .loading {
            display: none;
            margin-top: 24px;
            text-align: center;
            color: #666;
        }

        .spinner {
            display: inline-block;
            width: 32px;
            height: 32px;
            border: 3px solid #e0e0e0;
            border-top-color: #6366f1;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin-bottom: 8px;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        /* Result */
        .result {
            margin-top: 24px;
        }

        .result img {
            width: 100%;
            border-radius: 8px;
            border: 1px solid #eee;
        }

        .result-meta {
            margin-top: 10px;
            font-size: 13px;
            color: #888;
        }

        /* Error & success alert */
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
        }

        .alert-error {
            background: #fef2f2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        .alert-success {
            background: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
    </style>
</head>
<body>
<div class="card">
    <h1>🎨 Test Image Generation</h1>

    {{-- Tampilkan error validasi atau API --}}
    @if ($errors->any())
        <div class="alert alert-error">
            {{ $errors->first() }}
        </div>
    @endif

    {{-- Tampilkan hasil generate --}}
    @if (session('image_url'))
        <div class="alert alert-success">
            Gambar berhasil di-generate!
        </div>
        <div class="result">
            <img src="{{ session('image_url') }}" alt="Generated image">
            <p class="result-meta">Prompt: "{{ session('prompt') }}"</p>
        </div>
        <hr style="margin: 24px 0; border: none; border-top: 1px solid #eee;">
    @endif

    {{-- Form --}}
    <form id="imageForm" action="/generate-image" method="POST">
        @csrf
        <label for="prompt">Prompt</label>
        <textarea
            id="prompt"
            name="prompt"
            placeholder="Contoh: a cat sitting on a mountain at sunset, photorealistic"
        >{{ old('prompt') }}</textarea>

        <button type="submit" id="submitBtn">Generate Gambar</button>
    </form>

    <div class="loading" id="loadingState">
        <div class="spinner"></div>
        <p>Sedang generate... bisa 20–60 detik</p>
        <p style="font-size:12px; margin-top:4px; color:#aaa">
            Model gratis HF butuh warm-up kalau baru dipakai
        </p>
    </div>
</div>

<script>
    document.getElementById('imageForm').addEventListener('submit', function () {
        document.getElementById('submitBtn').disabled = true;
        document.getElementById('submitBtn').textContent = 'Loading...';
        document.getElementById('loadingState').style.display = 'block';
    });
</script>
</body>
</html>