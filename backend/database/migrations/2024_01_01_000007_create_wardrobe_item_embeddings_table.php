<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wardrobe_item_embeddings', function (Blueprint $table) {
            $table->uuid('wardrobe_item_id')->primary();
            $table->string('embedding_provider')->default('clip');
            $table->string('vector_id')->nullable();
            $table->timestamps();

            $table->foreign('wardrobe_item_id')->references('id')->on('wardrobe_items')->onDelete('cascade');
            $table->index('vector_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wardrobe_item_embeddings');
    }
};
