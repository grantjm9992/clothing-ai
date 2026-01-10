<?php

namespace App\Jobs;

use App\Models\WardrobeItem;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ProcessWardrobeItemJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public string $wardrobeItemId
    ) {}

    public function handle(): void
    {
        $item = WardrobeItem::with('primaryPhoto')->find($this->wardrobeItemId);

        if (!$item) {
            Log::error("Wardrobe item not found: {$this->wardrobeItemId}");
            return;
        }

        try {
            $item->update(['status' => 'processing']);

            // Call AI service to parse wardrobe item
            $response = Http::timeout(30)
                ->post(config('services.ai.url') . '/api/v1/parse/wardrobe_item', [
                    'image_url' => $item->primaryPhoto->presigned_url,
                    'user_id' => $item->user_id,
                ]);

            if ($response->successful()) {
                $data = $response->json();

                // Update item with parsed data
                $item->update([
                    'category' => $data['category'] ?? $item->category,
                    'sub_category' => $data['sub_category'] ?? null,
                    'colors' => $data['colors'] ?? [],
                    'pattern' => $data['pattern'] ?? null,
                    'material' => $data['material'] ?? null,
                    'formality' => $data['formality'] ?? 5,
                    'season_tags' => $data['season_tags'] ?? [],
                    'style_tags' => $data['style_tags'] ?? [],
                    'status' => 'ready',
                ]);

                // Generate and store embeddings
                if (isset($data['vector_id'])) {
                    $item->embedding()->updateOrCreate(
                        ['wardrobe_item_id' => $item->id],
                        [
                            'embedding_provider' => 'clip',
                            'vector_id' => $data['vector_id'],
                        ]
                    );
                }

                Log::info("Wardrobe item processed successfully: {$item->id}");
            } else {
                throw new \Exception("AI service error: " . $response->body());
            }
        } catch (\Exception $e) {
            Log::error("Failed to process wardrobe item {$item->id}: " . $e->getMessage());
            $item->update(['status' => 'failed']);
            throw $e;
        }
    }
}
