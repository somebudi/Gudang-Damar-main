<?php

namespace App\Http\Controllers\MobileApi;

use App\Concerns\PasswordValidationRules;
use App\Concerns\ProfileValidationRules;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
/**
 * Endpoint Mobile API untuk autentikasi (Flutter app).
 *
 * Bedanya dengan auth web (Fortify/Inertia/Socialite):
 *   - Web pakai session cookie + redirect HTML
 *   - Mobile pakai Sanctum personal access token + JSON response
 *
 * Reuse trait validation dari web (PasswordValidationRules &
 * ProfileValidationRules) supaya aturan password/email konsisten.
 */
class AuthMobileApiController extends Controller
{
    use PasswordValidationRules, ProfileValidationRules;

    /**
     * POST /mobile-api/register
     *
     * Body  : { name, email, password, password_confirmation, device_name? }
     * 201   : { message, user, token }
     * 422   : { message, errors }
     */
    public function register(Request $request): JsonResponse
    {
        $validated = Validator::make($request->all(), [
            ...$this->profileRules(),
            'password'    => $this->passwordRules(),
            'device_name' => 'nullable|string|max:255',
        ])->validate();

        $user = User::create([
            'name'     => $validated['name'],
            'email'    => $validated['email'],
            'password' => $validated['password'],
        ]);

        $deviceName = $validated['device_name'] ?? 'mobile';
        $token      = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Akun berhasil dibuat',
            'user'    => $user,
            'token'   => $token,
        ], 201);
    }

    /**
     * POST /mobile-api/login
     *
     * Body  : { email, password, device_name? }
     * 200   : { message, user, token }
     * 422   : { message, errors }
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email'       => ['required', 'email'],
            'password'    => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:255'],
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau sandi salah.'],
            ]);
        }

        $deviceName = $validated['device_name'] ?? 'mobile';
        $token      = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'user'    => $user,
            'token'   => $token,
        ]);
    }

    /**
     * POST /mobile-api/logout
     * Header: Authorization: Bearer <token>
     *
     * Revoke token yang sedang dipakai saja (single-device logout).
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * GET /mobile-api/me
     * Header: Authorization: Bearer <token>
     *
     * Cek token valid + ambil data user yang sedang login.
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $request->user(),
        ]);
    }
        /**
     * POST /mobile-api/auth/google
     *
     * Body  : { id_token, device_name? }
     * 200   : { message, user, token }
     * 401   : { message: 'Token Google tidak valid' }
     */
    public function googleLogin(Request $request): JsonResponse
    {
        $request->validate([
            'id_token'    => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:255'],
        ]);

        // Verifikasi idToken ke Google
        $clientId = config('services.google_android.client_id');
        $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $request->id_token,
        ]);

        if ($response->failed() || $response->json('aud') !== $clientId) {
            return response()->json(['message' => 'Token Google tidak valid'], 401);
        }

        $payload = $response->json();

        // Cari atau buat user
        $user = User::firstOrCreate(
            ['email' => $payload['email']],
            [
                'name'              => $payload['name'] ?? $payload['email'],
                'google_id'         => $payload['sub'],
                'email_verified_at' => now(),
                'password'          => Hash::make(str()->random(32)),
            ]
        );

        // Update google_id kalau user sudah ada tapi belum punya
        if (! $user->google_id) {
            $user->update(['google_id' => $payload['sub']]);
        }

        $deviceName = $request->device_name ?? 'mobile-google';
        $token      = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Login Google berhasil',
            'user'    => $user,
            'token'   => $token,
        ]);
    }
}