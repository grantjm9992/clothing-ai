<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_derivatives', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('media_object_id');
            $table->enum('kind', ['thumbnail', 'mask', 'cropped_item', 'face_blurred']);
            $table->string('storage_key');
            $table->timestamps();

            $table->foreign('media_object_id')->references('id')->on('media_objects')->onDelete('cascade');
            $table->index('media_object_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_derivatives');
    }
};
