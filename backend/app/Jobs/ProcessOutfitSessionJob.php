<?php

namespace App\Jobs;

use App\Models\OutfitFeedback;
use App\Models\OutfitRecommendation;
use App\Models\OutfitSession;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ProcessOutfitSessionJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public string $sessionId
    ) {}

    public function handle(): void
    {
        $session = OutfitSession::with(['outfitPhoto', 'user.wardrobeItems'])->find($this->sessionId);

        if (!$session) {
            Log::error("Outfit session not found: {$this->sessionId}");
            return;
        }

        try {
            $session->update(['status' => 'processing']);

            // Call AI service to analyze outfit
            $response = Http::timeout(30)
                ->post(config('services.ai.url') . '/api/v1/analyze/outfit', [
                    'image_url' => $session->outfitPhoto->presigned_url,
                    'context' => $session->context,
                    'user_id' => $session->user_id,
                ]);

            if ($response->successful()) {
                $data = $response->json();

                // Store feedback
                OutfitFeedback::create([
                    'outfit_session_id' => $session->id,
                    'overall_score' => $data['overall_score'] ?? null,
                    'summary' => $data['summary'] ?? '',
                    'positives' => $data['positives'] ?? [],
                    'issues' => $data['issues'] ?? [],
                    'suggestions' => $data['suggestions'] ?? [],
                ]);

                // Get recommendations if user has wardrobe
                if ($session->user->wardrobeItems()->count() > 0) {
                    $this->getRecommendations($session, $data);
                }

                $session->update(['status' => 'done']);
                Log::info("Outfit session processed successfully: {$session->id}");
            } else {
                throw new \Exception("AI service error: " . $response->body());
            }
        } catch (\Exception $e) {
            Log::error("Failed to process outfit session {$session->id}: " . $e->getMessage());
            $session->update([
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    private function getRecommendations(OutfitSession $session, array $analysisData): void
    {
        try {
            $response = Http::timeout(30)
                ->post(config('services.ai.url') . '/api/v1/recommend/outfit', [
                    'user_id' => $session->user_id,
                    'context' => $session->context,
                    'analysis' => $analysisData,
                ]);

            if ($response->successful()) {
                $recommendations = $response->json('recommendations', []);

                foreach ($recommendations as $index => $rec) {
                    OutfitRecommendation::create([
                        'outfit_session_id' => $session->id,
                        'type' => $rec['type'],
                        'items' => $rec['items'] ?? [],
                        'explanation' => $rec['explanation'] ?? '',
                        'confidence' => $rec['confidence'] ?? null,
                        'rank' => $index,
                    ]);
                }
            }
        } catch (\Exception $e) {
            Log::warning("Failed to get recommendations for session {$session->id}: " . $e->getMessage());
        }
    }
}
