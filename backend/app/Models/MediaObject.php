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

        // For development with public bucket, use direct URL
        $bucket = config('filesystems.disks.s3.bucket');
        return "http://localhost:9000/{$bucket}/{$this->storage_key}";
    }

    public function getPresignedUrlAttribute(): ?string
    {
        if (!$this->storage_key) {
            return null;
        }

        // For development with public bucket, use direct URL (no signature needed)
        $bucket = config('filesystems.disks.s3.bucket');
        return "http://localhost:9000/{$bucket}/{$this->storage_key}";
    }
}
