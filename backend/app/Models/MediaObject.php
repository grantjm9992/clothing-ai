<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

class MediaObject extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'type',
        'storage_key',
        'mime_type',
        'width',
        'height',
        'sha256',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'width' => 'integer',
            'height' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function derivatives(): HasMany
    {
        return $this->hasMany(MediaDerivative::class);
    }

    public function getUrlAttribute(): ?string
    {
        if (!$this->storage_key) {
            return null;
        }

        $url = Storage::disk('s3')->url($this->storage_key);

        // Replace internal Docker hostname with localhost for external access
        return str_replace('http://minio:9000', 'http://localhost:9000', $url);
    }

    public function getPresignedUrlAttribute(): ?string
    {
        if (!$this->storage_key) {
            return null;
        }

        $url = Storage::disk('s3')->temporaryUrl(
            $this->storage_key,
            now()->addMinutes(15)
        );

        // Replace internal Docker hostname with localhost for external access
        return str_replace('http://minio:9000', 'http://localhost:9000', $url);
    }
}
