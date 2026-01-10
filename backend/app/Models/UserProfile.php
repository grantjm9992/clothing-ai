<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserProfile extends Model
{
    use HasFactory;

    protected $primaryKey = 'user_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'user_id',
        'display_name',
        'gender',
        'birth_year',
        'height_cm',
        'body_notes',
        'style_preferences',
    ];

    protected function casts(): array
    {
        return [
            'style_preferences' => 'array',
            'birth_year' => 'integer',
            'height_cm' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
