<?php

namespace App\Http\Controllers\Media;

use App\Http\Controllers\Controller;
use App\Models\MediaObject;
use App\Services\S3Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class MediaController extends Controller
{
    public function presign(Request $request)
    {
        try {
            $validated = $request->validate([
                'type' => 'required|in:outfit_photo,wardrobe_item_photo,avatar,other',
                'mimeType' => [
                    'required',
                    'string',
                    function ($attribute, $value, $fail) {
                        if (!in_array($value, config('media.allowed_mime_types'))) {
                            $fail('The ' . $attribute . ' must be one of: ' . implode(', ', config('media.allowed_mime_types')));
                        }
                    },
                ],
                'fileName' => 'required|string|max:255',
                'fileSize' => 'required|integer|min:1|max:' . config('media.max_file_size'),
            ]);

            $user = $request->user();
            $extension = pathinfo($validated['fileName'], PATHINFO_EXTENSION);

            // Validate file extension
            if (!in_array(strtolower($extension), config('media.allowed_extensions'))) {
                throw ValidationException::withMessages([
                    'fileName' => 'File extension not allowed. Allowed: ' . implode(', ', config('media.allowed_extensions')),
                ]);
            }

            $uuid = Str::uuid();

            // Create storage path based on type
            $basePath = match ($validated['type']) {
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
                'file_size' => $validated['fileSize'],
                'status' => 'pending',
            ]);

            // Generate presigned URL with security options
            $uploadUrl = S3Service::generatePresignedPutUrl(
                $storageKey,
                config('media.presigned_url_expiry'),
                config('media.s3_upload_options')
            );

            Log::info('Presigned URL generated', [
                'user_id' => $user->id,
                'media_object_id' => $mediaObject->id,
                'type' => $validated['type'],
            ]);

            return response()->json([
                'id' => $mediaObject->id,
                'presigned_url' => $uploadUrl,
                'storage_key' => $storageKey,
                'expires_in' => config('media.presigned_url_expiry'),
            ]);
        } catch (ValidationException $e) {
            throw $e;
        } catch (\Exception $e) {
            Log::error('Failed to generate presigned URL', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => 'Failed to generate upload URL',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }

    public function complete(Request $request)
    {
        try {
            $validated = $request->validate([
                'mediaObjectId' => 'required|uuid|exists:media_objects,id',
                'width' => 'nullable|integer|min:1|max:50000',
                'height' => 'nullable|integer|min:1|max:50000',
                'sha256' => 'nullable|string|size:64',
            ]);

            $mediaObject = MediaObject::findOrFail($validated['mediaObjectId']);

            // Verify ownership
            if ($mediaObject->user_id !== $request->user()->id) {
                Log::warning('Unauthorized media completion attempt', [
                    'user_id' => $request->user()->id,
                    'media_object_id' => $mediaObject->id,
                    'owner_id' => $mediaObject->user_id,
                ]);
                return response()->json(['message' => 'Unauthorized'], 403);
            }

            // Verify the file was actually uploaded to S3
            if (!S3Service::objectExists($mediaObject->storage_key)) {
                Log::error('Upload completion failed: file not found in S3', [
                    'media_object_id' => $mediaObject->id,
                    'storage_key' => $mediaObject->storage_key,
                ]);

                return response()->json([
                    'message' => 'File not found in storage. Please retry upload.',
                ], 422);
            }

            // Get file metadata from S3
            $metadata = S3Service::getObjectMetadata($mediaObject->storage_key);
            if ($metadata) {
                // Verify file size matches
                if ($mediaObject->file_size && abs($metadata['size'] - $mediaObject->file_size) > 1024) {
                    Log::warning('File size mismatch', [
                        'media_object_id' => $mediaObject->id,
                        'expected' => $mediaObject->file_size,
                        'actual' => $metadata['size'],
                    ]);
                }

                // Update with actual file size from S3
                $validated['file_size'] = $metadata['size'];
            }

            // Update media object
            $mediaObject->update([
                'width' => $validated['width'] ?? null,
                'height' => $validated['height'] ?? null,
                'sha256' => $validated['sha256'] ?? null,
                'file_size' => $validated['file_size'] ?? $mediaObject->file_size,
                'status' => 'uploaded',
                'uploaded_at' => now(),
            ]);

            Log::info('Media upload completed', [
                'user_id' => $request->user()->id,
                'media_object_id' => $mediaObject->id,
            ]);

            return response()->json([
                'mediaObject' => $mediaObject,
            ]);
        } catch (ValidationException $e) {
            throw $e;
        } catch (\Exception $e) {
            Log::error('Failed to complete media upload', [
                'media_object_id' => $validated['mediaObjectId'] ?? null,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => 'Failed to complete upload',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }

    public function show(Request $request, string $id)
    {
        try {
            $mediaObject = MediaObject::findOrFail($id);

            // Verify ownership
            if ($mediaObject->user_id !== $request->user()->id) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }

            return response()->json([
                'mediaObject' => $mediaObject->load('derivatives'),
                'url' => $mediaObject->presigned_url,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to retrieve media object', [
                'media_object_id' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Media object not found',
            ], 404);
        }
    }

    public function destroy(Request $request, string $id)
    {
        try {
            $mediaObject = MediaObject::findOrFail($id);

            // Verify ownership
            if ($mediaObject->user_id !== $request->user()->id) {
                Log::warning('Unauthorized media deletion attempt', [
                    'user_id' => $request->user()->id,
                    'media_object_id' => $mediaObject->id,
                    'owner_id' => $mediaObject->user_id,
                ]);
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

            Log::info('Media object deleted', [
                'user_id' => $request->user()->id,
                'media_object_id' => $mediaObject->id,
            ]);

            return response()->json(['message' => 'Media deleted successfully']);
        } catch (\Exception $e) {
            Log::error('Failed to delete media object', [
                'media_object_id' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Failed to delete media',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }
}
