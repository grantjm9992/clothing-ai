<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MediaDerivative extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = ['media_object_id', 'kind', 'storage_key'];

    public function mediaObject(): BelongsTo
    {
        return $this->belongsTo(MediaObject::class);
    }
}
