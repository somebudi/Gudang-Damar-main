<?php

namespace App\Http\Controllers\MobileApi;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Exception;

class ImageMobileApiController extends Controller
{
    private string $promptSuffix =
        ', product photography, white background, studio lighting, ' .
        'sharp focus, photorealistic, high quality, 4k';

    private function translateToEnglish(string $text): string
    {
        try {
            $response = Http::timeout(10)->get('https://api.mymemory.translated.net/get', [
                'q'        => $text,
                'langpair' => 'id|en',
            ]);

            if ($response->successful()) {
                $translated = $response->json('responseData.translatedText');
                if ($translated && strtolower($translated) !== strtolower($text)) {
                    return $translated;
                }
            }
        } catch (Exception $e) {
            Log::warning('Translate failed: ' . $e->getMessage());
        }

        return $text;
    }

    public function generate(Request $request)
    {
        $request->validate([
            'prompt' => 'required|string|max:500',
        ]);

        try {
            $translatedPrompt = $this->translateToEnglish($request->prompt);
            $fullPrompt = $translatedPrompt . $this->promptSuffix;

            Log::info('MobileAPI generate image prompt: ' . $fullPrompt);

            $encodedPrompt = urlencode($fullPrompt);
            $imageUrl = "https://image.pollinations.ai/prompt/{$encodedPrompt}?width=1024&height=1024&nologo=true";

            $response = Http::timeout(120)->get($imageUrl);

            if ($response->failed()) {
                throw new Exception('Gagal mengunduh gambar dari Pollinations.');
            }

            // Kembalikan gambar sebagai base64 — tidak perlu storage:link
            $base64 = base64_encode($response->body());

            return response()->json([
                'success' => true,
                'base64'  => $base64,
                'mime'    => 'image/png',
            ]);

        } catch (Exception $e) {
            Log::error('MobileAPI Image Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat gambar: ' . $e->getMessage(),
            ], 500);
        }
    }
}
