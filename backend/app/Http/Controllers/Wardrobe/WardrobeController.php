<?php

namespace App\Http\Controllers\Wardrobe;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessWardrobeItemJob;
use App\Models\WardrobeItem;
use Illuminate\Http\Request;

class WardrobeController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->user()->wardrobeItems()->with('primaryPhoto');

        // Apply filters
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->is_active, FILTER_VALIDATE_BOOLEAN));
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('formality_min') && $request->has('formality_max')) {
            $query->whereBetween('formality', [$request->formality_min, $request->formality_max]);
        }

        $items = $query->latest()->paginate(50);

        return response()->json($items);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'primaryPhotoId' => 'required|uuid|exists:media_objects,id',
        ]);

        $item = WardrobeItem::create([
            'user_id' => $request->user()->id,
            'primary_photo_id' => $validated['primaryPhotoId'],
            'status' => 'processing',
        ]);

        // Queue processing job
        ProcessWardrobeItemJob::dispatch($item->id);

        return response()->json([
            'item' => $item->load('primaryPhoto'),
        ], 201);
    }

    public function show(Request $request, string $id)
    {
        $item = WardrobeItem::with(['primaryPhoto', 'embedding'])->findOrFail($id);

        if ($item->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(['item' => $item]);
    }

    public function update(Request $request, string $id)
    {
        $item = WardrobeItem::findOrFail($id);

        if ($item->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'category' => 'sometimes|in:top,bottom,outerwear,dress,shoes,bag,accessory',
            'sub_category' => 'sometimes|string|nullable',
            'colors' => 'sometimes|array',
            'pattern' => 'sometimes|string|nullable',
            'material' => 'sometimes|string|nullable',
            'brand' => 'sometimes|string|nullable',
            'size_label' => 'sometimes|string|nullable',
            'fit' => 'sometimes|in:slim,regular,relaxed,oversized|nullable',
            'season_tags' => 'sometimes|array',
            'formality' => 'sometimes|integer|min:0|max:10',
            'style_tags' => 'sometimes|array',
            'is_active' => 'sometimes|boolean',
        ]);

        $item->update($validated);

        return response()->json(['item' => $item]);
    }

    public function destroy(Request $request, string $id)
    {
        $item = WardrobeItem::findOrFail($id);

        if ($item->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $item->delete();

        return response()->json(['message' => 'Wardrobe item deleted successfully']);
    }

    public function reindex(Request $request, string $id)
    {
        $item = WardrobeItem::findOrFail($id);

        if ($item->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Re-queue processing
        ProcessWardrobeItemJob::dispatch($item->id);

        return response()->json(['message' => 'Reindexing queued']);
    }
}
