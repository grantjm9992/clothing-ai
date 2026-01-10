<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OutfitRecommendation extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'outfit_session_id',
        'type',
        'items',
        'explanation',
        'confidence',
        'rank',
    ];

    protected function casts(): array
    {
        return [
            'items' => 'array',
            'confidence' => 'decimal:2',
            'rank' => 'integer',
        ];
    }

    public function session(): BelongsTo
    {
        return $this->belongsTo(OutfitSession::class, 'outfit_session_id');
    }
}
