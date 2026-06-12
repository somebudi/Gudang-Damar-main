<?php

namespace App\Http\Controllers;

use App\Services\ImageService;
use Illuminate\Http\Request;
use Exception;

class ImageController extends Controller
{
    public function __construct(
        private ImageService $imageService
    ) {}

    public function generate(Request $request)
    {
        $request->validate([
            'prompt' => 'required|string|max:500',
        ]);

        try {
            $imageUrl = $this->imageService->generate($request->prompt);

            // Kalau request dari AJAX return JSON, kalau dari form biasa return view
            if ($request->expectsJson()) {
                return response()->json(['success' => true, 'url' => $imageUrl]);
            }

            return back()->with([
                'image_url' => $imageUrl,
                'prompt'    => $request->prompt,
            ]);

        } catch (Exception $e) {
            if ($request->expectsJson()) {
                return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
            }

            return back()->withErrors(['error' => $e->getMessage()]);
        }
    }
}