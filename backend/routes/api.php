<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Billing\BillingController;
use App\Http\Controllers\Media\MediaController;
use App\Http\Controllers\Outfit\OutfitController;
use App\Http\Controllers\Wardrobe\WardrobeController;
use Illuminate\Support\Facades\Route;

// Public auth routes
Route::prefix('v1/auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/oauth/{provider}', [AuthController::class, 'oauth']);
});

// Protected routes
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    // Auth
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Media (with rate limiting)
    Route::middleware([
        'throttle:' . config('media.rate_limit.max_attempts', 20) . ',' . config('media.rate_limit.decay_minutes', 1)
    ])->group(function () {
        Route::post('/media/presign', [MediaController::class, 'presign']);
        Route::post('/media/complete', [MediaController::class, 'complete']);
    });
    Route::get('/media/{id}', [MediaController::class, 'show']);
    Route::delete('/media/{id}', [MediaController::class, 'destroy']);

    // Wardrobe
    Route::get('/wardrobe/items', [WardrobeController::class, 'index']);
    Route::post('/wardrobe/items', [WardrobeController::class, 'store']);
    Route::get('/wardrobe/items/{id}', [WardrobeController::class, 'show']);
    Route::patch('/wardrobe/items/{id}', [WardrobeController::class, 'update']);
    Route::delete('/wardrobe/items/{id}', [WardrobeController::class, 'destroy']);
    Route::post('/wardrobe/items/{id}/reindex', [WardrobeController::class, 'reindex']);

    // Outfit sessions
    Route::post('/outfits/sessions', [OutfitController::class, 'createSession']);
    Route::get('/outfits/sessions', [OutfitController::class, 'listSessions']);
    Route::get('/outfits/sessions/{id}', [OutfitController::class, 'getSession']);
    Route::get('/outfits/sessions/{id}/feedback', [OutfitController::class, 'getFeedback']);
    Route::get('/outfits/sessions/{id}/recommendations', [OutfitController::class, 'getRecommendations']);
    Route::post('/outfits/sessions/{id}/chat', [OutfitController::class, 'chat']);

    // Saved outfits
    Route::get('/saved-outfits', [OutfitController::class, 'listSavedOutfits']);
    Route::post('/saved-outfits', [OutfitController::class, 'saveOutfit']);
    Route::delete('/saved-outfits/{id}', [OutfitController::class, 'deleteSavedOutfit']);

    // Billing
    Route::post('/billing/verify', [BillingController::class, 'verify']);
    Route::get('/billing/status', [BillingController::class, 'status']);
});
