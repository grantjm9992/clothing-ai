<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('media_objects', function (Blueprint $table) {
            $table->bigInteger('file_size')->nullable()->after('mime_type');
            $table->timestamp('uploaded_at')->nullable()->after('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('media_objects', function (Blueprint $table) {
            $table->dropColumn(['file_size', 'uploaded_at']);
        });
    }
};
