<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('outfit_feedback', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('outfit_session_id');
            $table->decimal('overall_score', 4, 2)->nullable();
            $table->text('summary')->nullable();
            $table->jsonb('positives')->nullable();
            $table->jsonb('issues')->nullable();
            $table->jsonb('suggestions')->nullable();
            $table->timestamps();

            $table->foreign('outfit_session_id')->references('id')->on('outfit_sessions')->onDelete('cascade');
            $table->index('outfit_session_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('outfit_feedback');
    }
};
