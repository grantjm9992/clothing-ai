<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('style_messages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('thread_id');
            $table->enum('role', ['user', 'assistant', 'system']);
            $table->text('content');
            $table->jsonb('metadata')->nullable();
            $table->timestamps();

            $table->foreign('thread_id')->references('id')->on('style_threads')->onDelete('cascade');
            $table->index(['thread_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('style_messages');
    }
};
