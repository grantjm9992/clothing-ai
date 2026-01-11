<?php

namespace App\Http\Controllers\Media;

use App\Http\Controllers\Controller;
use App\Models\MediaObject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MediaController extends Controller
{
    public function presign(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|in:outfit_photo,wardrobe_item_photo,avatar,other',
            'mimeType' => 'required|string',
            'fileName' => 'required|string',
        ]);

        $user = $request->user();
        $extension = pathinfo($validated['fileName'], PATHINFO_EXTENSION);
        $uuid = Str::uuid();

        // Create storage path based on type
        $basePath = match($validated['type']) {
            'outfit_photo' => "users/{$user->id}/outfits",
            'wardrobe_item_photo' => "users/{$user->id}/wardrobe",
            'avatar' => "users/{$user->id}/avatar",
            default => "users/{$user->id}/other",
        };

        $storageKey = "{$basePath}/{$uuid}.{$extension}";

        // Create media object
        $mediaObject = MediaObject::create([
            'id' => $uuid,
            'user_id' => $user->id,
            'type' => $validated['type'],
            'storage_key' => $storageKey,
            'mime_type' => $validated['mimeType'],
            'status' => 'pending',
        ]);

        // Generate presigned URL
        // MinIO will use MINIO_SERVER_URL (localhost:9000) for presigned URLs
        $uploadUrl = Storage::disk('s3')->temporaryUrl(
            $storageKey,
            now()->addMinutes(15),
            [
                'ContentType' => $validated['mimeType'],
            ]
        );

        return response()->json([
            'id' => $mediaObject->id,
            'presigned_url' => $uploadUrl,
            'storage_key' => $storageKey,
        ]);
    }

    public function complete(Request $request)
    {
        $validated = $request->validate([
            'mediaObjectId' => 'required|uuid|exists:media_objects,id',
            'width' => 'nullable|integer',
            'height' => 'nullable|integer',
            'sha256' => 'nullable|string',
        ]);

        $mediaObject = MediaObject::findOrFail($validated['mediaObjectId']);

        // Verify ownership
        if ($mediaObject->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Update media object
        $mediaObject->update([
            'width' => $validated['width'] ?? null,
            'height' => $validated['height'] ?? null,
            'sha256' => $validated['sha256'] ?? null,
            'status' => 'uploaded',
        ]);

        return response()->json([
            'mediaObject' => $mediaObject,
        ]);
    }

    public function show(Request $request, string $id)
    {
        $mediaObject = MediaObject::findOrFail($id);

        // Verify ownership
        if ($mediaObject->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'mediaObject' => $mediaObject->load('derivatives'),
            'url' => $mediaObject->presigned_url,
        ]);
    }

    public function destroy(Request $request, string $id)
    {
        $mediaObject = MediaObject::findOrFail($id);

        // Verify ownership
        if ($mediaObject->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Delete from S3
        Storage::disk('s3')->delete($mediaObject->storage_key);

        // Delete derivatives
        foreach ($mediaObject->derivatives as $derivative) {
            Storage::disk('s3')->delete($derivative->storage_key);
        }

        // Soft delete
        $mediaObject->delete();

        return response()->json(['message' => 'Media deleted successfully']);
    }
}
