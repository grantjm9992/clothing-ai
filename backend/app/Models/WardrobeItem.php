<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class WardrobeItem extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'primary_photo_id',
        'category',
        'sub_category',
        'colors',
        'pattern',
        'material',
        'brand',
        'size_label',
        'fit',
        'season_tags',
        'formality',
        'style_tags',
        'is_active',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'colors' => 'array',
            'season_tags' => 'array',
            'style_tags' => 'array',
            'formality' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function primaryPhoto(): BelongsTo
    {
        return $this->belongsTo(MediaObject::class, 'primary_photo_id');
    }

    public function embedding(): HasOne
    {
        return $this->hasOne(WardrobeItemEmbedding::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true)->where('status', 'ready');
    }

    public function scopeCategory($query, string $category)
    {
        return $query->where('category', $category);
    }

    public function scopeFormalityRange($query, int $min, int $max)
    {
        return $query->whereBetween('formality', [$min, $max]);
    }
}
