<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('outfit_recommendations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('outfit_session_id');
            $table->enum('type', ['swap_item', 'add_layer', 'add_accessory', 'full_outfit']);
            $table->jsonb('items')->nullable(); // array of wardrobe item UUIDs
            $table->text('explanation')->nullable();
            $table->decimal('confidence', 4, 2)->nullable();
            $table->integer('rank')->default(0);
            $table->timestamps();

            $table->foreign('outfit_session_id')->references('id')->on('outfit_sessions')->onDelete('cascade');
            $table->index(['outfit_session_id', 'rank']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('outfit_recommendations');
    }
};
