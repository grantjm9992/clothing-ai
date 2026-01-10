<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OutfitFeedback extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'outfit_feedback';

    protected $fillable = [
        'outfit_session_id',
        'overall_score',
        'summary',
        'positives',
        'issues',
        'suggestions',
    ];

    protected function casts(): array
    {
        return [
            'overall_score' => 'decimal:2',
            'positives' => 'array',
            'issues' => 'array',
            'suggestions' => 'array',
        ];
    }

    public function session(): BelongsTo
    {
        return $this->belongsTo(OutfitSession::class, 'outfit_session_id');
    }
}
