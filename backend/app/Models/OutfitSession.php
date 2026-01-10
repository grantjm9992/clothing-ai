<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class OutfitSession extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'outfit_photo_id',
        'context',
        'status',
        'error_message',
    ];

    protected function casts(): array
    {
        return [
            'context' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function outfitPhoto(): BelongsTo
    {
        return $this->belongsTo(MediaObject::class, 'outfit_photo_id');
    }

    public function feedback(): HasOne
    {
        return $this->hasOne(OutfitFeedback::class);
    }

    public function recommendations(): HasMany
    {
        return $this->hasMany(OutfitRecommendation::class);
    }

    public function thread(): HasOne
    {
        return $this->hasOne(StyleThread::class);
    }

    public function scopePending($query)
    {
        return $query->whereIn('status', ['queued', 'processing']);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'done');
    }
}
