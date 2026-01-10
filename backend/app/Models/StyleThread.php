<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StyleThread extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = ['user_id', 'outfit_session_id'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function outfitSession(): BelongsTo
    {
        return $this->belongsTo(OutfitSession::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(StyleMessage::class, 'thread_id');
    }
}
