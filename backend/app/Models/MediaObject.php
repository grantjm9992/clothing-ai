<?php

namespace App\Models;

use App\Services\S3Service;
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
        'file_size',
        'width',
        'height',
        'sha256',
        'status',
        'uploaded_at',
    ];

    protected function casts(): array
    {
        return [
            'file_size' => 'integer',
            'width' => 'integer',
            'height' => 'integer',
            'uploaded_at' => 'datetime',
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

        return Storage::disk('s3')->url($this->storage_key);
    }

    public function getPresignedUrlAttribute(): ?string
    {
        if (!$this->storage_key) {
            return null;
        }

        return S3Service::generatePresignedGetUrl(
            $this->storage_key,
            config('media.presigned_url_expiry')
        );
    }
}
