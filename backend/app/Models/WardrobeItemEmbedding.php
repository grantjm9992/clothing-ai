<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WardrobeItemEmbedding extends Model
{
    use HasFactory;

    protected $primaryKey = 'wardrobe_item_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ['wardrobe_item_id', 'embedding_provider', 'vector_id'];

    public function wardrobeItem(): BelongsTo
    {
        return $this->belongsTo(WardrobeItem::class);
    }
}
