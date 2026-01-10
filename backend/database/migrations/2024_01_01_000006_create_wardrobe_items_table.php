<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wardrobe_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->uuid('primary_photo_id')->nullable();
            $table->enum('category', ['top', 'bottom', 'outerwear', 'dress', 'shoes', 'bag', 'accessory']);
            $table->string('sub_category')->nullable();
            $table->jsonb('colors')->nullable();
            $table->string('pattern')->nullable();
            $table->string('material')->nullable();
            $table->string('brand')->nullable();
            $table->string('size_label')->nullable();
            $table->enum('fit', ['slim', 'regular', 'relaxed', 'oversized'])->nullable();
            $table->jsonb('season_tags')->nullable();
            $table->smallInteger('formality')->default(5);
            $table->jsonb('style_tags')->nullable();
            $table->boolean('is_active')->default(true);
            $table->enum('status', ['pending', 'processing', 'ready', 'failed'])->default('pending');
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('primary_photo_id')->references('id')->on('media_objects')->onDelete('set null');
            $table->index(['user_id', 'category']);
            $table->index(['user_id', 'is_active']);
            $table->index('formality');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wardrobe_items');
    }
};
