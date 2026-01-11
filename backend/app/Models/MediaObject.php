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

        // MinIO will use MINIO_SERVER_URL (localhost:9000) for URL generation
        return Storage::disk('s3')->url($this->storage_key);
    }

    public function getPresignedUrlAttribute(): ?string
    {
        if (!$this->storage_key) {
            return null;
        }

        // MinIO will use MINIO_SERVER_URL (localhost:9000) for presigned URLs
        return Storage::disk('s3')->temporaryUrl(
            $this->storage_key,
            now()->addMinutes(15)
        );
    }
}
