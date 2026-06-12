<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gudang Damar</title>
    @vite('resources/css/app.css')
</head>
<body>

    @include('components.navbar')

    <main>
        @yield('content')
    </main>

</body>
</html>