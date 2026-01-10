<?php

namespace App\Http\Controllers\Outfit;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessOutfitSessionJob;
use App\Models\OutfitSession;
use App\Models\SavedOutfit;
use App\Models\StyleMessage;
use App\Models\StyleThread;
use Illuminate\Http\Request;

class OutfitController extends Controller
{
    public function createSession(Request $request)
    {
        $validated = $request->validate([
            'outfitPhotoId' => 'required|uuid|exists:media_objects,id',
            'context' => 'required|array',
            'context.occasion' => 'sometimes|string',
            'context.location' => 'sometimes|string',
            'context.vibe' => 'sometimes|string',
            'context.whoWith' => 'sometimes|string',
            'context.notes' => 'sometimes|string',
        ]);

        $session = OutfitSession::create([
            'user_id' => $request->user()->id,
            'outfit_photo_id' => $validated['outfitPhotoId'],
            'context' => $validated['context'],
            'status' => 'queued',
        ]);

        // Queue processing
        ProcessOutfitSessionJob::dispatch($session->id);

        return response()->json([
            'sessionId' => $session->id,
            'status' => $session->status,
        ], 201);
    }

    public function getSession(Request $request, string $id)
    {
        $session = OutfitSession::with([
            'outfitPhoto',
            'feedback',
            'recommendations'
        ])->findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(['session' => $session]);
    }

    public function getFeedback(Request $request, string $id)
    {
        $session = OutfitSession::with('feedback')->findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(['feedback' => $session->feedback]);
    }

    public function getRecommendations(Request $request, string $id)
    {
        $session = OutfitSession::with('recommendations')->findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'recommendations' => $session->recommendations->sortBy('rank')->values()
        ]);
    }

    public function chat(Request $request, string $id)
    {
        $validated = $request->validate([
            'message' => 'required|string',
        ]);

        $session = OutfitSession::findOrFail($id);

        if ($session->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Get or create thread
        $thread = $session->thread()->firstOrCreate([
            'user_id' => $request->user()->id,
        ]);

        // Add user message
        $userMessage = StyleMessage::create([
            'thread_id' => $thread->id,
            'role' => 'user',
            'content' => $validated['message'],
        ]);

        // TODO: Call AI service to get assistant response
        // For now, return placeholder
        $assistantMessage = StyleMessage::create([
            'thread_id' => $thread->id,
            'role' => 'assistant',
            'content' => 'I understand your request. Let me update the recommendations.',
        ]);

        return response()->json([
            'userMessage' => $userMessage,
            'assistantMessage' => $assistantMessage,
        ]);
    }

    public function listSessions(Request $request)
    {
        $sessions = $request->user()
            ->outfitSessions()
            ->with(['outfitPhoto', 'feedback'])
            ->latest()
            ->paginate(20);

        return response()->json($sessions);
    }

    // Saved Outfits
    public function listSavedOutfits(Request $request)
    {
        $outfits = $request->user()
            ->savedOutfits()
            ->latest()
            ->paginate(20);

        return response()->json($outfits);
    }

    public function saveSaved Outfit(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'items' => 'required|array',
            'items.*' => 'uuid|exists:wardrobe_items,id',
            'occasionTags' => 'sometimes|array',
        ]);

        $outfit = SavedOutfit::create([
            'user_id' => $request->user()->id,
            'name' => $validated['name'],
            'items' => $validated['items'],
            'occasion_tags' => $validated['occasionTags'] ?? [],
        ]);

        return response()->json(['outfit' => $outfit], 201);
    }

    public function deleteSavedOutfit(Request $request, string $id)
    {
        $outfit = SavedOutfit::findOrFail($id);

        if ($outfit->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $outfit->delete();

        return response()->json(['message' => 'Outfit deleted successfully']);
    }
}
